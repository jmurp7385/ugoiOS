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
    case unspecified
    case phone
    case pad
}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}



class CommonUtility: NSObject {
    
    
    
    var loadingView:MBProgressHUD! = MBProgressHUD()

    let navBarColor:UIColor = UIColor(red: 40/255.0, green: 140/255.0, blue: 210/255.0, alpha: 1)
    let navBarContentColor:UIColor = UIColor.white
 
    class func showAlertView(_ title:NSString, message:NSString){
        let alert = UIAlertView()
        alert.title = title as String
        alert.message = message as String
        alert.addButton(withTitle: "Ok")
        alert.show()
        
    }
    
    
    class func showToast(_ msg : String){
        let hud = MBProgressHUD(view: UIApplication.shared.keyWindow)
        UIApplication.shared.keyWindow!.addSubview(hud!)
        hud?.customView = UIImageView(image: UIImage(named: "menucheck"))
        hud?.mode = MBProgressHUDModeCustomView
        hud?.labelText = msg
        hud?.show(true)
        hud?.hide(true, afterDelay: 3)
    }

    
    
    func showLoadingWithMessage(_ onView:UIView, message:String) {
        
        loadingView = MBProgressHUD(view: onView)
        onView.addSubview(loadingView)
        loadingView.labelText = message
        loadingView.show(true)
    }
    
