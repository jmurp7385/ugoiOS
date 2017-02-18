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
    
    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var table: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.table.reloadData()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 64
        }else{
            return 50
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
            
            var str = "LOGIN"
            if UserSessionInformation.sharedInstance.isLoggedIn {
                str = "\(UserSessionInformation.sharedInstance.fullname)"
            }
            
            let attStr = NSMutableAttributedString(string: str, attributes: [NSForegroundColorAttributeName:UIColor.white,NSFontAttributeName:font17r])
            
            cell.btnLogin.setAttributedTitle(attStr, for: UIControlState())

            cell.btnLogin.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.btnLogin.titleLabel?.minimumScaleFactor = 0.5
            cell.btnLogin.addTarget(self, action: #selector(MenuViewController.btnLoginTapped(_:)), for: UIControlEvents.touchUpInside)
            cell.backgroundColor = UIColor(r: 55, g: 139, b: 32, a: 1)

            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as! MenuCell
     
            cell.lblName.text = menus[indexPath.row].name
//            indexPath.row == 2 ? (cell.lblNotificationCount.hidden = false) : (cell.lblNotificationCount.hidden = true)
            cell.imgLeftIcon.image = UIImage(named: menus[indexPath.row].image)
            
            cell.backgroundColor = UIColor(r: 49, g: 49, b: 49, a: 1)
            return cell
        }

    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //println("selected row \(indexPath.row)")
        if indexPath.row == 1 {
            self.performSegue(withIdentifier: "toHome", sender: nil)
        }else{
            if indexPath.row != 0 {
                self.performSegue(withIdentifier: "toWebView", sender: indexPath.row)
            }
        }
        
    }
    
    func signoutTapped(){
        
    }
    
    func btnLoginTapped(_ sender: UIButton){
        self.revealViewController().revealToggle(animated: false)

        if !UserSessionInformation.sharedInstance.isLoggedIn {
            let vc: LoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let nav = UINavigationController(rootViewController: vc)
            UIApplication.shared.keyWindow?.topMostController()?.present(nav, animated: true, completion: nil)
//            self.presentViewController(nav, animated: true, completion: nil)
        }else{
            let vc: AccountViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
            let nav = UINavigationController(rootViewController: vc)
            UIApplication.shared.keyWindow?.topMostController()?.present(nav, animated: true, completion: nil)
        }
    }
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        
        if let nav = segue.destination as? UINavigationController {
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
