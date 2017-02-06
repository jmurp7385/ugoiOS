//
//  UserSessionInformation.swift
//  Tokri
//
//  Created by Sadiq on 27/04/15.
//  Copyright (c) 2015 Xstpl. All rights reserved.
//

import UIKit

class UserSessionInformation: NSObject {
    private static var __once: () = {
            Static.instance = UserSessionInformation()
            Static.instance.account = Account()

        }()
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
            static var token : Int = 0
        }
        
        _ = UserSessionInformation.__once
        
        
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
        let shared = UserSessionInformation.sharedInstance
        UserDefaults.standard.setValue(shared.access_token, forKey: "access_token")

        if shared.account!.customer_id != nil {
            UserDefaults.standard.set(shared.account!.customer_id!, forKey: "cust_id")
        }else{
            UserDefaults.standard.removeObject(forKey: "cust_id")
        }

        UserDefaults.standard.setValue(shared.account?.firstname, forKey: "firstname")
        UserDefaults.standard.setValue(shared.account?.lastname, forKey: "lastname")
        UserDefaults.standard.setValue(shared.account?.email, forKey: "email")
        UserDefaults.standard.setValue(shared.image, forKey: "image")
        UserDefaults.standard.setValue(shared.account?.telephone, forKey: "telephone")
        UserDefaults.standard.setValue(shared.token, forKey: "token")

        
        
    }
    
    func getData(){
        let shared = UserSessionInformation.sharedInstance
        shared.access_token = UserDefaults.standard.value(forKey: "access_token") as? String
        shared.account!.customer_id = UserDefaults.standard.value(forKey: "cust_id") as? Int
        shared.account!.firstname = UserDefaults.standard.value(forKey: "firstname") as? String
        shared.account!.lastname = UserDefaults.standard.value(forKey: "lastname") as? String
        shared.account!.email = UserDefaults.standard.value(forKey: "email") as? String
        shared.account!.telephone = UserDefaults.standard.value(forKey: "telephone") as? String
        shared.image = UserDefaults.standard.value(forKey: "image") as? String
        shared.token = UserDefaults.standard.value(forKey: "token") as? String


    }
}

