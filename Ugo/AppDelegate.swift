//
//  AppDelegate.swift
//  Ugo
//
//  Created by Sadiq on 28/07/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        var userSession = UserSessionInformation.sharedInstance
        userSession.getData()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        UINavigationBar.appearance().backgroundColor = UIColor.blackColor()
        
        
        //enable IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldRestoreScrollViewContentOffset = true

        getInitAPI()
        if userSession.access_token == nil {
            getTokenAPI()
        }else{
            self.initVC()
        }
        
        
//        geocoder.geocodeAddressString("Palolem Beach, Goa, India", completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
//            for pla in placemarks {
//                //println(pla)
//            }
//        })

        
        
        //        testAPI()
        //        test()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application,
            didFinishLaunchingWithOptions:launchOptions)
        
    }
    
    
    func geoCodeUsingAddress(add : String) -> CLLocationCoordinate2D {
        var latitude : Double = 0
        var longitude : Double = 0
        var esc_addr = add.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var str = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=\(esc_addr!)"
        var result = String(contentsOfURL: NSURL(string: str)!, encoding: NSUTF8StringEncoding, error: nil)
        var scanner = NSScanner(string: result!)
        if scanner.scanUpToString("\"lat\" :", intoString: nil) && scanner.scanString("\"lat\" :", intoString: nil)
        {
            scanner.scanDouble(&latitude)
        }
        if scanner.scanUpToString("\"lng\" :", intoString: nil) && scanner.scanString("\"lng\" :", intoString: nil)
        {
            scanner.scanDouble(&longitude)
        }
        
        
        var center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //println(center.latitude)
        //println(center.longitude)
        return center
        
    }
    
   
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
            openURL:url,
            sourceApplication:sourceApplication,
            annotation:annotation)
        
    }
    func test(){
        
//        
//        request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
//        .responseJSON { _, _, JSON, _ in
//            
//            if JSON != nil {
//               //println(JSON)
//            }
//        }

        var vc: AnyObject! =  UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EditAccountViewController")
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = vc as? UIViewController
        self.window?.makeKeyAndVisible()
        
    }
    
    
    
    func initVC(){
        var vc: AnyObject! =  UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("initVC")
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = vc as? UIViewController
        self.window?.makeKeyAndVisible()
        
    }
    
    func getTokenAPI(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTToken).response { (request, response, data, error) in
                //println(request)
                //println(response)
                //println(error)
                }.responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _,JSON, _ in
                    
                    if JSON != nil {
                        var resp = BaseJsonModel(JSON: JSON!)
                        if !resp.status{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg)
                        }else{
                            var userSession = UserSessionInformation.sharedInstance
                            userSession.access_token = JSON!["access_token"] as? String
                            userSession.storeData()
                        }
                        self.initVC()
                    }
                    
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
    
    func getTokenAPIGeneral(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTToken).response { (request, response, data, error) in
                //println(request)
                //println(response)
                //println(error)
                }.responseString { _, _, string, _ in
                    if let str = string {
                        //println(str)
                    }
                }.responseJSON { _, _,JSON, _ in
                    
                    if JSON != nil {

                        var resp = BaseJsonModel(JSON: JSON!)
                        if !resp.status{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg)
                        }else{
                            var userSession = UserSessionInformation.sharedInstance
                            userSession.access_token = JSON!["access_token"] as? String
                            userSession.storeData()
                        }
                        
                        //println(JSON!["access_token"])
                    }
                    
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
    func getInitAPI(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.initApp("languages,currencies,countries,settings,customer_groups,cart,wishlist")).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                
                if JSON != nil {
                    var resp = AppInit(JSON: JSON!)
                    if !resp.status{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg)
                    }else{
                        UserSessionInformation.sharedInstance.appInit = resp
                    }
                }
                
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
    
    
    func testAPI(){
        if CommonUtility.isNetworkAvailable() {
            var acc = Account()
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTRegister(account: acc)).response { (request, response, data, error) in
                //println(request)
                //println(response)
                //println(error)
                }.responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    
                    if JSON != nil {
                        
                        var resp = BaseJsonModel(JSON: JSON!)
                        if !resp.status{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg)
                        }
                    }
                    
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

