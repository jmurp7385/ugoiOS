//
//  EditAccountViewController.swift
//  Ugo
//
//  Created by Sadiq on 26/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit
import Alamofire

class EditAccountViewController: BaseViewController {

    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtTelephone: UITextField!
    @IBOutlet weak var txtFax: UITextField!

    
    @IBOutlet weak var btnSubmit: UIButton!
    var account : Account!
    
    @IBAction func btnSubmitTapped(_ sender: UIButton) {
        account.firstname = txtFirstName.text
        account.lastname = txtLastName.text
        account.email = txtEmail.text
        account.telephone = txtTelephone.text
        account.fax = txtFax.text
        
        userSession.account =  account
        putAccountAPI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Account"
        setCloseButton()
/* warning said they were not used, from extensions.swift
        txtFirstName.setBorderBottom
        txtLastName.setBorderBottom
        txtEmail.setBorderBottom
        txtTelephone.setBorderBottom
        txtFax.setBorderBottom
*/      
        account = userSession.account

        txtFirstName.text = account.firstname!
        txtLastName.text = account.lastname!
        txtEmail.text = account.email!
        txtTelephone.text = account.telephone!
        txtFax.text = account.fax!
        
        // Do any additional setup after loading the view.
    }

    // MARK: - API calls
    
    func putAccountAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.putAccount(account: account)).responseString { string in
                let str = string
                //println(str)
                

                }.responseJSON { JSON in
                CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                if JSON != nil{
                    let resp = DMAccount(JSON: JSON as AnyObject)
                    
                    if resp.status {
                        let account = DMAccount(JSON: JSON as AnyObject)
                        self.userSession.account = account.account
                        self.userSession.storeData()
                        CommonUtility.showAlertView("Information", message: "Account Details updated successfully")
                        self.navigationController?.popViewController(animated: true)

                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                    }
                }
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
