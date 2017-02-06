//
//  BaseViewController.swift
//  Tokri
//
//  Created by Shardul on 29/04/15.
//  Copyright (c) 2015 Xstpl. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController , UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource{
    
    var searchDisp:UISearchDisplayController!
    
    var reachability : Reachability!
    
    var page = 1
    var isCallAPI : Bool = true
    
    var cartBtn : BBBadgeBarButtonItem!
    var userSession : UserSessionInformation!
    var loadingView:MBProgressHUD! = MBProgressHUD()
    var searchResults : [Product] = []
    func showLoadingWithMessage(onView:UIView, message:String) {
        loadingView = MBProgressHUD(view: onView)
        onView.addSubview(loadingView)
        loadingView.labelText = message
        loadingView.show(true)
    }
    
    func hideLoadingIndicator(onView:UIView) {
        MBProgressHUD.hideHUDForView(onView, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchDisp = UISearchDisplayController(searchBar: UISearchBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 20)), contentsController: self)
        self.view.addSubview(searchDisp.searchBar)
        searchDisp.searchBar.hidden = true
        searchDisp.searchResultsDataSource = self
        searchDisp.searchResultsDelegate = self
        searchDisp.searchBar.delegate = self
        searchDisp.delegate = self
        searchDisp.searchResultsTableView.rowHeight = UITableViewAutomaticDimension
        searchDisp.searchResultsTableView.estimatedRowHeight = 60
        searchDisp.searchBar.tintColor = UIColor.blackColor()
        
        userSession = UserSessionInformation.sharedInstance
        //        setBadge
        
        searchDisp.searchResultsTableView.separatorColor = UIColor(r: 65, g: 154, b: 43, a: 1)
        searchDisp.searchBar.barTintColor = UIColor.blackColor()
        searchDisp.searchBar.tintColor = UIColor.whiteColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleNetworkChange:"), name: kReachabilityChangedNotification, object: nil)
        reachability = Reachability.reachabilityForInternetConnection()
        reachability.startNotifier()
        
        
        var revealController:SWRevealViewController? = self.revealViewController()
        
        if revealController != nil {
            revealController!.panGestureRecognizer()
            revealController!.tapGestureRecognizer()
        }
        
        
        self.edgesForExtendedLayout = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("removeAddWishListChildViewController"), name: "removeAddWishListChildViewController", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setbadgeNotif"), name: "setbadge", object: nil)
        
    }
    
    func setbadgeNotif(){
        
    }
    
    func handleNetworkChange(notification:NSNotification){
        
    }
    
    
    func removeActionbtn(){
        
    }
    
    
    
    
    func setBadge(){
        
        var count = userSession.cartCount
        
        if count != 0 && cartBtn != nil {
            cartBtn.badgeValue = "\(count)"
            cartBtn.badgeTextColor = UIColor.blackColor()
            cartBtn.badgeBGColor = UIColor.whiteColor()
            cartBtn.badgeFont = UIFont.systemFontOfSize(10)
            cartBtn.badgeOriginX = 18
            cartBtn.badgeOriginY = -2
            cartBtn.badgePadding = 3
            cartBtn.shouldHideBadgeAtZero = true
        }else{
            if cartBtn != nil {
                cartBtn.removeBadge()
            }
        }
        
        
    }
    
    func createButtonForNav(menu: barMenu) -> UIButton{
        var btn = UIButton(frame: CGRectMake(0, 0, 30, 30))
        var name = ""
        
        switch menu {
        case barMenu.sidemenu:
            name = "menu"
            btn.addTarget(self, action: Selector("menuTapped"), forControlEvents: UIControlEvents.TouchUpInside)
            break;
        case barMenu.logo:
            name = "topbar_logo"
            btn.frame = CGRectMake(0, 0, 70, 30)
            btn.addTarget(self, action: Selector("logoTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            break;
        case barMenu.tokri:
            name = "tokri"
            btn.addTarget(self, action: Selector("tokriTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            break;
        case barMenu.user:
            name = "user"
            btn.addTarget(self, action: Selector("userTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            break;
        case barMenu.search:
            name = "search"
            btn.addTarget(self, action: Selector("searchTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            break;
        default :
            break;
        }
        btn.setImage(UIImage(named: name), forState: UIControlState.Normal)
        return btn
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackButton() {
        self.navigationItem.leftBarButtonItem = customBarBtn(25, height: 25, imgName: "icon_back", actionName: "btnBackTappedFromBase")
    }
    
    func setCloseButton(isleft : Bool = true) {
        if isleft {
            self.navigationItem.leftBarButtonItem = customBarBtn(25, height: 25, imgName: "web_close", actionName: "btnCloseTappedFromBase")
        }else{
            self.navigationItem.rightBarButtonItem = customBarBtn(25, height: 25, imgName: "web_close", actionName: "btnCloseTappedFromBase")
        }
    }
    
    func createBarButton(imgName:String, actionName:String) -> UIBarButtonItem {
        var menuBtn = UIBarButtonItem(image: UIImage(named: imgName), style: UIBarButtonItemStyle.Bordered, target: self, action:
            Selector(actionName))
        menuBtn.tintColor = UIColor.whiteColor()
        
        return menuBtn
    }
    
    func customBarBtn(width:CGFloat, height:CGFloat, imgName:String, actionName:String) -> UIBarButtonItem {
        var replyBtn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        replyBtn.setImage(UIImage(named: imgName), forState: UIControlState.Normal)
        replyBtn.addTarget(self, action: Selector(actionName), forControlEvents:  UIControlEvents.TouchUpInside)
        
        return UIBarButtonItem(customView: replyBtn)
    }
    
    // MARK: Search API
    
    func searchProductAPI(searchText : String,page: String){
        if CommonUtility.isNetworkAvailable() {
            self.showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETSearchProduct(limit: "\(searchLimit)", page: page, order: nil, sort: nil, search: searchText, descriptions: nil)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    MBProgressHUD.hideAllHUDsForView(self.navigationController!.view, animated: true)
                    
                    if JSON != nil {
                        var resp = DMProduct(JSON: JSON!)
                        
                        if resp.status {
                            
                            //println("Search count \(resp.products.count)")
                            if resp.products.count == 0 {
                                self.isCallAPI = false
                            }else{
                                self.isCallAPI = true
                            }
                            self.searchResults = self.searchResults.count == 0 ? resp.products : self.searchResults + resp.products
                            
                            
                            self.searchDisp.searchResultsTableView.reloadData()
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg)
                        }
                    }
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    // MARK: Search Display
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = []
        
        if searchText == "" {
            page = 1
            isCallAPI = true
        }
        if count(searchText) > 2 {
            searchProductAPI(searchText, page: "1")
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchDisp.searchBar.hidden = true
    }
    
    func searchDisplayControllerDidBeginSearch(controller: UISearchDisplayController) {
        searchDisp.searchBar.hidden = false
    }
    
    func searchDisplayControllerDidEndSearch(controller: UISearchDisplayController) {
        
    }
    
    func searchDisplayControllerWillEndSearch(controller: UISearchDisplayController) {
        searchDisp.searchBar.hidden = true
    }
    
    func addSearchButtonWithCart(chk:Bool) {
        
        var searchBtn = createBarButton("search", actionName: "btnSearchTapped:")
        var btn = UIButton(frame: CGRectMake(0, 0, 30, 30))
        btn.addTarget(self, action: Selector("btnCartTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
        btn.setImage(UIImage(named: "cart"), forState: UIControlState.Normal)
        
        cartBtn = BBBadgeBarButtonItem(customUIButton: btn)
        
        cartBtn.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItems = chk ? [cartBtn,searchBtn] : [searchBtn]
    }
    
    // MARK: - Btn Taps
    func btnBackTappedFromBase() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func btnCloseTappedFromBase() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func btnCartTapped(sender:AnyObject) {
        var vc: CartViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CartViewController") as! CartViewController
        var nav = UINavigationController(rootViewController: vc)
        self.presentViewController(nav, animated: true, completion: nil)
        
    }
    
    // Search disp
    func btnSearchTapped(sender:AnyObject) {
        searchDisp.searchBar.becomeFirstResponder()
        searchDisp.searchBar.hidden = false
        
        page = 1
        isCallAPI = true
    }
    
    // MARK: - Table View Delegates
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchResults.count > 0 {
            tableView.contentInset = UIEdgeInsetsZero
            tableView.scrollIndicatorInsets = UIEdgeInsetsZero
            
            var cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell") as? SearchResultCell
            if cell == nil {
                cell = SearchResultCell.cell()
            }
            
            
            var product = searchResults[indexPath.row]
            
            cell!.lblTitle.text = product.name!
            cell!.lblPrice.text = product.price!
            cell!.imgProduct.setImageWithUrl(NSURL(string: product.thumb_image!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!, placeHolderImage: UIImage(named: "loading"))
            if let description = product.descriptions {
                cell!.lblDescription.text = description.trimWhiteSpaces()
            }
            
            return cell!
            
        }else{
            return UITableViewCell()
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if searchResults.count > 0 {
            var vc: ProductDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProductDetailViewController") as! ProductDetailViewController
            vc.product = searchResults[indexPath.row]
            self.navigationController!.pushViewController(vc, animated: true)
        }
        
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if CommonUtility.isNetworkAvailable() {
            if searchResults.count-1 == indexPath.row {
                page += 1
                if isCallAPI {
                    self.searchProductAPI(searchDisp.searchBar.text, page: "\(page)")
                }
            }
        }
    }
    
    
}
