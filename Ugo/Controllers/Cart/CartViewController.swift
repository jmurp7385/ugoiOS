//
//  CartViewController.swift
//  Ugo
//
//  Created by Sadiq on 17/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class CartViewController: BaseViewController ,SWTableViewCellDelegate , SelectQtyViewControllerDelegate{
    
    @IBOutlet weak var btnCheckout: UIButton!
    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var table: UITableView!
    
    var cart : DMCart!
    var products : [Product] = []
    var selectedIndex : Int = 1
    
    
    // MARK: - Btn Events
    
    @IBAction func btnCheckoutTapped(_ sender: UIButton) {
        if userSession.isLoggedIn {
            
            if let warning = self.cart.cart.error_warning {
                CommonUtility.showAlertView("Information", message: warning as NSString)
            }else{
                performSegue(withIdentifier: "toSelectAddressViewController", sender: nil)
            }
        }else{
            let nav: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginNav") as! UINavigationController
            
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    
    func receivedSelectedQty(_ sku: String) {
        //print("receivedSelectedQty \(sku)")
        //        btnSelectQty.setTitle(sku, forState: UIControlState.Normal)
        
        let product = products[selectedIndex]
        product.quantity = Int(sku)
        putCartAPI(product.key!, quantity: product.quantity!)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cart"
        tableView.separatorColor = UIColor(r: 65, g: 154, b: 43, a: 1)
        
        getCartAPI()
        setCloseButton()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
//        setCheckoutBtnStatus()
        
        userSession.isLoggedIn ? btnCheckout.setTitle("CHECKOUT", for: UIControlState()) : btnCheckout.setTitle("Login to proceed", for: UIControlState())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setCheckoutBtnStatus(){
        if self.userSession.cartCount > 0 && self.products.count > 0 {
            self.btnCheckout.isEnabled =  true
            self.btnCheckout.alpha = 1
        }else{
            self.btnCheckout.isEnabled =  false
            self.btnCheckout.alpha = 0.5
        }
    }
    // MARK: - API calls
    
    func getCartAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.getCart).responseString { string in
                //let str = string  //if let str = string {
                    //println(str)
                
                }.responseJSON { response in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    if let JSON =  response.result.value {
                    //if JSON != nil {
                        self.cart = DMCart(JSON: JSON as AnyObject)
                        let resp = self.cart
                        if (resp?.status)! {
                            self.products  = self.cart.cart.products
                            self.userSession.cartCount = self.cart.cart.products.count
                            self.tableView.reloadData()
                            
                            if let warning = self.cart.cart.error_warning {
                                CommonUtility.showAlertView("Information", message: warning as NSString)
                            }
                            
                        }else{
                            self.setCheckoutBtnStatus()
                            CommonUtility.showAlertView("We're sorry...", message: resp!.errorMsg as NSString)
                        }
                    }
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    func putCartAPI(_ productKey : String,quantity : Int){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.putCart(key: productKey, quantity: quantity)).responseString { string in
                //let str = string
                    //println(str)
                /*
                }.validate().responseJSON { response in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    self.setBadge()
                    switch response.result {
                    case .success:
                        self.cart = DMCart(JSON: response.result.value as AnyObject)
                        self.products = self.cart.cart.products
                        self.userSession.cartCount = self.cart.cart.products.count
                        self.setCheckoutBtnStatus()
                        self.table.reloadData()
                        if let warning = self.cart.cart.error_warning {
                            CommonUtility.showAlertView("Information", message: warning as NSString)
                        }
                    case .failure:
                        CommonUtility.showAlertView("Information", message: resp!.errorMsg as NSString)
                    }
                */
                }.responseJSON { JSON in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    self.setBadge()
                    self.cart = DMCart(JSON: JSON as AnyObject)
                    let resp = self.cart
                    if JSON != nil {
                        if (resp?.status)! {
                            self.products  = self.cart.cart.products
                            self.userSession.cartCount = self.cart.cart.products.count
                            self.setCheckoutBtnStatus()
                            self.tableView.reloadData()
                            
                            if let warning = self.cart.cart.error_warning {
                                CommonUtility.showAlertView("Information", message: warning as NSString)
                            }
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp!.errorMsg as NSString)
                        }
                    }
                 //   */
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    func deleteCartAPI(_ productKey : String){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.deleteCart(productKey)).responseString { string in
                //let str = string
                    //println(str)
            
                }.responseJSON { JSON in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    
                    if JSON != nil {
                        self.setBadge()
                        self.cart = DMCart(JSON: JSON as AnyObject)
                        
                        if self.cart.status {
                            self.products  = self.cart.cart.products
                            self.userSession.cartCount = self.cart.cart.products.count
                            self.setCheckoutBtnStatus()
                            self.tableView.reloadData()
                            
                            if let warning = self.cart.cart.error_warning {
                                CommonUtility.showAlertView("Information", message: warning as NSString)
                            }
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: self.cart.errorMsg as NSString)
                        }
                    }
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    // MARK: - Table View Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell") as! CartTableViewCell
        let product = products[indexPath.row]
        
        let attributed = NSMutableAttributedString(string: product.name != nil ? product.name! : "")
        
        if !product.in_stock! {
            attributed.append(NSAttributedString(string: " ***", attributes: [NSForegroundColorAttributeName:UIColor.red,NSBaselineOffsetAttributeName:2,NSFontAttributeName: UIFont.systemFont(ofSize: 15)]))
        }
        
        
        cell.lblTitle.attributedText = attributed
        cell.lblDescription.text = product.model != nil ? product.model! : ""
        cell.lblPrice.text = product.price != nil ? "\(product.price!)    x" : ""
        cell.btnSelectQty.setTitle("\(product.quantity!)", for: UIControlState())
        cell.imgProduct.af_setImage(withURL: URL(string: product.thumb_image!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed)!)!, placeholderImage: UIImage(named: "loading"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: UIImageView.ImageTransition.noTransition, runImageTransitionIfCached: true, completion: nil)
        cell.btnSelectQty.tag = indexPath.row
        cell.btnSelectQty.addTarget(self, action: #selector(CartViewController.btnSelectQtyTapped(_:)), for: UIControlEvents.touchUpInside)
        
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
        cell.delegate = self
        
        return cell
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = UIColor(r: 228, g: 228, b: 228, a: 1)
        
        let label = UILabel(frame: CGRect(x: 20, y: 4, width: ScreenSize.SCREEN_WIDTH-20, height: 21))
        
        let attStr = NSMutableAttributedString(string: "Cart Subtotal: ", attributes: [NSForegroundColorAttributeName:colorGray,NSFontAttributeName:font15r])
        
        attStr.append(NSAttributedString(string: "(\(products.count) items) ", attributes:  [NSForegroundColorAttributeName:colorGray,NSFontAttributeName:font14r]))
        
        if cart != nil && cart.cart.products.count > 0 {
            attStr.append(NSAttributedString(string: "\(cart.cart.totals[cart.cart.totals.count-1].text!)", attributes:  [NSForegroundColorAttributeName:colorGreen,NSFontAttributeName:font15r]))
        }
        label.attributedText = attStr
        
        view.addSubview(label)
        return view
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    
    //MARK:- Swipable delegates
    
    //MARK:- SWCell
    
    func rightButtons()->NSArray
    {
        let rightUtilityButtons:NSMutableArray = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButton(with: UIColor.clear, title: "Delete")
        return rightUtilityButtons
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        //print("called")
        deleteCartAPI(products[tableView.indexPath(for: cell)!.row].key!)
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, scrollingTo state: SWCellState) {
        
        switch state
        {
        case SWCellState.cellStateCenter :
            //println("utility buttons closed")
            break
        case SWCellState.cellStateLeft :
            //println("left utility buttons open")
            break
        case SWCellState.cellStateRight :
            //println("right utility buttons open")
            break
        default:
            break
        }
    }
    
    
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool
    {
        return true
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, canSwipeTo state: SWCellState) -> Bool
    {
        
        switch (state) {
        case SWCellState.cellStateLeft:
            // set to NO to disable all left utility buttons appearing
            return true;
            
        case SWCellState.cellStateRight:
            // set to NO to disable all right utility buttons appearing
            return true;
            
        default:
            
            break;
        }
        return true;
    }
    
    //MARK:- Alert Delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        let count = alertView.textField(at: 0)?.text
        let product = products[alertView.tag]
        
        if Int(count!) != nil {
            product.quantity = Int(count!)
            putCartAPI(product.key!, quantity: product.quantity!)
        }
        //        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: alertView.tag, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    @IBAction func btnSelectQtyTapped(_ sender: UIButton) {
        
        //        var alert = UIAlertView(title: "Select Quantity", message: "", delegate: self, cancelButtonTitle: "OK")
        //        alert.tag = sender.tag
        //        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        //        alert.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.NumberPad
        //        alert.show()
        
        
        
        let vw =  self.navigationController?.topViewController
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let quantity = storyboard.instantiateViewController(withIdentifier: "SelectQtyViewController") as! SelectQtyViewController
        
        quantity.delegate = self
        quantity.product = products[sender.tag]
        selectedIndex = sender.tag
        vw!.addChildViewController(quantity)
        quantity.view.frame = UIScreen.main.bounds
        vw!.view.addSubview(quantity.view)
        quantity.didMove(toParentViewController: vw!)
        
    }
    
    //MARK: navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectAddressViewController{
            vc.cart = cart.cart
        }
    }
    
}
