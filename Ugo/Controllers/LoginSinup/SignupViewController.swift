//
//  SignupViewController.swift
//  Ugo
//
//  Created by Sadiq on 28/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class SignupViewController: BaseViewController,AddressListViewDelegate {

    @IBOutlet weak var txtFirstname: UITextField!
    @IBOutlet weak var txtLastname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var scrollView : UIScrollView!

    @IBOutlet weak var btnSignup: UIButton!
    var account : Account!

    // MARK: - Btn Actions
    
    @IBAction func btnNextTapped(_ sender: UIButton) {
        
//        var vw =  UIApplication.sharedApplication().keyWindow?.topMostController()
//        var storyboard = UIStoryboard(name: "Main", bundle: nil)
//        var vc = storyboard.instantiateViewControllerWithIdentifier("AddAddressViewController") as! AddAddressViewController
//        vc.delegate = self
//        vc.type = AddressType.General
//        vw!.addChildViewController(vc)
//        vc.view.frame = UIScreen.mainScreen().bounds
//        vw!.view.addSubview(vc.view)
//        vc.didMoveToParentViewController(vw!)
        
        signupAPI()
    }
    
    func addressSelected(_ type: AddressType, address: Address) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        account = Account()
        setBackButton()
        self.title = "Sign Up"
        
        txtFirstname.setBorderBottom
        txtLastname.setBorderBottom
        txtEmail.setBorderBottom
        txtPwd.setBorderBottom
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func signupAPI(){
        if CommonUtility.isNetworkAvailable() {
            var acc = Account()
            
            acc.firstname = self.txtFirstname.text
            acc.lastname = self.txtLastname.text
            acc.email = self.txtEmail.text
            acc.password = self.txtPwd.text
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postRegister(account: acc)).response { (request, response, data, error) in
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
                            (UIApplication.shared.delegate as! AppDelegate).initVC()

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
