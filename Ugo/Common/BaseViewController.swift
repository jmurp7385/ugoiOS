//
//  BaseViewController.swift
//  Tokri
//
//  Created by Shardul on 29/04/15.
//  Copyright (c) 2015 Xstpl. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class BaseViewController: UITableViewController, /*UIViewController,*/ UISearchBarDelegate, UISearchDisplayDelegate/*, UITableViewDelegate,UITableViewDataSource*/{
    
    var searchDisp:UISearchController!
    
    var reachability : Reachability!
    
    var page = 1
    var isCallAPI : Bool = true
    
    var cartBtn : BBBadgeBarButtonItem!
    var userSession : UserSessionInformation!
    var loadingView:MBProgressHUD! = MBProgressHUD()
    var searchResults : [Product] = []
    func showLoadingWithMessage(_ onView:UIView, message:String) {
        loadingView = MBProgressHUD(view: onView)
        onView.addSubview(loadingView)
        loadingView.labelText = message
        loadingView.show(true)
    }
    
    func hideLoadingIndicator(_ onView:UIView) {
        MBProgressHUD.hide(for: onView, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchDisp = UISearchController(searchResultsController: nil) // added
//        searchDisp.searchResultsUpdater = self
        //searchDisp = UISearchController(nibName: UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20)), bundle: self)
        self.view.addSubview(searchDisp.searchBar)
        searchDisp.searchBar.isHidden = true
//        searchDisp.searchResultsDataSource = self
//        searchDisp.searchResultsDelegate = self
        searchDisp.searchBar.delegate = self
//        searchDisp.delegate = self
//        searchDisp.searchResultsTableView.rowHeight = UITableViewAutomaticDimension

//        searchDisp.searchResultsTableView.estimatedRowHeight = 60
        searchDisp.searchBar.tintColor = UIColor.black
        
        userSession = UserSessionInformation.sharedInstance
        //        setBadge
//        searchDisp.searchResultsTableView.separatorColor = UIColor(r: 65, g: 154, b: 43, a: 1)
        searchDisp.searchBar.barTintColor = UIColor.black
        searchDisp.searchBar.tintColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.handleNetworkChange(_:)), name: NSNotification.Name(rawValue: kReachabilityChangedNotification), object: nil)
        reachability = Reachability.forInternetConnection()
        reachability.startNotifier()
        
        
        let revealController:SWRevealViewController? = self.revealViewController()
        
        if revealController != nil {
            revealController!.panGestureRecognizer()
            revealController!.tapGestureRecognizer()
        }
        
        
        self.edgesForExtendedLayout = UIRectEdge()
        NotificationCenter.default.addObserver(self, selector: Selector(("removeAddWishListChildViewController")), name: NSNotification.Name(rawValue: "removeAddWishListChildViewController"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.setbadgeNotif), name: NSNotification.Name(rawValue: "setbadge"), object: nil)
        
    }
    
    func setbadgeNotif(){
        
    }
    
    func handleNetworkChange(_ notification:Notification){
        
    }
    
    
    func removeActionbtn(){
        
    }
    
    
    
    
    func setBadge(){
        
        let count = userSession.cartCount
        
        if count != 0 && cartBtn != nil {
            cartBtn.badgeValue = "\(count)"
            cartBtn.badgeTextColor = UIColor.black
            cartBtn.badgeBGColor = UIColor.white
            cartBtn.badgeFont = UIFont.systemFont(ofSize: 10)
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
    
    func createButtonForNav(_ menu: barMenu) -> UIButton{
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        var name = ""
        
        switch menu {
        case barMenu.sidemenu:
            name = "menu"
            btn.addTarget(self, action: Selector(("menuTapped")), for: UIControlEvents.touchUpInside)
            break;
        case barMenu.logo:
            name = "topbar_logo"
            btn.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
            btn.addTarget(self, action: Selector(("logoTapped:")), for: UIControlEvents.touchUpInside)
            break;
        case barMenu.tokri:
            name = "tokri"
            btn.addTarget(self, action: Selector(("tokriTapped:")), for: UIControlEvents.touchUpInside)
            break;
        case barMenu.user:
            name = "user"
            btn.addTarget(self, action: Selector(("userTapped:")), for: UIControlEvents.touchUpInside)
            break;
        case barMenu.search:
            name = "search"
            btn.addTarget(self, action: Selector(("searchTapped:")), for: UIControlEvents.touchUpInside)
            break;
        default :
            break;
        }
        btn.setImage(UIImage(named: name), for: UIControlState())
        return btn
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackButton() {
        self.navigationItem.leftBarButtonItem = customBarBtn(25, height: 25, imgName: "icon_back", actionName: "btnBackTappedFromBase")
    }
    
    func setCloseButton(_ isleft : Bool = true) {
        if isleft {
            self.navigationItem.leftBarButtonItem = customBarBtn(25, height: 25, imgName: "web_close", actionName: "btnCloseTappedFromBase")
        }else{
            self.navigationItem.rightBarButtonItem = customBarBtn(25, height: 25, imgName: "web_close", actionName: "btnCloseTappedFromBase")
        }
    }
    
    func createBarButton(_ imgName:String, actionName:String) -> UIBarButtonItem {
        let menuBtn = UIBarButtonItem(image: UIImage(named: imgName), style: UIBarButtonItemStyle.plain, target: self, action:
            Selector(actionName))
        menuBtn.tintColor = UIColor.white
        
        return menuBtn
    }
    
    func customBarBtn(_ width:CGFloat, height:CGFloat, imgName:String, actionName:String) -> UIBarButtonItem {
        let replyBtn = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        replyBtn.setImage(UIImage(named: imgName), for: UIControlState())
        replyBtn.addTarget(self, action: Selector(actionName), for:  UIControlEvents.touchUpInside)
        
        return UIBarButtonItem(customView: replyBtn)
    }
    
    // MARK: Search API
    
    func searchProductAPI(_ searchText : String,page: String){
        if CommonUtility.isNetworkAvailable() {
            self.showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.getSearchProduct(limit: "\(searchLimit)", page: page, order: nil, sort: nil, search: searchText, descriptions: nil)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    MBProgressHUD.hideAllHUDs(for: self.navigationController!.view, animated: true)
                    
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
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = []
        
        if searchText == "" {
            page = 1
            isCallAPI = true
        }
        if searchText.characters.count > 2 {
            searchProductAPI(searchText, page: "1")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchDisp.searchBar.isHidden = true
    }
    
    @nonobjc func searchDisplayControllerDidBeginSearch(_ controller: UISearchController) {
        searchDisp.searchBar.isHidden = false
    }
    
    @nonobjc func searchDisplayControllerDidEndSearch(_ controller: UISearchController) {
        
    }
    
    @nonobjc func searchDisplayControllerWillEndSearch(_ controller: UISearchController) {
        searchDisp.searchBar.isHidden = true
    }
    
    func addSearchButtonWithCart(_ chk:Bool) {
        
        let searchBtn = createBarButton("search", actionName: "btnSearchTapped:")
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        btn.addTarget(self, action: #selector(BaseViewController.btnCartTapped(_:)), for: UIControlEvents.touchUpInside)
        btn.setImage(UIImage(named: "cart"), for: UIControlState())
        
        cartBtn = BBBadgeBarButtonItem(customUIButton: btn)
        
        cartBtn.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItems = chk ? [cartBtn,searchBtn] : [searchBtn]
    }
    
    // MARK: - Btn Taps
    func btnBackTappedFromBase() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func btnCloseTappedFromBase() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func btnCartTapped(_ sender:AnyObject) {
        let vc: CartViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
        
    }
    
    // Search disp
    func btnSearchTapped(_ sender:AnyObject) {
        searchDisp.searchBar.becomeFirstResponder()
        searchDisp.searchBar.isHidden = false
        
        page = 1
        isCallAPI = true
    }
    
    // MARK: - Table View Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {      //added override to every fun below this
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchResults.count > 0 {
            tableView.contentInset = UIEdgeInsets.zero
            tableView.scrollIndicatorInsets = UIEdgeInsets.zero
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as? SearchResultCell
            if cell == nil {
                cell = SearchResultCell.cell()
            }
            
            
            let product = searchResults[indexPath.row]
            
            cell!.lblTitle.text = product.name!
            cell!.lblPrice.text = product.price!
            cell!.imgProduct.af_setImage(withUrl: URL(string: product.thumb_image!.addingPercentEscapes(using: String.Encoding.utf8)!)!, placeHolderImage: UIImage(named: "loading"))//setImageWithUrl
            if let description = product.descriptions {
                cell!.lblDescription.text = description.trimWhiteSpaces()
            }
            
            return cell!
            
        }else{
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchResults.count > 0 {
            let vc: ProductDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
            vc.product = searchResults[indexPath.row]
            self.navigationController!.pushViewController(vc, animated: true)
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if CommonUtility.isNetworkAvailable() {
            if searchResults.count-1 == indexPath.row {
                page += 1
                if isCallAPI {
                    self.searchProductAPI(searchDisp.searchBar.text!, page: "\(page)")
                }
            }
        }
    }
    
    
}
