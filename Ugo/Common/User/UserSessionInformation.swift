//
//  UserSessionInformation.swift
//  Tokri
//
//  Created by Sadiq on 27/04/15.
//  Copyright (c) 2015 Xstpl. All rights reserved.
//

import UIKit

class UserSessionInformation: NSObject {
    var access_token : String?
    var username: String?

    var image: String?
    var token: String?


    
    var account : Account?

    var cartCount : Int = 0
    
    var fullname : String { return (self.account != nil ? self.account!.firstname! + " " : "") + (self.account != nil ? self.account!.lastname! : "") }

    var appInit : AppInit!
    
    var isLoggedIn : Bool { return ( UserSessionInformation.sharedInstance.account!.customer_id != nil) ? true : false }
    
    class var sharedInstance:UserSessionInformation{
 
        
        struct Static{
            static var instance : UserSessionInformation!
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token){
            Static.instance = UserSessionInformation()
            Static.instance.account = Account()

        }
        
        
        return Static.instance
    }
    
    func resetAll(){
        UserSessionInformation.sharedInstance.account = nil
        UserSessionInformation.sharedInstance.username = nil
        UserSessionInformation.sharedInstance.image = nil
        UserSessionInformation.sharedInstance.token = nil
        storeData()
    }
    
    func storeData(){
        var shared = UserSessionInformation.sharedInstance
        NSUserDefaults.standardUserDefaults().setValue(shared.access_token, forKey: "access_token")

        if shared.account!.customer_id != nil {
            NSUserDefaults.standardUserDefaults().setInteger(shared.account!.customer_id!, forKey: "cust_id")
        }else{
            NSUserDefaults.standardUserDefaults().removeObjectForKey("cust_id")
        }

        NSUserDefaults.standardUserDefaults().setValue(shared.account?.firstname, forKey: "firstname")
        NSUserDefaults.standardUserDefaults().setValue(shared.account?.lastname, forKey: "lastname")
        NSUserDefaults.standardUserDefaults().setValue(shared.account?.email, forKey: "email")
        NSUserDefaults.standardUserDefaults().setValue(shared.image, forKey: "image")
        NSUserDefaults.standardUserDefaults().setValue(shared.account?.telephone, forKey: "telephone")
        NSUserDefaults.standardUserDefaults().setValue(shared.token, forKey: "token")

        
        
    }
    
    func getData(){
        var shared = UserSessionInformation.sharedInstance
        shared.access_token = NSUserDefaults.standardUserDefaults().valueForKey("access_token") as? String
        shared.account!.customer_id = NSUserDefaults.standardUserDefaults().valueForKey("cust_id") as? Int
        shared.account!.firstname = NSUserDefaults.standardUserDefaults().valueForKey("firstname") as? String
        shared.account!.lastname = NSUserDefaults.standardUserDefaults().valueForKey("lastname") as? String
        shared.account!.email = NSUserDefaults.standardUserDefaults().valueForKey("email") as? String
        shared.account!.telephone = NSUserDefaults.standardUserDefaults().valueForKey("telephone") as? String
        shared.image = NSUserDefaults.standardUserDefaults().valueForKey("image") as? String
        shared.token = NSUserDefaults.standardUserDefaults().valueForKey("token") as? String


    }
}