    func hideLoadingIndicator(_ onView:UIView) {
        
        MBProgressHUD.hide(for: onView, animated: true)
    }
    
    
  
    
    //MARK:- get Nav controller
    class func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }

    
    func attributedText(WithStr str:String) -> NSAttributedString! {
        
        let attrStr:NSMutableAttributedString = NSMutableAttributedString(string: "& \(str)")
        attrStr.addAttribute(NSForegroundColorAttributeName, value: CommonUtility().navBarColor, range: NSMakeRange(0, 2))
        
        return attrStr
    }
    
    func setSearchIconForTxt(_ txtSearch:UITextField, withImageName:NSString) {
        
        let searchImg = UIImage(named: withImageName as String)
        let leftImgView = UIImageView(image: searchImg)
        leftImgView.frame = CGRect(x: 10, y: 0, width: searchImg!.size.width, height: searchImg!.size.height)
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: searchImg!.size.width))
        leftView.addSubview(leftImgView)
        
        txtSearch.leftViewMode = UITextFieldViewMode.always
        txtSearch.leftView = leftView
    }
    
    func calculateHeight(WithString str:String) -> CGFloat! {
        
        let font = UIFont.systemFont(ofSize: 15)
        
        let rect:CGRect = str.boundingRect(with: CGSize(width: 280, height: 999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil)
        
        return rect.height
    }
    
   class func heightForView(_ text:String) -> CGFloat{
        let calculationView : UITextView = UITextView()
        calculationView.text = text
        
        let size : CGSize  = calculationView.sizeThatFits(CGSize(width: ScreenSize.SCREEN_WIDTH, height: CGFloat.greatestFiniteMagnitude))
        return size.height
    }
    
   class func heightForView(_ text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    

    func transformedValue(_ value:Double) -> String {
        
        var tokens:Array = ["bytes", "KB", "MB", "GB", "TB"]
        var convertedValue:Double = value
        var multiplyFactor:Int = 0
        
        while (convertedValue > 1024) {
            convertedValue /= 1024;
            multiplyFactor += 1;
        }
        
        return NSString(format: "%4.2f %@",convertedValue, tokens[multiplyFactor]) as String
    }
    
    func addNoDataLabelOnView(_ viewToAdd:UIView, text txt:String)
    {
        let tmpView = UIView(frame: CGRect(x: 20, y: 100, width: 280, height: 40))
        tmpView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        tmpView.layer.cornerRadius = 5
        
        let lbl = UILabel(frame: CGRect(x: 10, y: 0, width: tmpView.frame.width - 20, height: tmpView.frame.height))
        lbl.backgroundColor = UIColor.clear
        lbl.textColor = UIColor.white
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textAlignment = NSTextAlignment.center
                lbl.text = txt
        tmpView.addSubview(lbl)
        viewToAdd.addSubview(tmpView)
    }
    
    class func generateRandomString() -> NSString
    {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: NSString = ""
        for _ in 0...16
        {
            randomString = randomString.appendingFormat("%C", letters.character(at: Int(arc4random_uniform(26)) % letters.length))
        }
        return randomString
    }

    class func isNetworkAvailable() -> Bool
    {
        let reachability:Reachability = Reachability.forInternetConnection()
        let internetStatus:NetworkStatus = reachability.currentReachabilityStatus()

        if(internetStatus.rawValue !=  NotReachable.rawValue){
            return true
        }
        else {
            return false
        }
    }
    
    class func todayTomorowOrDateBy(_ strDate:String?) -> dayType
    {
        if(strDate != nil)
        {
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let actdate:Date? = dateFormatter.date(from: strDate!)
            let currDate:Date = Date()
            
            var dtcomponents:DateComponents? = getDateComponentsFromDate(actdate)
            var currcomponents:DateComponents? = getDateComponentsFromDate(currDate)
            
            if (dtcomponents?.day == currcomponents?.day && dtcomponents?.month == currcomponents?.month && dtcomponents?.year == currcomponents?.year)
            {
                return  dayType.today//"Today"
            }
            else if ((dtcomponents?.day)! == currcomponents!.day! + 1 && dtcomponents?.month == (currcomponents?.month)! && dtcomponents?.year == (currcomponents?.year)!)
            {
                return dayType.tomorrow //"Tomorrow"
            }
            else if ((dtcomponents?.day)! == currcomponents!.day! - 1 && dtcomponents?.month == (currcomponents?.month)! && dtcomponents?.year == (currcomponents?.year)!)
            {
                return dayType.yesterday //"Yesterday"
            }
            else
            {
                return dayType.other
            }
        }
        else
        {
            return dayType.other
        }
    }
    
    
   
    class func todayTomorowOrDateForChatBy(_ strDate:String?) -> dayType
    {
        if(strDate != nil)
        {
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let actdate:Date? = dateFormatter.date(from: strDate!)
            let currDate:Date = Date()
            
            var dtcomponents:DateComponents? = getDateComponentsFromDate(actdate)
            var currcomponents:DateComponents? = getDateComponentsFromDate(currDate)
            
            if (dtcomponents?.day == currcomponents?.day && dtcomponents?.month == currcomponents?.month && dtcomponents?.year == currcomponents?.year)
            {
                return  dayType.today//"Today"
            }
            else if ((dtcomponents?.day)! == currcomponents!.day! + 1 && dtcomponents?.month == (currcomponents?.month)! && dtcomponents?.year == (currcomponents?.year)!)
            {
                return dayType.tomorrow //"Tomorrow"
            }
            else if ((dtcomponents?.day)! == currcomponents!.day! - 1 && dtcomponents?.month == (currcomponents?.month)! && dtcomponents?.year == (currcomponents?.year)!)
            {
                return dayType.yesterday //"Yesterday"
            }
            else
            {
                return dayType.other
            }
        }
        else
        {
            return dayType.other
        }
    }
    
    class func getDateComponentsFromDate(_ date:Date?) -> DateComponents?
    {
        if(date != nil)
        {
            let gregCal = Calendar(identifier: .gregorian)
            let components = gregCal.dateComponents([.day,.month,.year], from: Date())
            return components
            /*
            let gregorian:Calendar? = Calendar(identifier: Calendar.Identifier.gregorian)
            if(gregorian != nil)
            {
                
                var components:DateComponents = gregorian!.components(Calendar.Unit.DayCalendarUnit | Calendar.Unit.MonthCalendarUnit | Calendar.Unit.YearCalendarUnit, fromDate:date!)
                return components
                
            }
            */
        }
        return nil
    }
    
    //MARK: - Validations
    
    class func containsSpecialCharacters(_ string: String) -> Bool {
        //let regex = NSRegularExpression(pattern: "[^A-Za-z]", options: nil, error: nil)!
        let regex = try! NSRegularExpression(pattern: "[^A-Za-z]", options: .caseInsensitive)
        if regex.firstMatch(in: string, options: .anchored, range: NSMakeRange(0, string.characters.count)) != nil {
            return true
        }
       
        return false
    }

    class func containsNumbers(_ string: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "[0-9]", options: .caseInsensitive)
        if regex.firstMatch(in: string, options: .anchored, range: NSMakeRange(0, string.characters.count)) != nil {
            return true
        }
        return false
    }
    
    class func isValidEmail(_ emailString:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: emailString)
    }
}
