//
//  IQKeyboardManager.swift
// https://github.com/hackiftekhar/IQKeyboardManager
// Copyright (c) 2013-15 Iftekhar Qurashi.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation
import CoreGraphics
import UIKit

///---------------------
/// MARK: IQToolbar tags
///---------------------

/**
Default tag for toolbar with Done button   -1002.
*/
let  kIQDoneButtonToolbarTag    =   -1002

/**
Default tag for toolbar with Previous/Next buttons -1005.
*/
let  kIQPreviousNextButtonToolbarTag    =   -1005

/**
Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView. Neither need to write any code nor any setup required and much more. A generic version of KeyboardManagement. https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
*/

class IQKeyboardManager: NSObject, UIGestureRecognizerDelegate {
    
    
    ///---------------------------
    ///  MARK: UIKeyboard handling
    ///---------------------------
    
    /**
    Enable/disable managing distance between keyboard and textField. Default is YES(Enabled when class loads in `+(void)load` method).
    */
    var enable = false {
        
        didSet {
            //If not enable, enable it.
            if enable == true && oldValue == false {
                //If keyboard is currently showing. Sending a fake notification for keyboardWillShow to adjust view according to keyboard.
                if _kbShowNotification != nil {
                    keyboardWillShow(_kbShowNotification)
                }
                _IQShowLog("enabled")
            } else if enable == false && oldValue == true {   //If not disable, desable it.
                keyboardWillHide(nil)
                _IQShowLog("disabled")
            }
        }
    }
    
    /**
    To set keyboard distance from textField. can't be less than zero. Default is 10.0.
    */
    var keyboardDistanceFromTextField: CGFloat {
        
        set {
            _privateKeyboardDistanceFromTextField =  max(0, newValue)
            _IQShowLog("keyboardDistanceFromTextField: \(_privateKeyboardDistanceFromTextField)")
        }
        get {
            return _privateKeyboardDistanceFromTextField
        }
    }

    /**
    Prevent keyboard manager to slide up the rootView to more than keyboard height. Default is YES.
    */
    var preventShowingBottomBlankSpace = true
    
    /**
    Returns the default singleton instance.
    */
    class func sharedManager() -> IQKeyboardManager {
        
        struct Static {
            //Singleton instance. Initializing keyboard manger.
            static let kbManager = IQKeyboardManager()
        }
        
        /** @return Returns the default singleton instance. */
        return Static.kbManager
    }
    
    ///-------------------------
    /// MARK: IQToolbar handling
    ///-------------------------
    
    /**
    Automatic add the IQToolbar functionality. Default is YES.
    */
    var enableAutoToolbar = true {
        
        didSet {

            enableAutoToolbar ?addToolbarIfRequired():removeToolbarIfRequired()

            let enableToolbar = enableAutoToolbar ? "Yes" : "NO"

            _IQShowLog("enableAutoToolbar: \(enableToolbar)")
        }
    }
    
    /**
    AutoToolbar managing behaviour. Default is IQAutoToolbarBySubviews.
    */
    var toolbarManageBehaviour = IQAutoToolbarManageBehaviour.bySubviews

    /**
    If YES, then uses textField's tintColor property for IQToolbar, otherwise tint color is black. Default is NO.
    */
    var shouldToolbarUsesTextFieldTintColor = false
    
    /**
    If YES, then it add the textField's placeholder text on IQToolbar. Default is YES.
    */
    var shouldShowTextFieldPlaceholder = true
    
    /**
    Placeholder Font. Default is nil.
    */
    var placeholderFont: UIFont?
    
    
    ///--------------------------
    /// MARK: UITextView handling
    ///--------------------------
    
    /**
    Adjust textView's frame when it is too big in height. Default is NO.
    */
    var canAdjustTextView = false

    /**
    Adjust textView's contentInset to fix a bug. for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string Default is YES.
    */
    var shouldFixTextViewClip = true

    
    ///---------------------------------------
    /// MARK: UIKeyboard appearance overriding
    ///---------------------------------------

    /**
    Override the keyboardAppearance for all textField/textView. Default is NO.
    */
    var overrideKeyboardAppearance = false
    
    /**
    If overrideKeyboardAppearance is YES, then all the textField keyboardAppearance is set using this property.
    */
    var keyboardAppearance = UIKeyboardAppearance.default

    
    ///-----------------------------------------------------------
    /// MARK: UITextField/UITextView Next/Previous/Resign handling
    ///-----------------------------------------------------------
    
    
    /**
    Resigns Keyboard on touching outside of UITextField/View. Default is NO.
    */
    var shouldResignOnTouchOutside = false {
        
        didSet {
            _tapGesture.isEnabled = shouldResignOnTouchOutside
            
            let shouldResign = shouldResignOnTouchOutside ? "Yes" : "NO"
            
            _IQShowLog("shouldResignOnTouchOutside: \(shouldResign)")
        }
    }
    
    /**
    Resigns currently first responder field.
    */
    func resignFirstResponder()-> Bool {
        
        if let textFieldRetain = _textFieldView {
            
            //Resigning first responder
            let isResignFirstResponder = textFieldRetain.resignFirstResponder()
            
            //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
            if isResignFirstResponder == false {
                //If it refuses to resign then becoming it first responder again for getting notifications callback.
                textFieldRetain.becomeFirstResponder()
                
                _IQShowLog("Refuses to resign first responder: \(_textFieldView?._IQDescription())")
            }
            
            return isResignFirstResponder;
        }
        
        return false
    }
    
    /**
    Returns YES if can navigate to previous responder textField/textView, otherwise NO.
    */
    var canGoPrevious: Bool {
        
        get {
            //Getting all responder view's.
            if let textFields = responderViews() {
                if let  textFieldRetain = _textFieldView {
                    
                    if contains(textFields, textFieldRetain) == true {
                        
                        //Getting index of current textField.
                        if let index = find(textFields, textFieldRetain) {

                            //If it is not first textField. then it's previous object canBecomeFirstResponder.
                            if index > 0 {
                                return true
                            }
                        }
                    }
                }
            }
            return false
        }
    }
    
    /**
    Returns YES if can navigate to next responder textField/textView, otherwise NO.
    */
    var canGoNext: Bool {
        
        get {
            //Getting all responder view's.
            if let textFields = responderViews() {
                if let  textFieldRetain = _textFieldView {
                    if contains(textFields, textFieldRetain) == true {
                        
                        //Getting index of current textField.
                        if let index = find(textFields, textFieldRetain) {
                            
                            //If it is not first textField. then it's previous object canBecomeFirstResponder.
                            if index < textFields.count-1 {
                                return true
                            }
                        }
                    }
                }
            }
            return false
        }
    }
    
