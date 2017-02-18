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
import IQKeyboardManagerSwift
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let userSession = UserSessionInformation.sharedInstance
        userSession.getData()
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UINavigationBar.appearance().backgroundColor = UIColor.black
        
        
        //enable IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        //IQKeyboardManager.sharedManager().shouldRestoreScrollViewContentOffset = true
        
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
    
    
    func geoCodeUsingAddress(_ add : String) -> CLLocationCoordinate2D {
        var latitude : Double = 0
        var longitude : Double = 0
        var center = CLLocationCoordinate2D()
        let esc_addr = add.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) //(using: String.Encoding.utf8)
        let str = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=\(esc_addr!)"
        //added do try catch 
        do {
            let result = try String(contentsOf: URL(string: str)!, encoding: String.Encoding.utf8)
            
            //let result = String(contentsOfURL: URL(string: str)!, encoding: String.Encoding.utf8)
            let scanner = Scanner(string: result)
            if scanner.scanUpTo("\"lat\" :", into: nil) && scanner.scanString("\"lat\" :", into: nil)
            {
                scanner.scanDouble(&latitude)
            }
            if scanner.scanUpTo("\"lng\" :", into: nil) && scanner.scanString("\"lng\" :", into: nil)
            {
                scanner.scanDouble(&longitude)
            }
            
            
            center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            //println(center.latitude)
            //println(center.longitude)
            return center
        } catch {
            print("error")
        }
        return center
    }
    
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     open:url,
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
        
        let vc: AnyObject! =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditAccountViewController")
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = vc as? UIViewController
        self.window?.makeKeyAndVisible()
        
    }
    
    
    
    func initVC(){
        let vc: AnyObject! =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "initVC")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = vc as? UIViewController
        self.window?.makeKeyAndVisible()
        
    }
    
    func getTokenAPI(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postToken).responseJSON { response in
                if let JSON = response.result.value as? [String : Any] {
                    let resp = BaseJsonModel(JSON: JSON as AnyObject)
                    if !resp.status{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                    }else{
                        let userSession = UserSessionInformation.sharedInstance
                        userSession.access_token = JSON["access_token"] as? String
                        //userSession.access_token = JSON["access_token"] as? String
                        userSession.storeData()
                    }
                    self.initVC()
                }
                
            }
            /*
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postToken).responseJSON { JSON in
                    
                    if JSON != nil {
                        let resp = BaseJsonModel(JSON: JSON as AnyObject)
                        if !resp.status{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                        }else{
                            let userSession = UserSessionInformation.sharedInstance
                            userSession.access_token = JSON["access_token"] as? String
                            userSession.storeData()
                        }
                        self.initVC()
                    }
                    
            }
            */
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
    
    func getTokenAPIGeneral(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postToken).responseJSON { response in
                if let JSON = response.result.value as? [String : Any] {
                    let resp = BaseJsonModel(JSON: JSON as AnyObject)
                    if !resp.status{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                    }else{
                        let userSession = UserSessionInformation.sharedInstance
                        userSession.access_token = JSON["access_token"] as? String
                        
                        userSession.storeData()
                    }
                }
                
            }
            /*
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postToken).responseJSON { JSON in
                    
                    if JSON != nil {
                        
                        let resp = BaseJsonModel(JSON: JSON as AnyObject)
                        if !resp.status{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                        }else{
                            let userSession = UserSessionInformation.sharedInstance
                            userSession.access_token = JSON["access_token"] as? String
                            userSession.storeData()
                        }
                        
                        //println(JSON!["access_token"])
                    }
                    
            }
 */
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
    func getInitAPI(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.initApp("languages,currencies,countries,settings,customer_groups,cart,wishlist")).responseString { string in
                //let str = string
                    //println(str)

                }.responseJSON { JSON in
                    
                    if JSON != nil {
                        let resp = AppInit(JSON: JSON as AnyObject)
                        if !resp.status{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
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
            let acc = Account()
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postRegister(account: acc)).responseJSON { JSON in
                    if JSON != nil {
                        
                        let resp = BaseJsonModel(JSON: JSON as AnyObject)
                        if !resp.status{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                        }
                    }
            }

            /*
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postRegister(account: acc)).response { (request, response, data, error) in
                //println(request)
                //println(response)
                //println(error)
                }.responseString { string in
                    if string != nil {
                        //println(str)
                    }
                }.responseJSON { JSON in
                    
                    if JSON != nil {
                        
                        let resp = BaseJsonModel(JSON: JSON!)
                        if !resp.status{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                        }
                    }
                    
            }
            */
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

