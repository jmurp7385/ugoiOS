

//
//  MainViewController.swift
//  Ugo
//
//  Created by Sadiq on 28/07/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate{
    
    var products : [Product] = []
    var categories : [Category] = []
    
    var scrollTimer : NSTimer!
    
    @IBOutlet weak var tableView: UITableView!
    // MARK: button Events
    func btnMenuTapped(sender: UIBarButtonItem) {
        self.revealViewController().revealToggleAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("isOverlayShown") {
            showOverlay("Help")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isOverlayShown")
        }
        
        var menuBtn = createBarButton("menu", actionName: "btnMenuTapped:")
        var logo = UIBarButtonItem(customView: UIImageView(image: UIImage(named: "logo")))
        self.navigationItem.leftBarButtonItems = [menuBtn,logo]
        addSearchButtonWithCart(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didSelectCell:"), name: "didSelectCell", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("endOfProductList:"), name: "endOfProductList", object: nil)
        
        
        
        
        specialProductAPI()
        getCategoriesAPI()
        
    }
    
    
    
    
    deinit{
        //print("deinit")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setBadge()
    }
    
    //MARK:- Help
    func showOverlay(img:String){
        var view = UIView(frame: UIScreen.mainScreen().bounds)
        var imageview = UIImageView(frame: view.frame)
        imageview.image = UIImage(named: img)
        view.tag = 1001
        view.gestureRecognizers = [UITapGestureRecognizer(target: self, action: Selector("helpDone"))]
        view.addSubview(imageview)
        self.navigationController?.view.addSubview(view)
        
    }
    
    func helpDone(){
        self.navigationController?.view.viewWithTag(1001)?.removeFromSuperview()
    }
    
    override func setbadgeNotif(){
        setBadge()
    }
    
    func didSelectCell(notification:NSNotification){
        self.performSegueWithIdentifier("productDetail", sender: notification.object)
    }
    
    func endOfProductList(notification:NSNotification){
        
        var cate = notification.object as! Category
        getProductsForCartAPI(cate.index!,page: "\(cate.page)")
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "productDetail":
            var productDetailViewController = segue.destinationViewController as! ProductDetailViewController
            productDetailViewController.product = sender as! Product
        default:
            break
            
        }
    }
    
    
    func specialProductAPI(){
        if CommonUtility.isNetworkAvailable() {
            
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETSpecialProducts).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { a, res, JSON, c in
                    println(res?.statusCode)
                    
                    if res?.statusCode == 401 {
                        var userSession = UserSessionInformation.sharedInstance
                        userSession.access_token = nil
                        userSession.storeData()
                        (UIApplication.sharedApplication().delegate as! AppDelegate).getTokenAPIGeneral()
                    }else{
                        if JSON != nil {
                            var resp = DMProduct(JSON: JSON!)
                            
                            if resp.status {
                                self.products = resp.products
                                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
                                
                            }else{
                                CommonUtility.showAlertView("Information", message: resp.errorMsg)
                            }
                        }
                    }
                    
                    
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
    }
    
    func getCategoriesAPI(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETCategories).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, res, JSON, _ in
                    
                    if JSON != nil {
                        if res?.statusCode == 401 {
                            var userSession = UserSessionInformation.sharedInstance
                            userSession.access_token = nil
                            userSession.storeData()
                            (UIApplication.sharedApplication().delegate as! AppDelegate).getTokenAPIGeneral()
                        }else{
                            var resp = DMCategory(JSON: JSON!)
                            
                            if resp.status {
                                self.categories = resp.categories
                                self.tableView.reloadData()
                                
                            }else{
                                CommonUtility.showAlertView("Information", message: resp.errorMsg)
                            }
                            
                        }
                    }
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
        
        
        
    }
    
    func getProductsForCartAPI(section: Int, page : String){
        
        if CommonUtility.isNetworkAvailable() {
            //println("Section \(section) products API Call")
            
            
            
            var cat_id = "\(categories[section-1].category_id!)"
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETProducts(limit: nil, page: page, cat_id: cat_id)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    
                    if JSON != nil {
                        
                        self.categories[section-1].isLoaded = true
                        var resp = DMCategory(JSON: JSON!)
                        
                        if resp.status {
                            var c = resp.category
                            //println("Section \(section) \(c.name) API Reaponse Products Count : \(c.products.count) ")
                            
                            if c.products.count == 0 {
                                self.categories[section-1].isCallAPI = false
                            }
                            self.categories[section-1].products =   self.categories[section-1].products.count == 0 ? c.products :   self.categories[section-1].products + c.products
                            
                            //                        self.categories[section-1].products = c.products
                            self.tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: UITableViewRowAnimation.Automatic)
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg)
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
    
    
    // MARK: - Table View Delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView != searchDisp.searchResultsTableView {
            return  categories.count + 1
        }else{
            return super.numberOfSectionsInTableView(searchDisp.searchResultsTableView)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView != searchDisp.searchResultsTableView {
            return 1
        }else{
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView != searchDisp.searchResultsTableView {
            if indexPath.section == 0 && indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("pageCell") as! PageTableViewCell
                cell.products = products
                return cell
                
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ProductListCell") as! ProductListCell
                var category = categories[indexPath.section-1]
                cell.products = category.products
                category.index = indexPath.section
                cell.category = category
                
                
                if !categories[indexPath.section-1].isLoaded {
                    cell.lblMsg.hidden = true
                    getProductsForCartAPI(indexPath.section,page: "1")
                    cell.loadingView.startAnimating()
                    
                }else{
                    if cell.products != nil {
                        if cell.products.count == 0 {
                            cell.lblMsg.hidden = false
                        }else{
                            cell.lblMsg.hidden = true
                        }
                    }
                    cell.loadingView.stopAnimating()
                }
                return cell
            }
        }else{
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView != searchDisp.searchResultsTableView {
            if section == 0 {
                return 0
            }else{
                return 30
            }
        }else{
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView != searchDisp.searchResultsTableView {
            
            if section == 0 {
                return nil
            } else {
                var view = UIView()
                view.backgroundColor = UIColor(r: 228, g: 228, b: 228, a: 1)
                
                let label = UILabel(frame: CGRectMake(8, 4, ScreenSize.SCREEN_WIDTH-20, 21))
                label.font = UIFont(name: "Roboto-Medium", size: 15)
                label.textColor = UIColor(r: 82, g: 162, b: 62, a: 1)
                label.text = "   \(categories[section-1].name!)"
                view.addSubview(label)
                return view
            }
        }else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView != searchDisp.searchResultsTableView {
            
            switch indexPath.section {
            case 0 :
                return 161
            case 1 :
                return 150
                
            default:
                return 150
            }
        }else{
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    
}
