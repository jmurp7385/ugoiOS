//
//  ProductDetailCell.swift
//  Ugo
//
//  Created by Sadiq on 11/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class ProductDetailCell: UITableViewCell ,UIAlertViewDelegate, SelectQtyViewControllerDelegate{
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblModel: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblStockStatus: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
    
    var product : Product!
    @IBOutlet weak var btnAddtoCart: UIButton!
    
    @IBAction func btnAddToCartTapped(sender: UIButton) {
        

        if product.quantity != nil && product.quantity != 0{
            addToCartAPI()
        }else{
            CommonUtility.showAlertView("Information", message: "Please enter quantity")
        }
    }
    
    @IBOutlet weak var btnSelectQty: UIButton!
    
    
    // MARK: - API calls
    
    func addToCartAPI(){
        if CommonUtility.isNetworkAvailable() {
            
            CommonUtility().showLoadingWithMessage(self.window!, message: "Adding product to cart...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTAddtoCart(product)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                CommonUtility().hideLoadingIndicator(self.window!)
                //                    //println(JSON!)
                var response = DMCart(JSON: JSON!)
                
                if response.status {
                    UserSessionInformation.sharedInstance.cartCount = response.cart.products.count
                    NSNotificationCenter.defaultCenter().postNotificationName("setbadge", object: nil)
                    
                    
                }else{
                    if response.errors[0].code == "error" {
                    CommonUtility.showAlertView("Information", message: "This product cannot be added to cart because of additional options. Please contact support.")
                    }else{
                        CommonUtility.showAlertView("We're sorry...", message: response.errors[0].message!)
                        
                    }
                }
                
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //    override func didMoveToSuperview() {
    //        super.didMoveToSuperview()
    //        self.layoutIfNeeded()
    //    }
    
    func receivedSelectedQty(sku: String) {
        //print("receivedSelectedQty \(sku)")
        if let stock = product.stock_status?.toInt() {
            if stock >= sku.toInt() {
                product.quantity = sku.toInt()
                btnSelectQty.setTitle("Quantity   \(sku)", forState: UIControlState.Normal)
            }else{
                CommonUtility.showAlertView("Information", message: "No stock for product or the minimum quantity requirement of a product is not met.")
            }
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            var count = alertView.textFieldAtIndex(0)?.text
            
            if let ct = count?.toInt() {
                product.quantity = ct
                btnSelectQty.setTitle("Quantity   \(ct)", forState: UIControlState.Normal)

            }
            
            
        }
    }
    
    @IBAction func btnSelectQtyTapped(sender: UIButton) {
        
//        var alert = UIAlertView(title: "Select Quantity", message: "", delegate: self, cancelButtonTitle: "OK")
//        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
//        alert.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.NumberPad
//        alert.show()
        
        
        var vw =  UIApplication.sharedApplication().keyWindow?.rootViewController
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var quantity = storyboard.instantiateViewControllerWithIdentifier("SelectQtyViewController") as! SelectQtyViewController
        
        quantity.delegate = self
        quantity.product = product
        vw!.addChildViewController(quantity)
        quantity.view.frame = UIScreen.mainScreen().bounds
        vw!.view.addSubview(quantity.view)
        quantity.didMoveToParentViewController(vw!)
        
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        btnSelectQty.backgroundColor = self.backgroundColor
        btnSelectQty.layer.shadowColor = UIColor.blackColor().CGColor
        btnSelectQty.layer.shadowOpacity = 0.5
        btnSelectQty.layer.shadowRadius = 0.8
        
        btnSelectQty.layer.shadowOffset = CGSizeMake(0.5 , 0.5)
        btnSelectQty.layer.cornerRadius = 3
        
        
    }
    
    
    class func cell() -> ProductDetailCell
    {
        var nib:NSArray = NSBundle.mainBundle().loadNibNamed("ProductDetailCell", owner: self, options: nil)
        var cell = nib.objectAtIndex(0) as? ProductDetailCell
        return cell!
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    class func heightForCell(var str:String?) -> CGFloat
    {
        var cell = ProductDetailCell.cell()
        if str == nil {
            str = " "
        }
        cell.lblDescription.setHTMLFromString(str!)
        
        var rect = cell.lblDescription.attributedText.boundingRectWithSize(CGSizeMake(ScreenSize.SCREEN_WIDTH - 32, 10000), options: NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading, context: nil)
        
        cell.lblDescription.sizeToFit()
        var lblHt = cell.lblDescription.frame.height
        
        return rect.height
    }
    
    
    
}
