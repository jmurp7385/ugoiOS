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
    
    @IBAction func btnLogOutTapped(sender: UIButton) {
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETLogout).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                if JSON == nil{
                    var appdel = UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    func postPWDAPI(pwd : String , confirm:String){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTPWD(pwd, confirm)).responseString { _, _, string, _ in
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
                    CommonUtility.showAlertView("Information", message: "Password Changed Successfully")

                }
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    // MARK: - Alert Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            var pwd = alertView.textFieldAtIndex(0)?.text
            var confirm = alertView.textFieldAtIndex(1)?.text
            postPWDAPI(pwd!, confirm: confirm!)
        }

    }
    
    // MARK: - Table View Delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("settingsCell") as? UITableViewCell
        if cell == nil {
            cell  = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "settingsCell")
            cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
    
        cell!.textLabel?.text = dataArray[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0 :
            self.performSegueWithIdentifier("toEditAccountViewController", sender: nil)

        case 1 :
            var alert = UIAlertView(title: "Change Password", message: "", delegate: self, cancelButtonTitle: "Cancel",otherButtonTitles: "OK")
            alert.alertViewStyle = UIAlertViewStyle.LoginAndPasswordInput
            alert.textFieldAtIndex(0)?.secureTextEntry = true
            alert.textFieldAtIndex(0)?.placeholder = "Password"
            alert.textFieldAtIndex(1)?.placeholder = "Confirm password"
            
            
            alert.show()
        case 2 :
            self.performSegueWithIdentifier("toOrderHistoryViewController", sender: nil)
           
        default :
            print()
        }
    }
    
}
