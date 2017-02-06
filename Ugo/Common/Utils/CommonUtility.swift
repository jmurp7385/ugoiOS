//
//  CommonUtility.swift
//  Chookka
//
//  Created by Shardul on 10/07/14.
//  Copyright (c) 2014 Mobinett Interactive, Inc. All rights reserved.
//

import UIKit

let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)

enum UIUserInterfaceIdiom : Int
{
    case Unspecified
    case Phone
    case Pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}



class CommonUtility: NSObject {
    
    
    
    var loadingView:MBProgressHUD! = MBProgressHUD()

    let navBarColor:UIColor = UIColor(red: 40/255.0, green: 140/255.0, blue: 210/255.0, alpha: 1)
    let navBarContentColor:UIColor = UIColor.whiteColor()
 
    class func showAlertView(title:NSString, message:NSString){
        let alert = UIAlertView()
        alert.title = title as String
        alert.message = message as String
        alert.addButtonWithTitle("Ok")
        alert.show()
        
    }
    
    
    class func showToast(msg : String){
        var hud = MBProgressHUD(view: UIApplication.sharedApplication().keyWindow)
        UIApplication.sharedApplication().keyWindow!.addSubview(hud)
        hud.customView = UIImageView(image: UIImage(named: "menucheck"))
        hud.mode = MBProgressHUDModeCustomView
        hud.labelText = msg
        hud.show(true)
        hud.hide(true, afterDelay: 3)
    }

    
    
    func showLoadingWithMessage(onView:UIView, message:String) {
        
        loadingView = MBProgressHUD(view: onView)
        onView.addSubview(loadingView)
        loadingView.labelText = message
        loadingView.show(true)
    }
    
