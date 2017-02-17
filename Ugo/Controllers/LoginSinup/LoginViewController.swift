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
import Alamofire

class LoginViewController: BaseViewController ,UIAlertViewDelegate,FBSDKLoginButtonDelegate{
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPwd: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    
    @IBOutlet weak var vwFB : UIView!
    
    var acc = Account()
    
    // MARK: - Btn Actions
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        if buttonIndex == 0 {
            if alertView.tag == 333 {
                let email = alertView.textField(at: 0)?.text
                self.forgotAPI(email!)
            }else if alertView.tag == 222 {
                let email = alertView.textField(at: 0)?.text
                self.acc.email = email
                self.signupFbAPI(self.acc)
            }
        }
    }
    
    @IBAction func btnSignupTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        loginAPI()
    }
    
    @IBAction func btnForgotPwdTapped(_ sender: UIButton) {
        let alert = UIAlertView(title: "Forgot Password", message: "Please enter email id.", delegate: self, cancelButtonTitle: "OK")
        alert.tag = 333
        alert.alertViewStyle = UIAlertViewStyle.plainTextInput
        alert.textField(at: 0)?.keyboardType = UIKeyboardType.emailAddress
        alert.show()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //   self.txtUsername.text = "sadiq@xtensible.in"
        // self.txtPwd.text = "asdasd"
        //
//        txtUsername.setBorderBottom       //not used
//        txtPwd.setBorderBottom            //not used
        
        setCloseButton()
        self.title = "Login"
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (FBSDKAccessToken.current() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            let loginButton = FBSDKLoginButton()
            loginButton.center = CGPoint(x: self.vwFB.center.x, y: self.vwFB.frame.height/2)
            //print(self.vwFB.center)
            self.vwFB.addSubview(loginButton)
            
            
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.delegate = self
        }
        
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //print("User Logged In")
        
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
                //print("Granted email permission")
                
                if let dict = result as? NSDictionary{
                    for d in dict {
                        print(d)
                    }
                }
                // Do work
            }
            returnUserData()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if let dict = result as? NSDictionary{
                for _ in dict {
                    //print(d)
                }
            }
            
            if ((error) != nil)
            {
                // Process error
                //print("Error: \(error)")
            }
            else
            {
                //print("fetched user: \(result)")
                if let resultDict = result as? NSDictionary {
                if let first_name : String = (result as! NSDictionary).value(forKey: "first_name") as? String{
                    //print("first_name is: \(first_name)")
                    self.acc.firstname = first_name
                    
                }
                if let last_name : String = resultDict.value(forKey: "last_name") as? String{
                    //print("last_name is: \(last_name)")
                    self.acc.lastname = last_name
                    
                }
                if let email : String = resultDict.value(forKey: "email") as? String{
                    //print("email is: \(email)")
                    self.acc.email = email
                }else{
                    CommonUtility.showAlertView("Information", message: "No email address is found")
                }
                if let id : String = resultDict.value(forKey: "id") as? String{
                    //print("id is: \(id)")
                    self.acc.fb = id
                }
                
                
                self.acc.password = "123456"
                
                if self.acc.email == "" {
                    let alert = UIAlertView(title: "Information", message: "Please enter email id.", delegate: self, cancelButtonTitle: "OK")
                    alert.tag = 222
                    alert.alertViewStyle = UIAlertViewStyle.plainTextInput
                    alert.textField(at: 0)?.keyboardType = UIKeyboardType.emailAddress
                    alert.show()
                }else{
                    self.signupFbAPI(self.acc)
                }
                }
                
                
            }
        })
    }
    
    func doneTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - API calls
    
    func loginAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            //changed POSTLogin to postLogin
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postLogin(txtUsername.text!, txtPwd.text!)).response { response in
                //                //print(request)
                //                //print(response)
                //                //print(error)
                }.responseString { string in
                    let str = string 
                        //print(str)
                    
                }.responseJSON { JSON in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    if JSON != nil{
                        var resp = DMAccount(JSON: JSON as AnyObject)
                        if resp.status {
                            self.userSession.account = resp.account
                            self.userSession.storeData()
                            self.doneTapped()
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                        }
                    }
                    
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    func forgotAPI(_ email:String){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Submitting...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postForgotPwd(email: email)).responseString { string in
                if string != nil {
                    //print(str)
                }
                }.responseJSON { JSON in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    if JSON != nil{
                        let resp = BaseJsonModel(JSON: JSON as AnyObject)
                        if resp.status {
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                        }
                    }else{
                        CommonUtility.showAlertView("Information", message: "Please check your email. Password reset instructions has been sent to your email address.")
                        
                    }
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    
    func signupFbAPI(_ acc : Account!){
        if CommonUtility.isNetworkAvailable() {
            
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postRegisterFB(account: acc)).response { response in
                //print(request)
                //print(response)
                //print(error)
                }.responseString { string in
                    if string != nil {
                        //print(str)
                    }
                }.responseJSON { JSON in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    if JSON != nil{
                        let resp = DMAccount(JSON: JSON as AnyObject)
                        if resp.status {
                            self.userSession.account = resp.account
                            self.userSession.storeData()
                            self.dismiss(animated: true, completion: nil)
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                        }
                    }
                    
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
}
