//
//  MenuTableViewController.swift
//  Ugo
//
//  Created by Sadiq on 28/07/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

struct Menu{
    var name:String!
    var image:String!
}

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var menus : [Menu] = []
    
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        menus.append(Menu(name: "Profile", image: "profile"))

        menus.append(Menu(name: "Home", image: "home"))
        
//        menus.append(Menu(name: "FAQ", image: "faq"))
//        menus.append(Menu(name: "Our Company", image: "company"))
//        menus.append(Menu(name: "Feedback/Contact", image: "feedback"))
//        menus.append(Menu(name: "Legal Terms of Service", image: "terms"))
        
        
        menus.append(Menu(name: "Our Company", image: "company"))
        menus.append(Menu(name: "FAQ", image: "faq"))
        menus.append(Menu(name: "Delivery Information", image: "delivery"))
        menus.append(Menu(name: "Privacy Policy", image: "privacy"))
        menus.append(Menu(name: "Terms and Conditions", image: "terms"))
        menus.append(Menu(name: "Feedback / Contact", image: "feedback"))

        
        
        
        
        
        
        
    
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 64
        }else{
            return 50
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! HeaderCell
            
            var str = "LOGIN"
            if UserSessionInformation.sharedInstance.isLoggedIn {
                str = "\(UserSessionInformation.sharedInstance.fullname)"
            }
            
            var attStr = NSMutableAttributedString(string: str, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:font17r])
            
            cell.btnLogin.setAttributedTitle(attStr, forState: .Normal)

            cell.btnLogin.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.btnLogin.titleLabel?.minimumScaleFactor = 0.5
            cell.btnLogin.addTarget(self, action: Selector("btnLoginTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            cell.backgroundColor = UIColor(r: 55, g: 139, b: 32, a: 1)

            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("menuCell") as! MenuCell
     
            cell.lblName.text = menus[indexPath.row].name
//            indexPath.row == 2 ? (cell.lblNotificationCount.hidden = false) : (cell.lblNotificationCount.hidden = true)
            cell.imgLeftIcon.image = UIImage(named: menus[indexPath.row].image)
            
            cell.backgroundColor = UIColor(r: 49, g: 49, b: 49, a: 1)
            return cell
        }

    }
  
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println("selected row \(indexPath.row)")
        if indexPath.row == 1 {
            self.performSegueWithIdentifier("toHome", sender: nil)
        }else{
            if indexPath.row != 0 {
                self.performSegueWithIdentifier("toWebView", sender: indexPath.row)
            }
        }
        
    }
    
    func signoutTapped(){
        
    }
    
    func btnLoginTapped(sender: UIButton){
        self.revealViewController().revealToggleAnimated(false)

        if !UserSessionInformation.sharedInstance.isLoggedIn {
            var vc: LoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            var nav = UINavigationController(rootViewController: vc)
            UIApplication.sharedApplication().keyWindow?.topMostController()?.presentViewController(nav, animated: true, completion: nil)
//            self.presentViewController(nav, animated: true, completion: nil)
        }else{
            var vc: AccountViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AccountViewController") as! AccountViewController
            var nav = UINavigationController(rootViewController: vc)
            UIApplication.sharedApplication().keyWindow?.topMostController()?.presentViewController(nav, animated: true, completion: nil)
        }
    }
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        
        if let nav = segue.destinationViewController as? UINavigationController {
            if segue.identifier == "toWebView" {
                if let webViewViewController = nav.childViewControllers[0] as? WebViewViewController {
                    var url = ""
                    switch (sender as! Int) {
                    case 2:
                        url = "http://52.2.40.228/index.php?route=information/information&information_id=4"
                        
                    case 3:
                        url = "http://52.2.40.228/index.php?route=information/information&information_id=7"
                    case 4:
                        url = "http://www.ugollc.com/index.php?route=information/information&information_id=6"
                    case 5:
                        url = "http://www.ugollc.com/index.php?route=information/information&information_id=3"                        
                    case 6 :
                        url = "http://52.2.40.228/index.php?route=information/information&information_id=5"
                    case 7:
                        url = "http://52.2.40.228/index.php?route=information/contact"
                    default:
                        url = "http://52.2.40.228/index.php?route=information/information&information_id=4"
                    }
                    
                    webViewViewController.strUrl = url
                }
            }
        }
        
    }
    
}