    /**
    Navigate to previous responder textField/textView.
    */
    func goPrevious()-> Bool {
        
        //Getting all responder view's.
        if let  textFieldRetain = _textFieldView {
            if let textFields = responderViews() {
                if contains(textFields, textFieldRetain) == true {
                    
                    //Getting index of current textField.
                    if let index = find(textFields, textFieldRetain) {
                        
                        //If it is not first textField. then it's previous object becomeFirstResponder.
                        if index > 0 {
                            
                            let nextTextField = textFields[index-1]
                            
                            let isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                            
                            //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                            if isAcceptAsFirstResponder == false {
                                //If next field refuses to become first responder then restoring old textField as first responder.
                                textFieldRetain.becomeFirstResponder()
                                
                                _IQShowLog("Refuses to become first responder: \(nextTextField._IQDescription())")
                            }
                            
                            return isAcceptAsFirstResponder
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    /**
    Navigate to next responder textField/textView.
    */
    func goNext()-> Bool {

        //Getting all responder view's.
        if let  textFieldRetain = _textFieldView {
            if let textFields = responderViews() {
                if contains(textFields, textFieldRetain) == true {
                    
                    //Getting index of current textField.
                    if let index = find(textFields, textFieldRetain) {
                        //If it is not last textField. then it's next object becomeFirstResponder.
                        if index < textFields.count-1 {
                            
                            let nextTextField = textFields[index+1]
                            
                            let isAcceptAsFirstResponder = nextTextField.becomeFirstResponder()
                            
                            //  If it refuses then becoming previous textFieldView as first responder again.    (Bug ID: #96)
                            if isAcceptAsFirstResponder == false {
                                //If next field refuses to become first responder then restoring old textField as first responder.
                                textFieldRetain.becomeFirstResponder()
                                
                                _IQShowLog("Refuses to become first responder: \(nextTextField._IQDescription())")
                            }
                            
                            return isAcceptAsFirstResponder
                        }
                    }
                }
            }
        }

        return false
    }
    
    /**	previousAction. */
    func previousAction (_ segmentedControl : AnyObject?) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.current.playInputClick()
        }
        
        if canGoPrevious == true {
            
            if let textFieldRetain = _textFieldView {
                let isAcceptAsFirstResponder = goPrevious()
                
                if isAcceptAsFirstResponder && textFieldRetain.previousInvocation.target != nil && textFieldRetain.previousInvocation.selector != nil {
                    
                    UIApplication.shared.sendAction(textFieldRetain.previousInvocation.selector!, to: textFieldRetain.previousInvocation.target, from: textFieldRetain, for: UIEvent())
                }
            }
        }
    }
    
    /**	nextAction. */
    func nextAction (_ segmentedControl : AnyObject?) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.current.playInputClick()
        }
        
        if canGoNext == true {
            
            if let textFieldRetain = _textFieldView {
                let isAcceptAsFirstResponder = goNext()
                
                if isAcceptAsFirstResponder && textFieldRetain.nextInvocation.target != nil && textFieldRetain.nextInvocation.selector != nil {
                    
                    UIApplication.shared.sendAction(textFieldRetain.nextInvocation.selector!, to: textFieldRetain.nextInvocation.target, from: textFieldRetain, for: UIEvent())
                }
            }
        }
    }
    
    /**	doneAction. Resigning current textField. */
    func doneAction (_ barButton : IQBarButtonItem?) {
        
        //If user wants to play input Click sound.
        if shouldPlayInputClicks == true {
            //Play Input Click Sound.
            UIDevice.current.playInputClick()
        }
        
        if let textFieldRetain = _textFieldView {
            //Resign textFieldView.
            let isResignedFirstResponder = resignFirstResponder()
            
            if isResignedFirstResponder && textFieldRetain.doneInvocation.target != nil  && textFieldRetain.doneInvocation.selector != nil{
                
                UIApplication.shared.sendAction(textFieldRetain.doneInvocation.selector!, to: textFieldRetain.doneInvocation.target, from: textFieldRetain, for: UIEvent())
            }
        }
    }
    
    /** Resigning on tap gesture.   (Enhancement ID: #14)*/
    func tapRecognized(_ gesture: UITapGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizerState.ended {

            //Resigning currently responder textField.
            resignFirstResponder()
        }
    }
    
    /** Note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES. */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /** To not detect touch events in a subclass of UIControl, these may have added their own selector for specific work */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //  Should not recognize gesture if the clicked view is either UIControl or UINavigationBar(<Back button etc...)    (Bug ID: #145)
        return (touch.view is UIControl || touch.view is UINavigationBar) ? false : true
    }
    
    ///----------------------------
    /// MARK: UIScrollView handling
    ///----------------------------
    
    /**
    Restore scrollViewContentOffset when resigning from scrollView. Default is NO.
    */
    var shouldRestoreScrollViewContentOffset = false

    
    ///-----------------------
    /// MARK: UISound handling
    ///-----------------------

    /**
    If YES, then it plays inputClick sound on next/previous/done click.
    */
    var shouldPlayInputClicks = false
    
    
    ///---------------------------
    /// MARK: UIAnimation handling
    ///---------------------------

    /**
    If YES, then uses keyboard default animation curve style to move view, otherwise uses UIViewAnimationOptionCurveEaseInOut animation style. Default is YES.
    
    @warning Sometimes strange animations may be produced if uses default curve style animation in iOS 7 and changing the textFields very frequently.
    */
    var shouldAdoptDefaultKeyboardAnimation = true

    /**
    If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
    */
    var layoutIfNeededOnUpdate = false

    ///------------------------------------
    /// MARK: Class Level disabling methods
    ///------------------------------------
    
    /**
    Disable adjusting view in disabledClass
    
    @param disabledClass Class in which library should not adjust view to show textField.
    */
    func disableInViewControllerClass(_ disabledClass : AnyClass) {
        _disabledClasses.insert(NSStringFromClass(disabledClass))
    }
    
    /**
    Re-enable adjusting textField in disabledClass
    
    @param disabledClass Class in which library should re-enable adjust view to show textField.
    */
    func removeDisableInViewControllerClass(_ disabledClass : AnyClass) {
        _disabledClasses.remove(NSStringFromClass(disabledClass))
    }
    
    /**
    Returns YES if ViewController class is disabled for library, otherwise returns NO.
    
    @param disabledClass Class which is to check for it's disability.
    */
    func isDisableInViewControllerClass(_ disabledClass : AnyClass) -> Bool {
        return contains(_disabledClasses, NSStringFromClass(disabledClass))
    }
    
    /**
    Disable automatic toolbar creation in in toolbarDisabledClass
    
    @param toolbarDisabledClass Class in which library should not add toolbar over textField.
    */
    func disableToolbarInViewControllerClass(_ toolbarDisabledClass : AnyClass) {
        _disabledToolbarClasses.insert(NSStringFromClass(toolbarDisabledClass))
    }
    
    /**
    Re-enable automatic toolbar creation in in toolbarDisabledClass
    
    @param toolbarDisabledClass Class in which library should re-enable automatic toolbar creation over textField.
    */
    func removeDisableToolbarInViewControllerClass(_ toolbarDisabledClass : AnyClass) {
        _disabledToolbarClasses.remove(NSStringFromClass(toolbarDisabledClass))
    }
    
    /**
    Returns YES if toolbar is disabled in ViewController class, otherwise returns NO.
    
    @param toolbarDisabledClass Class which is to check for toolbar disability.
    */
    func isDisableToolbarInViewControllerClass(_ toolbarDisabledClass : AnyClass) -> Bool {
        return contains(_disabledToolbarClasses, NSStringFromClass(toolbarDisabledClass))
    }
    
    /**
    Consider provided customView class as superView of all inner textField for calculating next/previous button logic.
    
    @param toolbarPreviousNextConsideredClass Custom UIView subclass Class in which library should consider all inner textField as siblings and add next/previous accordingly.
    */
    func considerToolbarPreviousNextInViewClass(_ toolbarPreviousNextConsideredClass : AnyClass) {
        _toolbarPreviousNextConsideredClass.insert(NSStringFromClass(toolbarPreviousNextConsideredClass))
    }
    
    /**
    Remove Consideration for provided customView class as superView of all inner textField for calculating next/previous button logic.
    
    @param toolbarPreviousNextConsideredClass Custom UIView subclass Class in which library should remove consideration for all inner textField as superView.
    */
    func removeConsiderToolbarPreviousNextInViewClass(_ toolbarPreviousNextConsideredClass : AnyClass) {
        _toolbarPreviousNextConsideredClass.remove(NSStringFromClass(toolbarPreviousNextConsideredClass))
    }
    
    /**
    Returns YES if inner hierarchy is considered for previous/next in class, otherwise returns NO.
    
    @param toolbarPreviousNextConsideredClass Class which is to check for previous next consideration
    */
    func isConsiderToolbarPreviousNextInViewClass(_ toolbarPreviousNextConsideredClass : AnyClass) -> Bool {
        return contains(_toolbarPreviousNextConsideredClass, NSStringFromClass(toolbarPreviousNextConsideredClass))
    }


    /**************************************************************************************/
    ///------------------------
    /// MARK: Private variables
    ///------------------------

    /*******************************************/

    /** To save UITextField/UITextView object voa textField/textView notifications. */
    fileprivate weak var    _textFieldView: UIView?
    
    /** used with canAdjustTextView boolean. */
    fileprivate var         _textFieldViewIntialFrame = CGRect.zero
    
    /** To save rootViewController.view.frame. */
    fileprivate var         _topViewBeginRect = CGRect.zero
    
    /** To save rootViewController */
    fileprivate weak var    _rootViewController: UIViewController?
    
    /** To save topBottomLayoutConstraint original constant */
    fileprivate var         _layoutGuideConstraintInitialConstant: CGFloat  = 0.25

    /*******************************************/

    /** Variable to save lastScrollView that was scrolled. */
    fileprivate weak var    _lastScrollView: UIScrollView?
    
    /** LastScrollView's initial contentOffset. */
    fileprivate var         _startingContentOffset = CGPoint.zero
    
    /** LastScrollView's initial scrollIndicatorInsets. */
    fileprivate var         _startingScrollIndicatorInsets = UIEdgeInsets.zero
    
    /** LastScrollView's initial contentInsets. */
    fileprivate var         _startingContentInsets = UIEdgeInsets.zero
    
    /*******************************************/

    /** To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    fileprivate var         _kbShowNotification: Notification?
    
    /** To save keyboard size. */
    fileprivate var         _kbSize = CGSize.zero
    
    /** To save keyboard animation duration. */
    fileprivate var         _animationDuration = 0.25
    
