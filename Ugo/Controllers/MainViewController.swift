

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
    
    var scrollTimer : Timer!
    
    @IBOutlet weak var tableView: UITableView!
    // MARK: button Events
    func btnMenuTapped(_ sender: UIBarButtonItem) {
        self.revealViewController().revealToggle(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UserDefaults.standard.bool(forKey: "isOverlayShown") {
            showOverlay("Help")
            UserDefaults.standard.set(true, forKey: "isOverlayShown")
        }
        
        let menuBtn = createBarButton("menu", actionName: "btnMenuTapped:")
        let logo = UIBarButtonItem(customView: UIImageView(image: UIImage(named: "logo")))
        self.navigationItem.leftBarButtonItems = [menuBtn,logo]
        addSearchButtonWithCart(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.didSelectCell(_:)), name: NSNotification.Name(rawValue: "didSelectCell"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.endOfProductList(_:)), name: NSNotification.Name(rawValue: "endOfProductList"), object: nil)
        
        
        
        
        specialProductAPI()
        getCategoriesAPI()
        
    }
    
    
    
    
    deinit{
        //print("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBadge()
    }
    
    //MARK:- Help
    func showOverlay(_ img:String){
        let view = UIView(frame: UIScreen.main.bounds)
        let imageview = UIImageView(frame: view.frame)
        imageview.image = UIImage(named: img)
        view.tag = 1001
        view.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(MainViewController.helpDone))]
        view.addSubview(imageview)
        self.navigationController?.view.addSubview(view)
        
    }
    
    func helpDone(){
        self.navigationController?.view.viewWithTag(1001)?.removeFromSuperview()
    }
    
    override func setbadgeNotif(){
        setBadge()
    }
    
    func didSelectCell(_ notification:Notification){
        self.performSegue(withIdentifier: "productDetail", sender: notification.object)
    }
    
    func endOfProductList(_ notification:Notification){
        
        let cate = notification.object as! Category
        getProductsForCartAPI(cate.index!,page: "\(cate.page)")
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "productDetail":
            let productDetailViewController = segue.destination as! ProductDetailViewController
            productDetailViewController.product = sender as! Product
        default:
            break
            
        }
    }
    
    
    func specialProductAPI(){
        if CommonUtility.isNetworkAvailable() {
            
            MINetworkManager.sharedInstance.manager?.request(APIRouter.getSpecialProducts).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { a, res, JSON, c in
                    println(res?.statusCode)
                    
                    if res?.statusCode == 401 {
                        var userSession = UserSessionInformation.sharedInstance
                        userSession.access_token = nil
                        userSession.storeData()
                        (UIApplication.shared.delegate as! AppDelegate).getTokenAPIGeneral()
                    }else{
                        if JSON != nil {
                            var resp = DMProduct(JSON: JSON!)
                            
                            if resp.status {
                                self.products = resp.products
                                self.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
                                
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
            MINetworkManager.sharedInstance.manager?.request(APIRouter.getCategories).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, res, JSON, _ in
                    
                    if JSON != nil {
                        if res?.statusCode == 401 {
                            var userSession = UserSessionInformation.sharedInstance
                            userSession.access_token = nil
                            userSession.storeData()
                            (UIApplication.shared.delegate as! AppDelegate).getTokenAPIGeneral()
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
    
    func getProductsForCartAPI(_ section: Int, page : String){
        
        if CommonUtility.isNetworkAvailable() {
            //println("Section \(section) products API Call")
            
            
            
            var cat_id = "\(categories[section-1].category_id!)"
            MINetworkManager.sharedInstance.manager?.request(APIRouter.getProducts(limit: nil, page: page, cat_id: cat_id)).responseString { _, _, string, _ in
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
                            self.tableView.reloadSections(IndexSet(integer: section), with: UITableViewRowAnimation.automatic)
                            
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if tableView != searchDisp.searchResultsTableView {
            return  categories.count + 1
        }else{
            return super.numberOfSections(in: searchDisp.searchResultsTableView)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView != searchDisp.searchResultsTableView {
            return 1
        }else{
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView != searchDisp.searchResultsTableView {
            if indexPath.section == 0 && indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pageCell") as! PageTableViewCell
                cell.products = products
                return cell
                
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell") as! ProductListCell
                var category = categories[indexPath.section-1]
                cell.products = category.products
                category.index = indexPath.section
                cell.category = category
                
                
                if !categories[indexPath.section-1].isLoaded {
                    cell.lblMsg.isHidden = true
                    getProductsForCartAPI(indexPath.section,page: "1")
                    cell.loadingView.startAnimating()
                    
                }else{
                    if cell.products != nil {
                        if cell.products.count == 0 {
                            cell.lblMsg.isHidden = false
                        }else{
                            cell.lblMsg.isHidden = true
                        }
                    }
                    cell.loadingView.stopAnimating()
                }
                return cell
            }
        }else{
            return super.tableView(tableView: tableView, cellForRowAtIndexPath: indexPath)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView != searchDisp.searchResultsTableView {
            
            if section == 0 {
                return nil
            } else {
                var view = UIView()
                view.backgroundColor = UIColor(r: 228, g: 228, b: 228, a: 1)
                
                let label = UILabel(frame: CGRect(x: 8, y: 4, width: ScreenSize.SCREEN_WIDTH-20, height: 21))
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    
}
