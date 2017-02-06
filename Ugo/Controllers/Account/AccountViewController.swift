//
//  AccountViewController.swift
//  Ugo
//
//  Created by Sadiq on 26/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class AccountViewController: BaseViewController, UIAlertViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var dataArray : [String] = []
    
    @IBAction func btnLogOutTapped(_ sender: UIButton) {
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.getLogout).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                if JSON == nil{
                    let appdel = UIApplication.shared.delegate as! AppDelegate
                    self.userSession.account = Account()
                    self.userSession.access_token = nil
                    self.userSession.storeData()
                    let loginManager = FBSDKLoginManager()
                    loginManager.logOut()
                    appdel.initVC()
                    
                }
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Account Info"
        self.setCloseButton()
        dataArray = ["Edit Account","Change Password","Order History"]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK: - API calls
    
    func postPWDAPI(_ pwd : String , confirm:String){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postpwd(pwd, confirm)).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                if JSON != nil{
                    let resp = BaseJsonModel(JSON: JSON!)
                    if resp.status {

                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                    }
                }else{
                    CommonUtility.showAlertView("Information", message: "Password Changed Successfully")

                }
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    // MARK: - Alert Delegate  made private - unsure of consequence yet, if any
    internal func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            let pwd = alertView.textField(at: 0)?.text
            let confirm = alertView.textField(at: 1)?.text
            postPWDAPI(pwd!, confirm: confirm!)
        }

    }
    
    // MARK: - Table View Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as UITableViewCell! //changed from 'as? UITableViewCell' to 'as UITableViewCell!'
        if cell == nil {
            cell  = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "settingsCell")
            cell?.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
    
        cell!.textLabel?.text = dataArray[indexPath.row]
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0 :
            self.performSegue(withIdentifier: "toEditAccountViewController", sender: nil)

        case 1 :
            let alert = UIAlertView(title: "Change Password", message: "", delegate: self, cancelButtonTitle: "Cancel",otherButtonTitles: "OK")
            alert.alertViewStyle = UIAlertViewStyle.loginAndPasswordInput
            alert.textField(at: 0)?.isSecureTextEntry = true    //secureTextEntry to isSecureTextEntry
            alert.textField(at: 0)?.placeholder = "Password"
            alert.textField(at: 1)?.placeholder = "Confirm password"
            alert.show()
        case 2 :
            self.performSegue(withIdentifier: "toOrderHistoryViewController", sender: nil)
           
        default :
            print()
        }
    }
    
}