    func hideLoadingIndicator(onView:UIView) {
        
        MBProgressHUD.hideHUDForView(onView, animated: true)
    }
    
    
  
    
    //MARK:- get Nav controller
    class func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.sharedApplication().keyWindow?.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }

    
    func attributedText(WithStr str:String) -> NSAttributedString! {
        
        var attrStr:NSMutableAttributedString = NSMutableAttributedString(string: "& \(str)")
        attrStr.addAttribute(NSForegroundColorAttributeName, value: CommonUtility().navBarColor, range: NSMakeRange(0, 2))
        
        return attrStr
    }
    
    func setSearchIconForTxt(txtSearch:UITextField, withImageName:NSString) {
        
        var searchImg = UIImage(named: withImageName as String)
        var leftImgView = UIImageView(image: searchImg)
        leftImgView.frame = CGRectMake(10, 0, searchImg!.size.width, searchImg!.size.height)
        var leftView = UIView(frame: CGRectMake(0, 0, 20, searchImg!.size.width))
        leftView.addSubview(leftImgView)
        
        txtSearch.leftViewMode = UITextFieldViewMode.Always
        txtSearch.leftView = leftView
    }
    
    func calculateHeight(WithString str:String) -> CGFloat! {
        
        var font = UIFont.systemFontOfSize(15)
        
        var rect:CGRect = str.boundingRectWithSize(CGSize(width: 280, height: 999), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil)
        
        return rect.height
    }
    
   class func heightForView(text:String) -> CGFloat{
        var calculationView : UITextView = UITextView()
        calculationView.text = text
        
        var size : CGSize  = calculationView.sizeThatFits(CGSize(width: ScreenSize.SCREEN_WIDTH, height: CGFloat.max))
        return size.height
    }
    
   class func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    

    func transformedValue(value:Double) -> String {
        
        var tokens:Array = ["bytes", "KB", "MB", "GB", "TB"]
        var convertedValue:Double = value
        var multiplyFactor:Int = 0
        
        while (convertedValue > 1024) {
            convertedValue /= 1024;
            multiplyFactor++;
        }
        
        return NSString(format: "%4.2f %@",convertedValue, tokens[multiplyFactor]) as String
    }
    
    func addNoDataLabelOnView(viewToAdd:UIView, text txt:String)
    {
        var tmpView = UIView(frame: CGRectMake(20, 100, 280, 40))
        tmpView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        tmpView.layer.cornerRadius = 5
        
        var lbl = UILabel(frame: CGRectMake(10, 0, tmpView.frame.width - 20, tmpView.frame.height))
        lbl.backgroundColor = UIColor.clearColor()
        lbl.textColor = UIColor.whiteColor()
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFontOfSize(13)
        lbl.textAlignment = NSTextAlignment.Center
                lbl.text = txt
        tmpView.addSubview(lbl)
        viewToAdd.addSubview(tmpView)
    }
    
    class func generateRandomString() -> NSString
    {
        var letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: NSString = ""
        for index in 0...16
        {
            randomString = randomString.stringByAppendingFormat("%C", letters.characterAtIndex(Int(arc4random_uniform(26)) % letters.length))
        }
        return randomString
    }

    class func isNetworkAvailable() -> Bool
    {
        var reachability:Reachability = Reachability.reachabilityForInternetConnection()
        var internetStatus:NetworkStatus = reachability.currentReachabilityStatus()
        
        if(internetStatus.value !=  NotReachable.value){
            return true
        }
        else {
            return false
        }
    }
    
    class func todayTomorowOrDateBy(strDate:String?) -> dayType
    {
        if(strDate != nil)
        {
            var dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            var actdate:NSDate? = dateFormatter.dateFromString(strDate!)
            var currDate:NSDate = NSDate()
            
            var dtcomponents:NSDateComponents? = getDateComponentsFromDate(actdate)
            var currcomponents:NSDateComponents? = getDateComponentsFromDate(currDate)
            
            if (dtcomponents?.day == currcomponents?.day && dtcomponents?.month == currcomponents?.month && dtcomponents?.year == currcomponents?.year)
            {
                return  dayType.TODAY//"Today"
            }
            else if (dtcomponents?.day == currcomponents!.day + 1 && dtcomponents?.month == currcomponents?.month && dtcomponents?.year == currcomponents?.year)
            {
                return dayType.TOMORROW //"Tomorrow"
            }
            else if (dtcomponents?.day == currcomponents!.day - 1 && dtcomponents?.month == currcomponents?.month && dtcomponents?.year == currcomponents?.year)
            {
                return dayType.YESTERDAY //"Yesterday"
            }
            else
            {
                return dayType.OTHER
            }
        }
        else
        {
            return dayType.OTHER
        }
    }
    
    
   
    class func todayTomorowOrDateForChatBy(strDate:String?) -> dayType
    {
        if(strDate != nil)
        {
            var dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            var actdate:NSDate? = dateFormatter.dateFromString(strDate!)
            var currDate:NSDate = NSDate()
            
            var dtcomponents:NSDateComponents? = getDateComponentsFromDate(actdate)
            var currcomponents:NSDateComponents? = getDateComponentsFromDate(currDate)
            
            if (dtcomponents?.day == currcomponents?.day && dtcomponents?.month == currcomponents?.month && dtcomponents?.year == currcomponents?.year)
            {
                return  dayType.TODAY//"Today"
            }
            else if (dtcomponents?.day == currcomponents!.day + 1 && dtcomponents?.month == currcomponents?.month && dtcomponents?.year == currcomponents?.year)
            {
                return dayType.TOMORROW //"Tomorrow"
            }
            else if (dtcomponents?.day == currcomponents!.day - 1 && dtcomponents?.month == currcomponents?.month && dtcomponents?.year == currcomponents?.year)
            {
                return dayType.YESTERDAY //"Yesterday"
            }
            else
            {
                return dayType.OTHER
            }
        }
        else
        {
            return dayType.OTHER
        }
    }
    
    class func getDateComponentsFromDate(date:NSDate?) -> NSDateComponents?
    {
        if(date != nil)
        {
            var gregorian:NSCalendar? = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            if(gregorian != nil)
            {
                var components:NSDateComponents = gregorian!.components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit, fromDate:date!)
                
                return components
            }
        }
        return nil
    }
    
    //MARK: - Validations
    
    class func containsSpecialCharacters(string: String) -> Bool {
        let regex = NSRegularExpression(pattern: "[^A-Za-z]", options: nil, error: nil)!
        if regex.firstMatchInString(string, options: nil, range: NSMakeRange(0, count(string))) != nil {
            return true
        }
        return false
    }

    class func containsNumbers(string: String) -> Bool {
        let regex = NSRegularExpression(pattern: "[0-9]", options: nil, error: nil)!
        if regex.firstMatchInString(string, options: nil, range: NSMakeRange(0, count(string))) != nil {
            return true
        }
        return false
    }
    
    class func isValidEmail(emailString:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(emailString)
    }
}
