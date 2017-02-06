//
//  CartViewController.swift
//  Ugo
//
//  Created by Sadiq on 17/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class CartViewController: BaseViewController ,SWTableViewCellDelegate , SelectQtyViewControllerDelegate{
    
    @IBOutlet weak var btnCheckout: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var cart : DMCart!
    var products : [Product] = []
    var selectedIndex : Int = 1
    
    
    // MARK: - Btn Events
    
    @IBAction func btnCheckoutTapped(sender: UIButton) {
        if userSession.isLoggedIn {
            
            if let warning = self.cart.cart.error_warning {
                CommonUtility.showAlertView("Information", message: warning)
            }else{
                performSegueWithIdentifier("toSelectAddressViewController", sender: nil)
            }
        }else{
            var nav: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("loginNav") as! UINavigationController
            
            self.presentViewController(nav, animated: true, completion: nil)
        }
    }
    
    
    func receivedSelectedQty(sku: String) {
        //print("receivedSelectedQty \(sku)")
        //        btnSelectQty.setTitle(sku, forState: UIControlState.Normal)
        
        var product = products[selectedIndex]
        product.quantity = sku.toInt()
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
    
    
    override func viewWillAppear(animated: Bool) {
//        setCheckoutBtnStatus()
        
        userSession.isLoggedIn ? btnCheckout.setTitle("CHECKOUT", forState: UIControlState.Normal) : btnCheckout.setTitle("Login to proceed", forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setCheckoutBtnStatus(){
        if self.userSession.cartCount > 0 && self.products.count > 0 {
            self.btnCheckout.enabled =  true
            self.btnCheckout.alpha = 1
        }else{
            self.btnCheckout.enabled =  false
            self.btnCheckout.alpha = 0.5
        }
    }
    // MARK: - API calls
    
    func getCartAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETCart).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    if JSON != nil {
                        self.cart = DMCart(JSON: JSON!)
                        var resp = self.cart
                        if resp.status {
                            self.products  = self.cart.cart.products
                            self.userSession.cartCount = self.cart.cart.products.count
                            self.tableView.reloadData()
                            
                            if let warning = self.cart.cart.error_warning {
                                CommonUtility.showAlertView("Information", message: warning)
                            }
                            
                        }else{
                            self.setCheckoutBtnStatus()
                            CommonUtility.showAlertView("We're sorry...", message: resp.errorMsg)
                        }
                    }
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    func putCartAPI(productKey : String,quantity : Int){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.PUTCart(key: productKey, quantity: quantity)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    self.setBadge()
                    self.cart = DMCart(JSON: JSON!)
                    var resp = self.cart
                    if JSON != nil {
                        if resp.status {
                            self.products  = self.cart.cart.products
                            self.userSession.cartCount = self.cart.cart.products.count
                            self.setCheckoutBtnStatus()
                            self.tableView.reloadData()
                            
                            if let warning = self.cart.cart.error_warning {
                                CommonUtility.showAlertView("Information", message: warning)
                            }
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg)
                        }
                    }
                    
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    func deleteCartAPI(productKey : String){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.DELETECart(productKey)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    
                    if JSON != nil {
                        self.setBadge()
                        self.cart = DMCart(JSON: JSON!)
                        
                        if self.cart.status {
                            self.products  = self.cart.cart.products
                            self.userSession.cartCount = self.cart.cart.products.count
                            self.setCheckoutBtnStatus()
                            self.tableView.reloadData()
                            
                            if let warning = self.cart.cart.error_warning {
                                CommonUtility.showAlertView("Information", message: warning)
                            }
                            
                        }else{
                            CommonUtility.showAlertView("Information", message: self.cart.errorMsg)
                        }
                    }
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    // MARK: - Table View Delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CartTableViewCell") as! CartTableViewCell
        var product = products[indexPath.row]
        
        var attributed = NSMutableAttributedString(string: product.name != nil ? product.name! : "")
        
        if !product.in_stock! {
            attributed.appendAttributedString(NSAttributedString(string: " ***", attributes: [NSForegroundColorAttributeName:UIColor.redColor(),NSBaselineOffsetAttributeName:2,NSFontAttributeName: UIFont.systemFontOfSize(15)]))
        }
        
        
        cell.lblTitle.attributedText = attributed
        cell.lblDescription.text = product.model != nil ? product.model! : ""
        cell.lblPrice.text = product.price != nil ? "\(product.price!)    x" : ""
        cell.btnSelectQty.setTitle("\(product.quantity!)", forState: UIControlState.Normal)
        
        cell.imgProduct.setImageWithUrl(NSURL(string: product.thumb_image!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!, placeHolderImage: UIImage(named: "loading"))
        cell.btnSelectQty.tag = indexPath.row
        cell.btnSelectQty.addTarget(self, action: Selector("btnSelectQtyTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
        cell.delegate = self
        
        return cell
        
    }
    
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var view = UIView()
        view.backgroundColor = UIColor(r: 228, g: 228, b: 228, a: 1)
        
        let label = UILabel(frame: CGRectMake(20, 4, ScreenSize.SCREEN_WIDTH-20, 21))
        
        var attStr = NSMutableAttributedString(string: "Cart Subtotal: ", attributes: [NSForegroundColorAttributeName:colorGray,NSFontAttributeName:font15r])
        
        attStr.appendAttributedString(NSAttributedString(string: "(\(products.count) items) ", attributes:  [NSForegroundColorAttributeName:colorGray,NSFontAttributeName:font14r]))
        
        if cart != nil && cart.cart.products.count > 0 {
            attStr.appendAttributedString(NSAttributedString(string: "\(cart.cart.totals[cart.cart.totals.count-1].text!)", attributes:  [NSForegroundColorAttributeName:colorGreen,NSFontAttributeName:font15r]))
        }
        label.attributedText = attStr
        
        view.addSubview(label)
        return view
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    
    
    //MARK:- Swipable delegates
    
    //MARK:- SWCell
    
    func rightButtons()->NSArray
    {
        var rightUtilityButtons:NSMutableArray = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.clearColor(), title: "Delete")
        return rightUtilityButtons
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        //print("called")
        deleteCartAPI(products[tableView.indexPathForCell(cell)!.row].key!)
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, scrollingToState state: SWCellState) {
        
        switch state
        {
        case SWCellState.CellStateCenter :
            //println("utility buttons closed")
            break
        case SWCellState.CellStateLeft :
            //println("left utility buttons open")
            break
        case SWCellState.CellStateRight :
            //println("right utility buttons open")
            break
        default:
            break
        }
    }
    
    
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool
    {
        return true
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool
    {
        
        switch (state) {
        case SWCellState.CellStateLeft:
            // set to NO to disable all left utility buttons appearing
            return true;
            
        case SWCellState.CellStateRight:
            // set to NO to disable all right utility buttons appearing
            return true;
            
        default:
            
            break;
        }
        return true;
    }
    
    //MARK:- Alert Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        var count = alertView.textFieldAtIndex(0)?.text
        var product = products[alertView.tag]
        
        if let ct = count?.toInt() {
            product.quantity = count?.toInt()
            putCartAPI(product.key!, quantity: product.quantity!)
        }
        //        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: alertView.tag, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        
    }
    
    @IBAction func btnSelectQtyTapped(sender: UIButton) {
        
        //        var alert = UIAlertView(title: "Select Quantity", message: "", delegate: self, cancelButtonTitle: "OK")
        //        alert.tag = sender.tag
        //        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        //        alert.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.NumberPad
        //        alert.show()
        
        
        
        var vw =  self.navigationController?.topViewController
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var quantity = storyboard.instantiateViewControllerWithIdentifier("SelectQtyViewController") as! SelectQtyViewController
        
        quantity.delegate = self
        quantity.product = products[sender.tag]
        selectedIndex = sender.tag
        vw!.addChildViewController(quantity)
        quantity.view.frame = UIScreen.mainScreen().bounds
        vw!.view.addSubview(quantity.view)
        quantity.didMoveToParentViewController(vw!)
        
    }
    
    //MARK: navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SelectAddressViewController{
            vc.cart = cart.cart
        }
    }
    
}