    /** To mimic the keyboard animation */
    fileprivate var         _animationCurve = UIViewAnimationOptions.curveEaseOut
    
    /*******************************************/

    /** TapGesture to resign keyboard on view's touch. */
    fileprivate var         _tapGesture: UITapGestureRecognizer!
    
    /*******************************************/
    
    /** Default toolbar tintColor to be used within the project. Default is black. */
    fileprivate var         _defaultToolbarTintColor = UIColor.black

    /*******************************************/
    
    /** Set of restricted classes for library */
    fileprivate var         _disabledClasses  = Set<String>()
    
    /** Set of restricted classes for adding toolbar */
    fileprivate var         _disabledToolbarClasses  = Set<String>()
    
    /** Set of permitted classes to add all inner textField as siblings */
    fileprivate var         _toolbarPreviousNextConsideredClass  = Set<String>()
 
    /*******************************************/

    fileprivate struct flags {
        /** used with canAdjustTextView to detect a textFieldView frame is changes or not. (Bug ID: #92)*/
        var isTextFieldViewFrameChanged = false
        /** Boolean to maintain keyboard is showing or it is hide. To solve rootViewController.view.frame calculations. */
        var isKeyboardShowing = false
    }
    
    /** Private flags to use within the project */
    fileprivate var _keyboardManagerFlags = flags(isTextFieldViewFrameChanged: false, isKeyboardShowing: false)

    /** To use with keyboardDistanceFromTextField. */
    fileprivate var         _privateKeyboardDistanceFromTextField: CGFloat = 10.0
    
    /**************************************************************************************/
    
    ///--------------------------------------
    /// MARK: Initialization/Deinitialization
    ///--------------------------------------
    
    /*  Singleton Object Initialization. */
    override init() {
        
        super.init()

        //  Registering for keyboard notification.
        NotificationCenter.default.addObserver(self, selector: #selector(IQKeyboardManager.keyboardWillShow(_:)),                name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IQKeyboardManager.keyboardWillHide(_:)),                name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IQKeyboardManager.keyboardDidHide(_:)),                name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        //  Registering for textField notification.
        NotificationCenter.default.addObserver(self, selector: #selector(IQKeyboardManager.textFieldViewDidBeginEditing(_:)),    name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IQKeyboardManager.textFieldViewDidEndEditing(_:)),      name: NSNotification.Name.UITextFieldTextDidEndEditing, object: nil)
        
        //  Registering for textView notification.
        NotificationCenter.default.addObserver(self, selector: #selector(IQKeyboardManager.textFieldViewDidBeginEditing(_:)),    name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IQKeyboardManager.textFieldViewDidEndEditing(_:)),      name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IQKeyboardManager.textFieldViewDidChange(_:)),          name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        
        //  Registering for orientation changes notification
        NotificationCenter.default.addObserver(self, selector: #selector(IQKeyboardManager.willChangeStatusBarOrientation(_:)),          name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)

        //Creating gesture for @shouldResignOnTouchOutside. (Enhancement ID: #14)
        _tapGesture = UITapGestureRecognizer(target: self, action: #selector(IQKeyboardManager.tapRecognized(_:)))
        _tapGesture.delegate = self
        _tapGesture.isEnabled = shouldResignOnTouchOutside
        
        disableInViewControllerClass(UITableViewController)
        considerToolbarPreviousNextInViewClass(UITableView)
        considerToolbarPreviousNextInViewClass(UICollectionView)
    }
    
    /** Override +load method to enable KeyboardManager when class loader load IQKeyboardManager. Enabling when app starts (No need to write any code) */
    /** It doesn't work on Swift 1.2 */
//    override class func load() {
//        super.load()
//        
//        //Enabling IQKeyboardManager.
//        IQKeyboardManager.sharedManager().enable = true
//    }
    
    deinit {
        //  Disable the keyboard manager.
        enable = false

        //Removing notification observers on dealloc.
        NotificationCenter.default.removeObserver(self)
    }
    
    /** Getting keyWindow. */
    fileprivate func keyWindow() -> UIWindow? {
        
        if let keyWindow = _textFieldView?.window {
            return keyWindow
        } else {
            
            struct Static {
                /** @abstract   Save keyWindow object for reuse.
                @discussion Sometimes [[UIApplication sharedApplication] keyWindow] is returning nil between the app.   */
                static var keyWindow : UIWindow?
            }
            

            /*  (Bug ID: #23, #25, #73)   */
            let originalKeyWindow = UIApplication.shared.keyWindow
            
            //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
            if originalKeyWindow != nil && (Static.keyWindow == nil || Static.keyWindow != originalKeyWindow) {
                Static.keyWindow = originalKeyWindow
            }

            //Return KeyWindow
            return Static.keyWindow
        }
    }

    ///-----------------------
    /// MARK: Helper Functions
    ///-----------------------
    
    /*  Helper function to manipulate RootViewController's frame with animation. */
    private func setRootViewFrame(_ frame: CGRect) {
        var frame = frame
        
        //  Getting topMost ViewController.
        var controller = _textFieldView?.topMostController()
        
        if controller == nil {
            controller = keyWindow()?.topMostController()
        }
        
        if let unwrappedController = controller {
            //frame size needs to be adjusted on iOS8 due to orientation structure changes.
            if IQ_IS_IOS8_OR_GREATER == true {
                frame.size = unwrappedController.view.frame.size
            }
            
            //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                
                //  Setting it's new frame
                unwrappedController.view.frame = frame
                self._IQShowLog("Set \(controller?._IQDescription()) frame to : \(frame)")
                
                //Animating content if needed (Bug ID: #204)
                if self.layoutIfNeededOnUpdate == true {
                    //Animating content (Bug ID: #160)
                    unwrappedController.view.setNeedsLayout()
                    unwrappedController.view.layoutIfNeeded()
                }
 
                
                }) { (animated:Bool) -> Void in}
        } else {  //  If can't get rootViewController then //printing warning to user.
            _IQShowLog("You must set UIWindow.rootViewController in your AppDelegate to work with IQKeyboardManager")
        }
    }

    /* Adjusting RootViewController's frame according to device orientation. */
    fileprivate func adjustFrame() {
        
        //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
        if _textFieldView == nil {
            return
        }
        
        let textFieldView = _textFieldView!

        _IQShowLog("****** \(#function) %@ started ******")

        //  Boolean to know keyboard is showing/hiding
        _keyboardManagerFlags.isKeyboardShowing = true
        
        //  Getting KeyWindow object.
        let optionalWindow = keyWindow()
        
        //  Getting RootViewController.  (Bug ID: #1, #4)
        var optionalRootController = _textFieldView?.topMostController()
        if optionalRootController == nil {
            optionalRootController = keyWindow()?.topMostController()
        }
        
        //  Converting Rectangle according to window bounds.
        let optionalTextFieldViewRect = textFieldView.superview?.convert(textFieldView.frame, to: optionalWindow)

        if optionalRootController == nil || optionalWindow == nil || optionalTextFieldViewRect == nil {
            return
        }
        
        let rootController = optionalRootController!
        let window = optionalWindow!
        let textFieldViewRect = optionalTextFieldViewRect!
        
        //If it's iOS8 then we should do calculations according to portrait orientations.   //  (Bug ID: #64, #66)
        let interfaceOrientation = (IQ_IS_IOS8_OR_GREATER) ? UIInterfaceOrientation.portrait : rootController.interfaceOrientation

        //  Getting RootViewRect.
        var rootViewRect = rootController.view.frame
        //Getting statusBarFrame
        var topLayoutGuide : CGFloat = 0
        //Maintain keyboardDistanceFromTextField
        let newKeyboardDistanceFromTextField = (textFieldView.keyboardDistanceFromTextField == kIQUseDefaultKeyboardDistance) ? keyboardDistanceFromTextField : textFieldView.keyboardDistanceFromTextField
        var kbSize = _kbSize;
        
       let statusBarFrame = UIApplication.shared.statusBarFrame
        
        switch interfaceOrientation {
        case UIInterfaceOrientation.landscapeLeft, UIInterfaceOrientation.landscapeRight:
            topLayoutGuide = statusBarFrame.width
            kbSize.width += newKeyboardDistanceFromTextField
        case UIInterfaceOrientation.portrait, UIInterfaceOrientation.portraitUpsideDown:
            topLayoutGuide = statusBarFrame.height
            kbSize.height += newKeyboardDistanceFromTextField
        default:    break
        }

        var move : CGFloat = 0.0
        //  Move positive = textField is hidden.
        //  Move negative = textField is showing.
        
        //  Calculating move position. Common for both normal and special cases.
        switch interfaceOrientation {
        case UIInterfaceOrientation.landscapeLeft:
            move = min(textFieldViewRect.minX-(topLayoutGuide+5), textFieldViewRect.maxX-(window.frame.width-kbSize.width))
        case UIInterfaceOrientation.landscapeRight:
            move = min(window.frame.width-textFieldViewRect.maxX-(topLayoutGuide+5), kbSize.width-textFieldViewRect.minX)
        case UIInterfaceOrientation.portrait:
            move = min(textFieldViewRect.minY-(topLayoutGuide+5), textFieldViewRect.maxY-(window.frame.height-kbSize.height))
        case UIInterfaceOrientation.portraitUpsideDown:
            move = min(window.frame.height-textFieldViewRect.maxY-(topLayoutGuide+5), kbSize.height-textFieldViewRect.minY)
        default:    break
        }
        
        _IQShowLog("Need to move: \(move)")

        //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
        let superScrollView = textFieldView.superviewOfClassType(UIScrollView) as? UIScrollView
        
        //If there was a lastScrollView.    //  (Bug ID: #34)
        if let lastScrollView = _lastScrollView {
            //If we can't find current superScrollView, then setting lastScrollView to it's original form.
            if superScrollView == nil {
                
                _IQShowLog("Restoring \(lastScrollView._IQDescription()) contentInset to : \(_startingContentInsets) and contentOffset to : \(_startingContentOffset)")

                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                    
                    lastScrollView.contentInset = self._startingContentInsets
                    lastScrollView.scrollIndicatorInsets = self._startingScrollIndicatorInsets
                    }) { (animated:Bool) -> Void in }
                
                if shouldRestoreScrollViewContentOffset == true {
                    lastScrollView.setContentOffset(_startingContentOffset, animated: true)
                }
                
                _startingContentInsets = UIEdgeInsets.zero
                _startingScrollIndicatorInsets = UIEdgeInsets.zero
                _startingContentOffset = CGPoint.zero
                _lastScrollView = nil
            } else if superScrollView != lastScrollView {     //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
                
                _IQShowLog("Restoring \(lastScrollView._IQDescription()) contentInset to : \(_startingContentInsets) and contentOffset to : \(_startingContentOffset)")
                
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                    
                    lastScrollView.contentInset = self._startingContentInsets
                    lastScrollView.scrollIndicatorInsets = self._startingScrollIndicatorInsets
                    }) { (animated:Bool) -> Void in }
                
                if shouldRestoreScrollViewContentOffset == true {
                    lastScrollView.setContentOffset(_startingContentOffset, animated: true)
                }

                _lastScrollView = superScrollView
                _startingContentInsets = superScrollView!.contentInset
                _startingScrollIndicatorInsets = superScrollView!.scrollIndicatorInsets
                _startingContentOffset = superScrollView!.contentOffset
                
                _IQShowLog("Saving New \(lastScrollView._IQDescription()) contentInset : \(_startingContentInsets) and contentOffset : \(_startingContentOffset)")
            }
            //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing, going ahead
        } else if let unwrappedSuperScrollView = superScrollView {    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
            _lastScrollView = unwrappedSuperScrollView
            _startingContentInsets = unwrappedSuperScrollView.contentInset
            _startingScrollIndicatorInsets = unwrappedSuperScrollView.scrollIndicatorInsets
            _startingContentOffset = unwrappedSuperScrollView.contentOffset

            _IQShowLog("Saving \(unwrappedSuperScrollView._IQDescription()) contentInset : \(_startingContentInsets) and contentOffset : \(_startingContentOffset)")
        }
        
