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
    func addObject(_ value: NSManagedObject, forKey: String) {
        let items = self.mutableSetValue(forKey: forKey);
        items.add(value)
    }
}

extension Array {
    func contains<T>(_ obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
    func get<T>(_ index: Int) -> T? {
        if 0 <= index && index < count {
            return self[index] as? T //added as? T
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
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func removeWhitespace() -> String {
        return self.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeDots() -> String {
        return self.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
    }
    
    var floatVal : Float {
        return (self as NSString).floatValue
    }
    
    func getHtmlToAttributed(_ font:UIFont = font15) -> NSAttributedString {
        let encodedData = self.data(using: String.Encoding.utf8)!
        var attributedString = NSAttributedString()
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject,
            NSFontAttributeName : font
        ]
        //let attributedString = NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil, error: nil)!
        do {
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {
            print("error")
        }
        
        
        return attributedString
    }
    
    
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g:CGFloat , b:CGFloat , a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    convenience init(hex:String , alpha: Double = 1.0){
        //var cString:NSString = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercased()
        let cString:NSString = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased() as NSString
        let rString = cString.substring(to: 2)
        let gString = (cString.substring(from: 2) as NSString).substring(to: 2)
        let bString = (cString.substring(from: 4)as NSString).substring(to: 2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        self.init(red:CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(alpha))
    }
}

extension UIView{
    
    func _गोल_करा(_ radius:CGFloat, color:UIColor = UIColor.clear) -> UIView{
        let rounfView:UIView = self
        rounfView.layer.cornerRadius = CGFloat(radius)
        rounfView.layer.borderWidth = 1
        rounfView.layer.borderColor = color.cgColor
        rounfView.clipsToBounds = true
        return rounfView
    }
    
    var _गोल_करा:UIView! {
        let rounfView:UIView = self
        //rounfView._गोल_करा(rounfView.frame.width / 2)
        return rounfView
    }
    
    var shadow :UIView!{
        self.layer.shadowColor = UIColor.black.cgColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOffset = CGSize(width: 0, height: 0);
        self.clipsToBounds = false;
        
        return self
    }
}

extension UITextField {
    var setRightView : UITextField {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imgView.image = UIImage(named: "arrowdown")
        
        self.rightView = imgView
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 30))
        
        self.rightViewMode = .always
        self.leftViewMode = .always
        return self
    }
    
    var setBorder : UITextField {
        self.backgroundColor = UIColor.white
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 30))
        self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 30))
        
        self.leftViewMode = .always
        return self
    }
    
    var setBorderBottom : UITextField {
        let border = CALayer()
        let width : CGFloat = 0.4
        border.borderColor = UIColor(r: 220, g: 220, b: 220, a: 1).cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
        return self
    }
}

extension UILabel {
    
    func characterSpacing(_ val:CGFloat) {
        let attributedString = NSMutableAttributedString(string: self.text!)
        attributedString.addAttribute(NSKernAttributeName, value: val, range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
    
    
    func setHTMLFromString(_ text: String) {
        let modifiedFont = NSString(format:"<span style=\"font-family: \(self.font.fontName); font-size: \(self.font.pointSize)\">%@</span>" as NSString, text) as String
        do {
            let attrStr = try NSAttributedString(
                data: modifiedFont.data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8],
                documentAttributes: nil)
            self.attributedText = attrStr
        } catch {
            print("error")
        }
    }
    
    
    func heightAsPerTheText(setTest txt:String) -> UILabel! {
        self.numberOfLines = 0
        self.text = txt
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.expectedHeight())
        return self
    }
    
    func expectedHeight() -> CGFloat! {
        
        let constraintSize = CGSize(width: ScreenSize.SCREEN_WIDTH - 32, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = self.text!.boundingRect(with: constraintSize,
                                                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                attributes: [NSFontAttributeName: self.font],
                                                context: nil)
        return labelSize.height + 15
    }
    
    func expectedWidth() -> CGFloat! {
        let constraintSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.frame.height)
        let labelSize = self.text!.boundingRect(with: constraintSize,
                                                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                attributes: [NSFontAttributeName: self.font],
                                                context: nil)
        return labelSize.width
    }
    
    
}

