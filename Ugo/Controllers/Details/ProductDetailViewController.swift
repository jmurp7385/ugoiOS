//
//  ProductDetailViewController.swift
//  Ugo
//
//  Created by Sadiq on 10/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class ProductDetailViewController: BaseViewController , UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblModel: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblStockStatus: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    var product : Product!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSearchButtonWithCart(true)
        setBackButton()
        
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            self.tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 60.0
        }
        
        productDetailAPI()
        //        searchProductAPI()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.setBadge()
    }
    
    override func setbadgeNotif(){
        setBadge()
    }
    // MARK: - API calls
    
    func productDetailAPI(){
        if CommonUtility.isNetworkAvailable() {
            var product_id = "\(product.product_id!)"
            self.showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETProductDetail(product_id)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }
                .responseJSON { _, _, JSON, _ in
                    self.hideLoadingIndicator(self.navigationController!.view)
                    
                    
                    if JSON != nil {
                        var resp = DMProduct(JSON: JSON!)
                        
                        if resp.status {
                            self.product = resp.product
                            self.product.quantity = 1
                            self.tableView.reloadData()
                            
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
            if self.product.related_products.count > 0 {
                return 2
            }else{
                return 1
            }
        }else{
            return super.numberOfSectionsInTableView(tableView)
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
            return  super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let label = UILabel()
            label.backgroundColor = UIColor(r: 228, g: 228, b: 228, a: 1)
            label.font = UIFont(name: "Roboto-Medium", size: 15)
            label.textColor = UIColor(r: 68, g: 144, b: 54, a: 1)
            label.text = "   You may also like"
            
            return label
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView != searchDisp.searchResultsTableView {
            return 1
        }else{
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    
    
    func heightForView(var text:String?, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        if text == nil {
            text = " "
        }
        label.setHTMLFromString(text!)
        
        label.sizeToFit()
        return label.frame.height
    }
    
    //    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
    //            return UITableViewAutomaticDimension
    //        }else{
    //            return 420 + heightForView(product.descriptions, font: UIFont.systemFontOfSize(15), width: ScreenSize.SCREEN_WIDTH - 32)
    //        }
    //    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView != searchDisp.searchResultsTableView {
            
            switch indexPath.section {
            case 0 :
                
                if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
                    return UITableViewAutomaticDimension
                }else{
                    var cell =  ProductDetailCell.cell()
                    //println(product.descriptions)
                    
                    
                    return 410 + ProductDetailCell.heightForCell(product.descriptions)
                    //                    return 420 + heightForView(product.descriptions, font: UIFont.systemFontOfSize(15), width: ScreenSize.SCREEN_WIDTH - 32)
                }
                
            case 1 :
                return 150
                
            default:
                return 44
            }
        }else{
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView != searchDisp.searchResultsTableView {
            
            if indexPath.section == 0 && indexPath.row == 0 {
                var cell = tableView.dequeueReusableCellWithIdentifier("ProductDetailCell") as? ProductDetailCell
                if cell == nil {
                    cell = ProductDetailCell.cell()
                }
                cell!.product = product
                
                var str = product.descriptions != nil ? product.descriptions! : ""
                
                cell!.lblTitle.text = product.title != nil ? product.title! : ""
                cell!.lblModel.text = product.model != nil ? product.model! : ""
                cell!.lblPrice.text = product.price != nil ? product.price! : ""
                
                
                if let stock = product.stock_status?.toInt() {
                    cell!.btnAddtoCart.enabled = true
                    cell!.btnAddtoCart.alpha = 1
                    cell!.lblStockStatus.text = "Total \(stock) in Stock"
                }else{
                    cell!.btnAddtoCart.enabled = false
                    cell!.btnAddtoCart.alpha = 0.6
                    cell!.lblStockStatus.text = product.stock_status != nil ? product.stock_status! : ""
                }
                
                cell!.imgProduct.setImageWithUrl(NSURL(string: product.image != nil ? product.image!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)! : "")!, placeHolderImage: UIImage(named: "loading"))
                
                cell!.lblDescription.setHTMLFromString(str)
                
                cell!.lblDescription.sizeToFit()
                return cell!
                
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ProductListCell") as! ProductListCell
                cell.products = product.related_products
                cell.loadingView.stopAnimating()
                
                return cell
            }
        }else{
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    
}