        //  Special case for ScrollView.
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if let lastScrollView = _lastScrollView {
            //Saving
            var lastView = textFieldView
            var superScrollView = _lastScrollView
            
            while let scrollView = superScrollView {
                
                //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
                if move > 0 ? (move > (-scrollView.contentOffset.y - scrollView.contentInset.top)) : scrollView.contentOffset.y>0 {
                    
                    //Getting lastViewRect.
                    if let lastViewRect = lastView.superview?.convert(lastView.frame, to: scrollView) {
                        
                        //Calculating the expected Y offset from move and scrollView's contentOffset.
                        var shouldOffsetY = scrollView.contentOffset.y - min(scrollView.contentOffset.y,-move)
                        
                        //Rearranging the expected Y offset according to the view.
                        shouldOffsetY = min(shouldOffsetY, lastViewRect.origin.y /*-5*/)   //-5 is for good UI.//Commenting -5 (Bug ID: #69)

                        //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                        //[superScrollView superviewOfClassType:[UIScrollView class]] == nil    If processing scrollView is last scrollView in upper hierarchy (there is no other scrollView upper hierrchy.)
                        //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                        //shouldOffsetY >= 0     shouldOffsetY must be greater than in order to keep distance from navigationBar (Bug ID: #92)
                        if textFieldView is UITextView == true && scrollView.superviewOfClassType(UIScrollView) == nil && shouldOffsetY >= 0 {
                            var maintainTopLayout : CGFloat = 0
                            
                            if let navigationBarFrame = textFieldView.viewController()?.navigationController?.navigationBar.frame {
                                maintainTopLayout = navigationBarFrame.maxY
                            }
                            
                            maintainTopLayout += 10.0 //For good UI
                            
                            //  Converting Rectangle according to window bounds.
                            if let currentTextFieldViewRect = textFieldView.superview?.convert(textFieldView.frame, to: window) {
                                var expectedFixDistance = shouldOffsetY
                                
                                //Calculating expected fix distance which needs to be managed from navigation bar
                                switch interfaceOrientation {
                                case UIInterfaceOrientation.landscapeLeft:
                                    expectedFixDistance = currentTextFieldViewRect.minX - maintainTopLayout
                                case UIInterfaceOrientation.landscapeRight:
                                    expectedFixDistance = (window.frame.width-currentTextFieldViewRect.maxX) - maintainTopLayout
                                case UIInterfaceOrientation.portrait:
                                    expectedFixDistance = currentTextFieldViewRect.minY - maintainTopLayout
                                case UIInterfaceOrientation.portraitUpsideDown:
                                    expectedFixDistance = (window.frame.height-currentTextFieldViewRect.maxY) - maintainTopLayout
                                default:    break
                                }
                                
                                //Now if expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance) is lower than current shouldOffsetY, which means we're in a position where navigationBar up and hide, then reducing shouldOffsetY with expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance)
                                shouldOffsetY = min(shouldOffsetY, scrollView.contentOffset.y + expectedFixDistance)

                                //Setting move to 0 because now we don't want to move any view anymore (All will be managed by our contentInset logic.
                                move = 0
                            }
                            else {
                                //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                                move -= (shouldOffsetY-scrollView.contentOffset.y)
                            }
                        }
                        else
                        {
                            //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                            move -= (shouldOffsetY-scrollView.contentOffset.y)
                        }
                        
                        //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                        UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                        
                            self._IQShowLog("Adjusting \(scrollView.contentOffset.y-shouldOffsetY) to \(scrollView._IQDescription()) ContentOffset")
                            
                            self._IQShowLog("Remaining Move: \(move)")
                            
                            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, shouldOffsetY)
                            }) { (animated:Bool) -> Void in }
                    }
                    
