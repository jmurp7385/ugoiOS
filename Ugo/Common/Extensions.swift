//
//  Extensions.swift
//  Tokri
//
//  Created by Sadiq on 27/04/15.
//  Copyright (c) 2015 Xstpl. All rights reserved.
//

import UIKit
import CoreData



class Extensions: NSObject {
    
}

extension NSManagedObject {
    func addObject(value: NSManagedObject, forKey: String) {
        var items = self.mutableSetValueForKey(forKey);
        items.addObject(value)
    }
}

extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
    func get(index: Int) -> T? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}
extension Float{
    var stringVal : String {
        return "\(self)"
    }
}
extension String {
    
    func trimWhiteSpaces() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    func removeWhitespace() -> String {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeDots() -> String {
        return self.stringByReplacingOccurrencesOfString(".", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    var floatVal : Float {
        return (self as NSString).floatValue
    }
    
    func getHtmlToAttributed(font:UIFont = font15) -> NSAttributedString {
        let encodedData = self.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
            NSFontAttributeName : font
        ]
        let attributedString = NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil, error: nil)!
        
        
        return attributedString
    }
    
    
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g:CGFloat , b:CGFloat , a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    convenience init(hex:String , alpha: Double = 1.0){
        var cString:NSString = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        var rString = cString.substringToIndex(2)
        var gString = (cString.substringFromIndex(2) as NSString).substringToIndex(2)
        var bString = (cString.substringFromIndex(4)as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        self.init(red:CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(alpha))
    }
}

extension UIView{
    
    func _गोल_करा(radius:CGFloat, color:UIColor = UIColor.clearColor()) -> UIView{
        var rounfView:UIView = self
        rounfView.layer.cornerRadius = CGFloat(radius)
        rounfView.layer.borderWidth = 1
        rounfView.layer.borderColor = color.CGColor
        rounfView.clipsToBounds = true
        return rounfView
    }
    
    var _गोल_करा:UIView! {
        var rounfView:UIView = self
        rounfView._गोल_करा(rounfView.frame.width / 2)
        return rounfView
    }
    
    var shadow :UIView!{
        self.layer.shadowColor = UIColor.blackColor().CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.clipsToBounds = false;

        return self
    }
}

extension UITextField {
    var setRightView : UITextField {
        var imgView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        imgView.image = UIImage(named: "arrowdown")
    
        self.rightView = imgView
        self.leftView = UIView(frame: CGRectMake(0, 0, 15, 30))
        
        self.rightViewMode = .Always
        self.leftViewMode = .Always
        return self
    }
    
    var setBorder : UITextField {
        self.backgroundColor = UIColor.whiteColor()
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.leftView = UIView(frame: CGRectMake(0, 0, 15, 30))
        self.rightView = UIView(frame: CGRectMake(0, 0, 15, 30))

        self.leftViewMode = .Always
        return self
    }
    
    var setBorderBottom : UITextField {
        let border = CALayer()
        var width : CGFloat = 0.4
        border.borderColor = UIColor(r: 220, g: 220, b: 220, a: 1).CGColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
        return self
    }
}

extension UILabel {
    
    func characterSpacing(val:CGFloat) {
        let attributedString = NSMutableAttributedString(string: self.text!)
        attributedString.addAttribute(NSKernAttributeName, value: val, range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
    
    
    func setHTMLFromString(text: String) {
        var modifiedFont = NSString(format:"<span style=\"font-family: \(self.font.fontName); font-size: \(self.font.pointSize)\">%@</span>", text) as String
        
        var attrStr = NSAttributedString(
            data: modifiedFont.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding],
            documentAttributes: nil,
            error: nil)
        
        self.attributedText = attrStr
    }

    
    func heightAsPerTheText(setTest txt:String) -> UILabel! {
        self.numberOfLines = 0
        self.text = txt
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, self.expectedHeight())
        return self
    }
    
    func expectedHeight() -> CGFloat! {
        
        let constraintSize = CGSizeMake(ScreenSize.SCREEN_WIDTH - 32, CGFloat.max)
        let labelSize = self.text!.boundingRectWithSize(constraintSize,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self.font],
            context: nil)
        return labelSize.height + 15
    }
    
    func expectedWidth() -> CGFloat! {
        let constraintSize = CGSizeMake(CGFloat.max, self.frame.height)
        let labelSize = self.text!.boundingRectWithSize(constraintSize,
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self.font],
            context: nil)
        return labelSize.width
    }
    
   
}

