//
//  LoginViewController.swift
//  Ugo
//
//  Created by Sadiq on 17/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: BaseViewController ,UIAlertViewDelegate,FBSDKLoginButtonDelegate{
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPwd: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    
    @IBOutlet weak var vwFB : UIView!
    
    var acc = Account()
    
    // MARK: - Btn Actions
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 0 {
            if alertView.tag == 333 {
                var email = alertView.textFieldAtIndex(0)?.text
                self.forgotAPI(email!)
            }else if alertView.tag == 222 {
                var email = alertView.textFieldAtIndex(0)?.text
                self.acc.email = email
                self.signupFbAPI(self.acc)
            }
        }
    }
    
    @IBAction func btnSignupTapped(sender: UIButton) {
        
    }
    
    @IBAction func btnLoginTapped(sender: UIButton) {
        loginAPI()
    }
    
    @IBAction func btnForgotPwdTapped(sender: UIButton) {
        var alert = UIAlertView(title: "Forgot Password", message: "Please enter email id.", delegate: self, cancelButtonTitle: "OK")
        alert.tag = 333
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.EmailAddress
        alert.show()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //   self.txtUsername.text = "sadiq@xtensible.in"
        // self.txtPwd.text = "asdasd"
        //
        txtUsername.setBorderBottom
        txtPwd.setBorderBottom
        
        setCloseButton()
        self.title = "Login"
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            var loginButton = FBSDKLoginButton()
            loginButton.center = CGPointMake(self.vwFB.center.x, self.vwFB.frame.height/2)
            //println(self.vwFB.center)
            self.vwFB.addSubview(loginButton)
            
            
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.delegate = self
        }
        
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        //println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                //println("Granted email permission")
                
                if let dict = result as? NSDictionary{
                    for d in dict {
                        //println(d)
                    }
                }
                // Do work
            }
            returnUserData()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        //println("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if let dict = result as? NSDictionary{
                for d in dict {
                    //println(d)
                }
            }
            
            if ((error) != nil)
            {
                // Process error
                //println("Error: \(error)")
            }
            else
            {
                //println("fetched user: \(result)")
                if let first_name : String = result.valueForKey("first_name") as? String{
                    //println("first_name is: \(first_name)")
                    self.acc.firstname = first_name
                    
                }
                if let last_name : String = result.valueForKey("last_name") as? String{
                    //println("last_name is: \(last_name)")
                    self.acc.lastname = last_name
                    
                }
                if let email : String = result.valueForKey("email") as? String{
                    //println("email is: \(email)")
                    self.acc.email = email
                }else{
                    CommonUtility.showAlertView("Information", message: "No email address is found")
                }
                if let id : String = result.valueForKey("id") as? String{
                    //println("id is: \(id)")
                    self.acc.fb = id
                }
                
                
                self.acc.password = "123456"
                
                if self.acc.email == "" {
                    var alert = UIAlertView(title: "Information", message: "Please enter email id.", delegate: self, cancelButtonTitle: "OK")
                    alert.tag = 222
                    alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
                    alert.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.EmailAddress
                    alert.show()
                }else{
                    self.signupFbAPI(self.acc)
                }
                
                
            }
        })
    }
    
    func doneTapped(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - API calls
    
    func loginAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTLogin(txtUsername.text, txtPwd.text)).response { (request, response, data, error) in
                //                //println(request)
                //                //println(response)
                //                //println(error)
                }.responseString { _, _, string, _ in
                    if let str = string {
                        //println(str)
                    }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    if JSON != nil{
                        var resp = DMAccount(JSON: JSON!)
                        if resp.status {
                            self.userSession.account = resp.account
                            self.userSession.storeData()
                            self.doneTapped()
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg)
                        }
                    }
                    
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    func forgotAPI(email:String){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Submitting...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTForgotPwd(email: email)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    if JSON != nil{
                        var resp = BaseJsonModel(JSON: JSON!)
                        if resp.status {
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg)
                        }
                    }else{
                        CommonUtility.showAlertView("Information", message: "Please check your email. Password reset instructions has been sent to your email address.")
                        
                    }
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    
    func signupFbAPI(acc : Account!){
        if CommonUtility.isNetworkAvailable() {
            
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTRegisterFB(account: acc)).response { (request, response, data, error) in
                //println(request)
                //println(response)
                //println(error)
                }.responseString { _, _, string, _ in
                    if let str = string {
                        //println(str)
                    }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    if JSON != nil{
                        var resp = DMAccount(JSON: JSON!)
                        if resp.status {
                            self.userSession.account = resp.account
                            self.userSession.storeData()
                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg)
                        }
                    }
                    
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
}