                    //  Getting next lastView & superScrollView.
                    lastView = scrollView
                    superScrollView = lastView.superviewOfClassType(UIScrollView) as? UIScrollView
                } else {
                    break
                }
            }
            
            //Updating contentInset
            if let lastScrollViewRect = lastScrollView.superview?.convert(lastScrollView.frame, to: window) {
                
                var bottom : CGFloat = 0.0
                
                switch interfaceOrientation {
                case UIInterfaceOrientation.landscapeLeft:
                    bottom = kbSize.width-(window.frame.width-lastScrollViewRect.maxX)
                case UIInterfaceOrientation.landscapeRight:
                    bottom = kbSize.width-lastScrollViewRect.minX
                case UIInterfaceOrientation.portrait:
                    bottom = kbSize.height-(window.frame.height-lastScrollViewRect.maxY)
                case UIInterfaceOrientation.portraitUpsideDown:
                    bottom = kbSize.height-lastScrollViewRect.minY
                default:    break
                }
                
                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                var movedInsets = lastScrollView.contentInset
                
                movedInsets.bottom = max(_startingContentInsets.bottom, bottom)
                
                _IQShowLog("\(lastScrollView._IQDescription()) old ContentInset : \(lastScrollView.contentInset)")
                
                //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                    lastScrollView.contentInset = movedInsets

                    var newInset = lastScrollView.scrollIndicatorInsets
                    newInset.bottom = movedInsets.bottom - 10
                    lastScrollView.scrollIndicatorInsets = newInset

                    }) { (animated:Bool) -> Void in }

                //Maintaining contentSize
                if lastScrollView.contentSize.height < lastScrollView.frame.size.height {
                    var contentSize = lastScrollView.contentSize
                    contentSize.height = lastScrollView.frame.size.height
                    lastScrollView.contentSize = contentSize
                }
                
                _IQShowLog("\(lastScrollView._IQDescription()) new ContentInset : \(lastScrollView.contentInset)")
            }
        }
        //Going ahead. No else if.
        
        //Special case for UITextView(Readjusting the move variable when textView hight is too big to fit on screen)
        //_canAdjustTextView    If we have permission to adjust the textView, then let's do it on behalf of user  (Enhancement ID: #15)
        //_lastScrollView       If not having inside any scrollView, (now contentInset manages the full screen textView.
        //[_textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
        //_isTextFieldViewFrameChanged  If frame is not change by library in past  (Bug ID: #92)
        if canAdjustTextView == true && _lastScrollView == nil && textFieldView is UITextView == true && _keyboardManagerFlags.isTextFieldViewFrameChanged == false {
            var textViewHeight = textFieldView.frame.height
 
            switch interfaceOrientation {
            case UIInterfaceOrientation.landscapeLeft, UIInterfaceOrientation.landscapeRight:
                textViewHeight = min(textViewHeight, (window.frame.width-kbSize.width-(topLayoutGuide+5)))
            case UIInterfaceOrientation.portrait, UIInterfaceOrientation.portraitUpsideDown:
                textViewHeight = min(textViewHeight, (window.frame.height-kbSize.height-(topLayoutGuide+5)))
            default:    break
            }
            
            UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve|UIViewAnimationOptions.BeginFromCurrentState), animations: { () -> Void in

                self._IQShowLog("\(textFieldView._IQDescription()) Old Frame : \(textFieldView.frame)")

                var textFieldViewRect = textFieldView.frame
                textFieldViewRect.size.height = textViewHeight
                textFieldView.frame = textFieldViewRect
                self._keyboardManagerFlags.isTextFieldViewFrameChanged = true

                self._IQShowLog("\(textFieldView._IQDescription()) New Frame : \(textFieldView.frame)")

                }, completion: { (finished) -> Void in })
        }

        var hasDoneTweakLayoutGuide = false
        
        if let viewController = textFieldView.viewController() {
            
            if let constraint = viewController.IQLayoutGuideConstraint {
                
                var layoutGuide : UILayoutSupport?
                if let itemLayoutGuide = constraint.firstItem as? UILayoutSupport {
                    layoutGuide = itemLayoutGuide
                } else if let itemLayoutGuide = constraint.secondItem as? UILayoutSupport {
                    layoutGuide = itemLayoutGuide
                }
                
                if let itemLayoutGuide : UILayoutSupport = layoutGuide {
                    
                    if (itemLayoutGuide === viewController.topLayoutGuide)    //If topLayoutGuide constraint
                    {
                        let constant = min(_layoutGuideConstraintInitialConstant, constraint.constant-move);
                        
                        UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve|UIViewAnimationOptions.BeginFromCurrentState), animations: { () -> Void in
                            
                            constraint.constant = constant;
                            self._rootViewController?.view.setNeedsLayout()
                            self._rootViewController?.view.layoutIfNeeded()
                            
                            }, completion: { (finished) -> Void in })
                        
                        hasDoneTweakLayoutGuide = true
                    }
                    else if (itemLayoutGuide === viewController.bottomLayoutGuide)    //If bottomLayoutGuice constraint
                    {
                        let constant = max(_layoutGuideConstraintInitialConstant, constraint.constant+move);
                        
                        UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve|UIViewAnimationOptions.BeginFromCurrentState), animations: { () -> Void in
                            
                            constraint.constant = constant;
                            self._rootViewController?.view.setNeedsLayout()
                            self._rootViewController?.view.layoutIfNeeded()
                            
                            }, completion: { (finished) -> Void in })

                        hasDoneTweakLayoutGuide = true
                    }
                }
            }
        }
        
        //If not constraint
        if hasDoneTweakLayoutGuide == false {
            
            //  Special case for iPad modalPresentationStyle.
            if rootController.modalPresentationStyle == UIModalPresentationStyle.formSheet || rootController.modalPresentationStyle == UIModalPresentationStyle.pageSheet {
                
                _IQShowLog("Found Special case for Model Presentation Style: \(rootController.modalPresentationStyle)")
                
                //  +Positive or zero.
                if move >= 0 {
                    // We should only manipulate y.
                    rootViewRect.origin.y -= move
                    
                    //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                    if preventShowingBottomBlankSpace == true {
                        var minimumY: CGFloat = 0
                        
                        switch interfaceOrientation {
                        case UIInterfaceOrientation.landscapeLeft, UIInterfaceOrientation.landscapeRight:
                            minimumY = window.frame.width-rootViewRect.size.height-topLayoutGuide-(kbSize.width-newKeyboardDistanceFromTextField)
                        case UIInterfaceOrientation.portrait, UIInterfaceOrientation.portraitUpsideDown:
                            minimumY = (window.frame.height-rootViewRect.size.height-topLayoutGuide)/2-(kbSize.height-newKeyboardDistanceFromTextField)
                        default:    break
                        }
                        
                        rootViewRect.origin.y = max(rootViewRect.minY, minimumY)
                    }
                    
                    _IQShowLog("Moving Upward")
                    //  Setting adjusted rootViewRect
                    setRootViewFrame(rootViewRect)
                } else {  //  -Negative
                    //  Calculating disturbed distance. Pull Request #3
                    let disturbDistance = rootViewRect.minY-_topViewBeginRect.minY
                    
                    //  disturbDistance Negative = frame disturbed.
                    //  disturbDistance positive = frame not disturbed.
                    if disturbDistance < 0 {
                        // We should only manipulate y.
                        rootViewRect.origin.y -= max(move, disturbDistance)
                        
                        _IQShowLog("Moving Downward")
                        //  Setting adjusted rootViewRect
                        setRootViewFrame(rootViewRect)
                    }
                }
            } else {  //If presentation style is neither UIModalPresentationFormSheet nor UIModalPresentationPageSheet then going ahead.(General case)
                //  +Positive or zero.
                if move >= 0 {
                    
                    switch interfaceOrientation {
                    case UIInterfaceOrientation.landscapeLeft:       rootViewRect.origin.x -= move
                    case UIInterfaceOrientation.landscapeRight:      rootViewRect.origin.x += move
                    case UIInterfaceOrientation.portrait:            rootViewRect.origin.y -= move
                    case UIInterfaceOrientation.portraitUpsideDown:  rootViewRect.origin.y += move
                    default:    break
                    }

                    //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                    if preventShowingBottomBlankSpace == true {
                        
                        switch interfaceOrientation {
                        case UIInterfaceOrientation.landscapeLeft:
                            rootViewRect.origin.x = max(rootViewRect.origin.x, min(0, -kbSize.width+newKeyboardDistanceFromTextField))
                        case UIInterfaceOrientation.landscapeRight:
                            rootViewRect.origin.x = min(rootViewRect.origin.x, +kbSize.width-newKeyboardDistanceFromTextField)
                        case UIInterfaceOrientation.portrait:
                            rootViewRect.origin.y = max(rootViewRect.origin.y, min(0, -kbSize.height+newKeyboardDistanceFromTextField))
                        case UIInterfaceOrientation.portraitUpsideDown:
                            rootViewRect.origin.y = min(rootViewRect.origin.y, +kbSize.height-newKeyboardDistanceFromTextField)
                        default:    break
                        }
                    }
                    
                    _IQShowLog("Moving Upward")
                    //  Setting adjusted rootViewRect
                    setRootViewFrame(rootViewRect)
                } else {  //  -Negative
                    var disturbDistance : CGFloat = 0
                    
                    switch interfaceOrientation {
                    case UIInterfaceOrientation.landscapeLeft:
                        disturbDistance = rootViewRect.minX-_topViewBeginRect.minX
                    case UIInterfaceOrientation.landscapeRight:
                        disturbDistance = _topViewBeginRect.minX-rootViewRect.minX
                    case UIInterfaceOrientation.portrait:
                        disturbDistance = rootViewRect.minY-_topViewBeginRect.minY
                    case UIInterfaceOrientation.portraitUpsideDown:
                        disturbDistance = _topViewBeginRect.minY-rootViewRect.minY
                    default:    break
                    }
                    
                    //  disturbDistance Negative = frame disturbed.
                    //  disturbDistance positive = frame not disturbed.
                    if disturbDistance < 0 {
                        
                        switch interfaceOrientation {
                        case UIInterfaceOrientation.landscapeLeft:       rootViewRect.origin.x -= max(move, disturbDistance)
                        case UIInterfaceOrientation.landscapeRight:      rootViewRect.origin.x += max(move, disturbDistance)
                        case UIInterfaceOrientation.portrait:            rootViewRect.origin.y -= max(move, disturbDistance)
                        case UIInterfaceOrientation.portraitUpsideDown:  rootViewRect.origin.y += max(move, disturbDistance)
                        default:    break
                        }
                        
                        _IQShowLog("Moving Downward")
                        //  Setting adjusted rootViewRect
                        //  Setting adjusted rootViewRect
                        setRootViewFrame(rootViewRect)
                    }
                }
            }
        }

        _IQShowLog("****** \(#function) ended ******")
    }
    
    ///-------------------------------
    /// MARK: UIKeyboard Notifications
    ///-------------------------------

    /*  UIKeyboardWillShowNotification. */
    func keyboardWillShow(_ notification : Notification?) -> Void {
        
        _kbShowNotification = notification

        if enable == false {
            return
        }
        
        _IQShowLog("****** \(#function) started ******")

        //Due to orientation callback we need to resave it's original frame.    //  (Bug ID: #46)
        //Added _isTextFieldViewFrameChanged check. Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed. (Bug ID: #92)
        if _keyboardManagerFlags.isTextFieldViewFrameChanged == false && _textFieldView != nil {
            if let textFieldView = _textFieldView {
                _textFieldViewIntialFrame = textFieldView.frame
                _IQShowLog("Saving \(textFieldView._IQDescription()) Initial frame : \(_textFieldViewIntialFrame)")
            }
        }

        //  (Bug ID: #5)
        if _topViewBeginRect.equalTo(CGRect.zero) == true {
            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            var rootController = _textFieldView?.topMostController()
            if rootController == nil {
                rootController = keyWindow()?.topMostController()
            }
            
            if let unwrappedRootController = rootController {
                _topViewBeginRect = unwrappedRootController.view.frame
                _IQShowLog("Saving \(unwrappedRootController._IQDescription()) beginning Frame: \(_topViewBeginRect)")
            } else {
                _topViewBeginRect = CGRect.zero
            }
        }

        let oldKBSize = _kbSize

        if let info = notification?.userInfo {
            
            if shouldAdoptDefaultKeyboardAnimation {

                //  Getting keyboard animation.
                if let curve = (info[UIKeyboardAnimationCurveUserInfoKey] as AnyObject).uintValue {
                    _animationCurve = UIViewAnimationOptions(rawValue: curve)
                }
            } else {
                _animationCurve = UIViewAnimationOptions.curveEaseOut
            }
            
            //  Getting keyboard animation duration
            if let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                
                //Saving animation duration
                if duration != 0.0 {
                    _animationDuration = duration
                }
            }
            
            //  Getting UIKeyboardSize.
            if let kbFrame = (info[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
                _kbSize = kbFrame.size
                
                _IQShowLog("UIKeyboard Size : \(_kbSize)")
            }
        }
        
        //  Getting topMost ViewController.
        var topMostController = _textFieldView?.topMostController()
        
        if topMostController == nil {
            topMostController = keyWindow()?.topMostController()
        }

        //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
        if _kbSize.equalTo(oldKBSize) == false {
            
            //If _textFieldView is inside UITableViewController then let UITableViewController to handle it (Bug ID: #37) (Bug ID: #76) See note:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
            
            if _textFieldView != nil && _textFieldView?.isAlertViewTextField() == false {
                
                //Getting textField viewController
                if let textFieldViewController = _textFieldView?.viewController() {
                    
                    var shouldIgnore = false
                    
                    for disabledClassString in _disabledClasses {
                        
                        //If viewController is kind of disabled viewController class, then ignoring to adjust view.
                        if textFieldViewController.isKindOfClass((NSClassFromString(disabledClassString))) {
                            shouldIgnore = true
                            break
                        }
                    }
                    
                    //If shouldn't ignore.
                    if shouldIgnore == false  {
                        //  keyboard is already showing. adjust frame.
                        adjustFrame()
                    }
                }
            }
        }
        
        _IQShowLog("****** \(#function) ended ******")
    }
    
    /*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
    func keyboardWillHide(_ notification : Notification?) -> Void {
        
        //If it's not a fake notification generated by [self setEnable:NO].
        if notification != nil {
            _kbShowNotification = nil
        }
        
        //If not enabled then do nothing.
        if enable == false {
            return
        }
        
        _IQShowLog("****** \(#function) started ******")

        //Commented due to #56. Added all the conditions below to handle UIWebView's textFields.    (Bug ID: #56)
        //  We are unable to get textField object while keyboard showing on UIWebView's textField.  (Bug ID: #11)
        //    if (_textFieldView == nil)   return

        //  Boolean to know keyboard is showing/hiding
        _keyboardManagerFlags.isKeyboardShowing = false
        
        let info : [AnyHashable: Any]? = notification?.userInfo
        
        //  Getting keyboard animation duration
        if let duration =  (info?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            if duration != 0 {
                //  Setitng keyboard animation duration
                _animationDuration = duration
            }
        }
        
        //Restoring the contentOffset of the lastScrollView
        if let lastScrollView = _lastScrollView {
            
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                
                lastScrollView.contentInset = self._startingContentInsets
                lastScrollView.scrollIndicatorInsets = self._startingScrollIndicatorInsets
                
                if self.shouldRestoreScrollViewContentOffset == true {
                    lastScrollView.contentOffset = self._startingContentOffset
                }
                
                self._IQShowLog("Restoring \(lastScrollView._IQDescription()) contentInset to : \(self._startingContentInsets) and contentOffset to : \(self._startingContentOffset)")

                // TODO: restore scrollView state
                // This is temporary solution. Have to implement the save and restore scrollView state
                var superScrollView = lastScrollView
                
                while let scrollView = superScrollView.superviewOfClassType(UIScrollView) as? UIScrollView {

                    let contentSize = CGSizeMake(max(scrollView.contentSize.width, CGRectGetWidth(scrollView.frame)), max(scrollView.contentSize.height, CGRectGetHeight(scrollView.frame)))
                    
                    let minimumY = contentSize.height - CGRectGetHeight(scrollView.frame)
                    
                    if minimumY < scrollView.contentOffset.y {
                        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, minimumY)
                        
                        self._IQShowLog("Restoring \(scrollView._IQDescription()) contentOffset to : \(self._startingContentOffset)")
                    }
                    
                    superScrollView = scrollView
                }
                }) { (finished) -> Void in }
        }
        
        //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
        if _topViewBeginRect.equalTo(CGRect.zero) == false {
            
            if let rootViewController = _rootViewController {
                
                //frame size needs to be adjusted on iOS8 due to orientation API changes.
                if IQ_IS_IOS8_OR_GREATER == true {
                    _topViewBeginRect.size = rootViewController.view.frame.size
                }
                
                //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                    
                    var hasDoneTweakLayoutGuide = false
                    
                    if let viewController = self._textFieldView?.viewController() {
                        
                        if let constraint = viewController.IQLayoutGuideConstraint {
                            
                            var layoutGuide : UILayoutSupport?
                            if let itemLayoutGuide = constraint.firstItem as? UILayoutSupport {
                                layoutGuide = itemLayoutGuide
                            } else if let itemLayoutGuide = constraint.secondItem as? UILayoutSupport {
                                layoutGuide = itemLayoutGuide
                            }
                            
                            if let itemLayoutGuide : UILayoutSupport = layoutGuide {
                                
                                if (itemLayoutGuide === viewController.topLayoutGuide || itemLayoutGuide === viewController.bottomLayoutGuide)
                                {
                                    constraint.constant = self._layoutGuideConstraintInitialConstant
                                    rootViewController.view.setNeedsLayout()
                                    rootViewController.view.layoutIfNeeded()

                                    hasDoneTweakLayoutGuide = true
                                }
                            }
                        }
                    }
                    
                    if hasDoneTweakLayoutGuide == false {
                        self._IQShowLog("Restoring \(rootViewController._IQDescription()) frame to : \(self._topViewBeginRect)")
                        
                        //  Setting it's new frame
                        rootViewController.view.frame = self._topViewBeginRect
                        
                        //Animating content if needed (Bug ID: #204)
                        if self.layoutIfNeededOnUpdate == true {
                            //Animating content (Bug ID: #160)
                            rootViewController.view.setNeedsLayout()
                            rootViewController.view.layoutIfNeeded()
                        }
                    }
                    }) { (finished) -> Void in }
                
                _rootViewController = nil
            }
        }
        
        //Reset all values
        _lastScrollView = nil
        _kbSize = CGSize.zero
        _startingContentInsets = UIEdgeInsets.zero
        _startingScrollIndicatorInsets = UIEdgeInsets.zero
        _startingContentOffset = CGPoint.zero
        //    topViewBeginRect = CGRectZero    //Commented due to #82

        _IQShowLog("****** \(#function) ended ******")
    }

    func keyboardDidHide(_ notification:Notification) {

        _IQShowLog("****** \(#function) started ******")
        
        _topViewBeginRect = CGRect.zero

        _IQShowLog("****** \(#function) ended ******")
    }
    
    ///-------------------------------------------
    /// MARK: UITextField/UITextView Notifications
    ///-------------------------------------------

    /**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
    func textFieldViewDidBeginEditing(_ notification:Notification) {

        _IQShowLog("****** \(#function) started ******")

        //  Getting object
        _textFieldView = notification.object as? UIView
        
        if overrideKeyboardAppearance == true {
            
            if let textFieldView = _textFieldView as? UITextField {
                //If keyboard appearance is not like the provided appearance
                if textFieldView.keyboardAppearance != keyboardAppearance {
                    //Setting textField keyboard appearance and reloading inputViews.
                    textFieldView.keyboardAppearance = keyboardAppearance
                    textFieldView.reloadInputViews()
                }
            } else if  let textFieldView = _textFieldView as? UITextView {
                //If keyboard appearance is not like the provided appearance
                if textFieldView.keyboardAppearance != keyboardAppearance {
                    //Setting textField keyboard appearance and reloading inputViews.
                    textFieldView.keyboardAppearance = keyboardAppearance
                    textFieldView.reloadInputViews()
                }
            }
        }
        
        // Saving textFieldView current frame to use it with canAdjustTextView if textViewFrame has already not been changed.
        //Added _isTextFieldViewFrameChanged check. (Bug ID: #92)
        if _keyboardManagerFlags.isTextFieldViewFrameChanged == false {
            if let textFieldView = _textFieldView {
                _textFieldViewIntialFrame = textFieldView.frame
                _IQShowLog("Saving \(textFieldView._IQDescription()) Initial frame : \(_textFieldViewIntialFrame)")
            }
        }
        
        //If autoToolbar enable, then add toolbar on all the UITextField/UITextView's if required.
        if enableAutoToolbar == true {

            _IQShowLog("adding UIToolbars if required")

            //UITextView special case. Keyboard Notification is firing before textView notification so we need to resign it first and then again set it as first responder to add toolbar on it.
            if _textFieldView is UITextView == true && _textFieldView?.inputAccessoryView == nil {
                
                UIView.animateWithDuration(0.00001, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in

                    self.addToolbarIfRequired()
                    
                    }, completion: { (finished) -> Void in

                        //RestoringTextView before reloading inputViews
                        if (self._keyboardManagerFlags.isTextFieldViewFrameChanged)
                        {
                            self._keyboardManagerFlags.isTextFieldViewFrameChanged = false;
                            
                            if let textFieldView = self._textFieldView {
                                textFieldView.frame = self._textFieldViewIntialFrame;
                            }
                        }

                        //On textView toolbar didn't appear on first time, so forcing textView to reload it's inputViews.
                        self._textFieldView?.reloadInputViews()
                })
            } else {
                //Adding toolbar
                addToolbarIfRequired()
            }
        }

        if enable == false {
            _IQShowLog("****** \(#function) ended ******")
            return
        }
        
        _textFieldView?.window?.addGestureRecognizer(_tapGesture)    //   (Enhancement ID: #14)

        if _keyboardManagerFlags.isKeyboardShowing == false {    //  (Bug ID: #5)

            //  keyboard is not showing(At the beginning only). We should save rootViewRect.
            if let constant = _textFieldView?.viewController()?.IQLayoutGuideConstraint?.constant {
                _layoutGuideConstraintInitialConstant = constant
            }

            _rootViewController = _textFieldView?.topMostController()
            if _rootViewController == nil {
                _rootViewController = keyWindow()?.topMostController()
            }

            if let rootViewController = _rootViewController {
                
                _topViewBeginRect = rootViewController.view.frame
                
                _IQShowLog("Saving \(rootViewController._IQDescription()) beginning frame : \(_topViewBeginRect)")
            }
        }
        
        //If _textFieldView is inside ignored responder then do nothing. (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/Library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html. If it is UIAlertView textField then do not affect anything (Bug ID: #70).
        if _textFieldView != nil && _textFieldView?.isAlertViewTextField() == false {

            //Getting textField viewController
            if let textFieldViewController = _textFieldView?.viewController() {
                
                var shouldIgnore = false
                
                for disabledClassString in _disabledClasses {
                    
                    //If viewController is kind of disabled viewController class, then ignoring to adjust view.
                    if textFieldViewController.isKindOfClass((NSClassFromString(disabledClassString))) {
                        shouldIgnore = true
                        break
                    }
                }
                
                //If shouldn't ignore.
                if shouldIgnore == false  {
                    //  keyboard is already showing. adjust frame.
                    adjustFrame()
                }
            }
        }

        _IQShowLog("****** \(#function) ended ******")
    }
    
    /**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
    func textFieldViewDidEndEditing(_ notification:Notification) {
        
        _IQShowLog("****** \(#function) started ******")

        //Removing gesture recognizer   (Enhancement ID: #14)
        _textFieldView?.window?.removeGestureRecognizer(_tapGesture)
        
        // We check if there's a change in original frame or not.
        if _keyboardManagerFlags.isTextFieldViewFrameChanged == true {
            UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                self._keyboardManagerFlags.isTextFieldViewFrameChanged = false
                
                self._IQShowLog("Restoring \(self._textFieldView?._IQDescription()) frame to : \(self._textFieldViewIntialFrame)")

                self._textFieldView?.frame = self._textFieldViewIntialFrame
                }, completion: { (finished) -> Void in })
        }
        
        //Setting object to nil
        _textFieldView = nil

        _IQShowLog("****** \(#function) ended ******")
    }

    /** UITextViewTextDidChangeNotificationBug,  fix for iOS 7.0.x - http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string */
    func textFieldViewDidChange(_ notification:Notification) {  //  (Bug ID: #18)
        
        if  shouldFixTextViewClip {
            let textView = notification.object as! UITextView
            
            let line = textView.caretRectForPosition(textView.selectedTextRange?.start)
            
            let overflow = line.maxY - (textView.contentOffset.y + (textView.bounds).height - textView.contentInset.bottom - textView.contentInset.top)
            
            //Added overflow conditions (Bug ID: 95)
            if overflow > 0.0 && overflow < CGFloat(FLT_MAX) {
                // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
                // Scroll caret to visible area
                var offset = textView.contentOffset
                offset.y += overflow + 7 // leave 7 pixels margin
                
                // Cannot animate with setContentOffset:animated: or caret will not appear
                UIView.animateWithDuration(_animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState|_animationCurve, animations: { () -> Void in
                    textView.contentOffset = offset
                    }, completion: { (finished) -> Void in })
            }
        }
    }

    ///------------------------------------------
    /// MARK: Interface Orientation Notifications
    ///------------------------------------------
    
    /**  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
    func willChangeStatusBarOrientation(_ notification:Notification) {
        
        _IQShowLog("****** \(#function) started ******")
        
        //If textFieldViewInitialRect is saved then restore it.(UITextView case @canAdjustTextView)
        if _keyboardManagerFlags.isTextFieldViewFrameChanged == true {
            if let textFieldView = _textFieldView {
                //Due to orientation callback we need to set it's original position.
                UIView.animateWithDuration(_animationDuration, delay: 0, options: (_animationCurve|UIViewAnimationOptions.BeginFromCurrentState), animations: { () -> Void in
                    self._keyboardManagerFlags.isTextFieldViewFrameChanged = false

                    self._IQShowLog("Restoring \(textFieldView._IQDescription()) frame to : \(self._textFieldViewIntialFrame)")
                    
                    //Setting textField to it's initial frame
                    textFieldView.frame = self._textFieldViewIntialFrame
                    
                    }, completion: { (finished) -> Void in })
            }
        }

        _IQShowLog("****** \(#function) ended ******")
    }
    
    ///------------------
    /// MARK: AutoToolbar
    ///------------------
    
    /**	Get all UITextField/UITextView siblings of textFieldView. */
    func responderViews()-> [UIView]? {
        
        var superConsideredView : UIView?

        //If find any consider responderView in it's upper hierarchy then will get deepResponderView.
        for disabledClassString in _toolbarPreviousNextConsideredClass {
            
                if _textFieldView?.superviewOfClassType(NSClassFromString(disabledClassString)) != nil {
                    break
                }
        }
    
    //If there is a superConsideredView in view's hierarchy, then fetching all it's subview that responds. No sorting for superConsideredView, it's by subView position.    (Enhancement ID: #22)
        if superConsideredView != nil {
            return superConsideredView?.deepResponderViews()
        } else {  //Otherwise fetching all the siblings
            
            if let textFields = _textFieldView?.responderSiblings() {
                
                //Sorting textFields according to behaviour
                switch toolbarManageBehaviour {
                    //If autoToolbar behaviour is bySubviews, then returning it.
                case IQAutoToolbarManageBehaviour.bySubviews:   return textFields
                    
                    //If autoToolbar behaviour is by tag, then sorting it according to tag property.
                case IQAutoToolbarManageBehaviour.byTag:    return textFields.sortedArrayByTag()
                    
                    //If autoToolbar behaviour is by tag, then sorting it according to tag property.
                case IQAutoToolbarManageBehaviour.byPosition:    return textFields.sortedArrayByPosition()
                }
            } else {
                return nil
            }
        }
    }
    
    /** Add toolbar if it is required to add on textFields and it's siblings. */
    fileprivate func addToolbarIfRequired() {
        
        if let textFieldViewController = _textFieldView?.viewController() {
            
            for disabledClassString in _disabledToolbarClasses {
                
                if textFieldViewController.isKindOfClass((NSClassFromString(disabledClassString))) {
                    
                    removeToolbarIfRequired()
                    return
                }
            }
        }
        
        //	Getting all the sibling textFields.
        if let siblings = responderViews() {
            
            //	If only one object is found, then adding only Done button.
            if siblings.count == 1 {
                let textField = siblings[0]
                
                //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Previous/Next/Done toolbar).
                if textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag {
                    
                    //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                    textField.addDoneOnKeyboardWithTarget(self, action: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)
                    textField.inputAccessoryView?.tag = kIQDoneButtonToolbarTag //  (Bug ID: #78)
                }
                
                if textField.inputAccessoryView is IQToolbar && textField.inputAccessoryView?.tag == kIQDoneButtonToolbarTag {
                    
                    let toolbar = textField.inputAccessoryView as! IQToolbar
                    
                    //  Setting toolbar to keyboard.
                    if let _textField = textField as? UITextField {

                        //Bar style according to keyboard appearance
                        switch _textField.keyboardAppearance {

                        case UIKeyboardAppearance.dark:
                            toolbar.barStyle = UIBarStyle.black
                            toolbar.tintColor = UIColor.white
                        default:
                            toolbar.barStyle = UIBarStyle.default
                            toolbar.tintColor = shouldToolbarUsesTextFieldTintColor ? _textField.tintColor : _defaultToolbarTintColor
                        }
                    } else if let _textView = textField as? UITextView {

                        //Bar style according to keyboard appearance
                        switch _textView.keyboardAppearance {
                            
                        case UIKeyboardAppearance.dark:
                            toolbar.barStyle = UIBarStyle.black
                            toolbar.tintColor = UIColor.white
                        default:
                            toolbar.barStyle = UIBarStyle.default
                            toolbar.tintColor = shouldToolbarUsesTextFieldTintColor ? _textView.tintColor : _defaultToolbarTintColor
                        }
                    }

                    //Setting toolbar title font.   //  (Enhancement ID: #30)
                    if shouldShowTextFieldPlaceholder == true && placeholderFont != nil {
                        
                        let toolbar = textField.inputAccessoryView as! IQToolbar

                        //Updating placeholder font to toolbar.     //(Bug ID: #148)
                        if let _textField = textField as? UITextField {
                            
                            if toolbar.title != _textField.placeholder {
                                toolbar.title = _textField.placeholder
                            }

                        } else if let _textView = textField as? IQTextView {
                            
                            if toolbar.title != _textView.placeholder {
                                toolbar.title = _textView.placeholder
                            }
                        }

                        //Setting toolbar title font.   //  (Enhancement ID: #30)
                        if placeholderFont != nil {
                            toolbar.titleFont = placeholderFont
                        }
                    }
                }
            } else if siblings.count != 0 {
                
                //	If more than 1 textField is found. then adding previous/next/done buttons on it.
                for textField in siblings {
                    
                    //Either there is no inputAccessoryView or if accessoryView is not appropriate for current situation(There is Done toolbar).
                    if textField.inputAccessoryView == nil || textField.inputAccessoryView?.tag == kIQDoneButtonToolbarTag {
                        
                        //Now adding textField placeholder text as title of IQToolbar  (Enhancement ID: #27)
                        textField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: "previousAction:", nextAction: "nextAction:", doneAction: "doneAction:", shouldShowPlaceholder: shouldShowTextFieldPlaceholder)
                        textField.inputAccessoryView?.tag = kIQPreviousNextButtonToolbarTag //  (Bug ID: #78)
                   }
                    
                    if textField.inputAccessoryView is IQToolbar && textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag {
                        
                        let toolbar = textField.inputAccessoryView as! IQToolbar
                        
                        //  Setting toolbar to keyboard.
                        if let _textField = textField as? UITextField {
                            
                            //Bar style according to keyboard appearance
                            switch _textField.keyboardAppearance {
                                
                            case UIKeyboardAppearance.dark:
                                toolbar.barStyle = UIBarStyle.black
                                toolbar.tintColor = UIColor.white
                            default:
                                toolbar.barStyle = UIBarStyle.default
                                toolbar.tintColor = shouldToolbarUsesTextFieldTintColor ? _textField.tintColor : _defaultToolbarTintColor
                            }
                        } else if let _textView = textField as? UITextView {
                            
                            //Bar style according to keyboard appearance
                            switch _textView.keyboardAppearance {
                                
                            case UIKeyboardAppearance.dark:
                                toolbar.barStyle = UIBarStyle.black
                                toolbar.tintColor = UIColor.white
                            default:
                                toolbar.barStyle = UIBarStyle.default
                                toolbar.tintColor = shouldToolbarUsesTextFieldTintColor ? _textView.tintColor : _defaultToolbarTintColor
                            }
                        }
                        
                        //Setting toolbar title font.   //  (Enhancement ID: #30)
                        if shouldShowTextFieldPlaceholder == true && placeholderFont != nil {
                            
                            let toolbar = textField.inputAccessoryView as! IQToolbar
                            
                            //Updating placeholder font to toolbar.     //(Bug ID: #148)
                            if let _textField = textField as? UITextField {
                                
                                if toolbar.title != _textField.placeholder {
                                    toolbar.title = _textField.placeholder
                                }
                                
                            } else if let _textView = textField as? IQTextView {
                                
                                if toolbar.title != _textView.placeholder {
                                    toolbar.title = _textView.placeholder
                                }
                            }
                            
                            //Setting toolbar title font.   //  (Enhancement ID: #30)
                            if placeholderFont != nil {
                                toolbar.titleFont = placeholderFont
                            }
                        }
                    }
                    
                    //If the toolbar is added by IQKeyboardManager then automatically enabling/disabling the previous/next button.
                    if textField.inputAccessoryView?.tag == kIQPreviousNextButtonToolbarTag {
                        //In case of UITableView (Special), the next/previous buttons has to be refreshed everytime.    (Bug ID: #56)
                        //	If firstTextField, then previous should not be enabled.
                        if siblings[0] == textField {
                            textField.setEnablePrevious(false, isNextEnabled: true)
                        } else if siblings.last  == textField {   //	If lastTextField then next should not be enaled.
                            textField.setEnablePrevious(true, isNextEnabled: false)
                        } else {
                            textField.setEnablePrevious(true, isNextEnabled: true)
                        }
                    }
                }
            }
        }
    }
    
    /** Remove any toolbar if it is IQToolbar. */
    fileprivate func removeToolbarIfRequired() {    //  (Bug ID: #18)
        
        //	Getting all the sibling textFields.
        if let siblings = responderViews() {
            
            for view in siblings {
                
                let toolbar = view.inputAccessoryView
                
                if toolbar is IQToolbar == true  && (toolbar?.tag == kIQDoneButtonToolbarTag || toolbar?.tag == kIQPreviousNextButtonToolbarTag) {
                    
                    if view is UITextField == true {
                        let textField = view as! UITextField
                        textField.inputAccessoryView = nil
                    } else if view is UITextView == true {
                        let textView = view as! UITextView
                        textView.inputAccessoryView = nil
                    }
                }
            }
        }
    }
    
    fileprivate func _IQShowLog(_ logString: String) {
        
        #if IQKEYBOARDMANAGER_DEBUG
        //println("IQKeyboardManager: " + logString)
        #endif
    }
}

