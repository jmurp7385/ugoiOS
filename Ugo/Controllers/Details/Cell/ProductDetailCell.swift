//
//  ProductDetailCell.swift
//  Ugo
//
//  Created by Sadiq on 11/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit
import Alamofire
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ProductDetailCell: UITableViewCell ,UIAlertViewDelegate, SelectQtyViewControllerDelegate{
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblModel: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblStockStatus: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
    
    var product : Product!
    @IBOutlet weak var btnAddtoCart: UIButton!
    
    @IBAction func btnAddToCartTapped(_ sender: UIButton) {
        

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
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postAddtoCart(product)).responseString { string in
                //let str = string
                    //println(str)
                
                }.responseJSON { JSON in
                CommonUtility().hideLoadingIndicator(self.window!)
                //                    //println(JSON!)
                let response = DMCart(JSON: JSON as AnyObject)
                
                if response.status {
                    UserSessionInformation.sharedInstance.cartCount = response.cart.products.count
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "setbadge"), object: nil)
                    
                    
                }else{
                    if response.errors[0].code == "error" {
                    CommonUtility.showAlertView("Information", message: "This product cannot be added to cart because of additional options. Please contact support.")
                    }else{
                        //CommonUtility.showAlertView("We're sorry...", message: response.errors[0].message!)
                        CommonUtility.showAlertView("We're sorry...", message: response.errors[0].message! as NSString)
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
    
    func receivedSelectedQty(_ sku: String) {
        //print("receivedSelectedQty \(sku)")
        if let stock = Int(product.stock_status!) {
            if stock >= Int(sku) {
                product.quantity = Int(sku)
                btnSelectQty.setTitle("Quantity   \(sku)", for: UIControlState())
            }else{
                CommonUtility.showAlertView("Information", message: "No stock for product or the minimum quantity requirement of a product is not met.")
            }
        }
        
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            let count = alertView.textField(at: 0)?.text
            
            if let ct = Int(count!) {
                product.quantity = ct
                btnSelectQty.setTitle("Quantity   \(ct)", for: UIControlState())

            }
            
            
        }
    }
    
    @IBAction func btnSelectQtyTapped(_ sender: UIButton) {
        
//        var alert = UIAlertView(title: "Select Quantity", message: "", delegate: self, cancelButtonTitle: "OK")
//        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
//        alert.textFieldAtIndex(0)?.keyboardType = UIKeyboardType.NumberPad
//        alert.show()
        
        
        let vw =  UIApplication.shared.keyWindow?.rootViewController
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let quantity = storyboard.instantiateViewController(withIdentifier: "SelectQtyViewController") as! SelectQtyViewController
        
        quantity.delegate = self
        quantity.product = product
        vw!.addChildViewController(quantity)
        quantity.view.frame = UIScreen.main.bounds
        vw!.view.addSubview(quantity.view)
        quantity.didMove(toParentViewController: vw!)
        
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        btnSelectQty.backgroundColor = self.backgroundColor
        btnSelectQty.layer.shadowColor = UIColor.black.cgColor
        btnSelectQty.layer.shadowOpacity = 0.5
        btnSelectQty.layer.shadowRadius = 0.8
        
        btnSelectQty.layer.shadowOffset = CGSize(width: 0.5 , height: 0.5)
        btnSelectQty.layer.cornerRadius = 3
        
        
    }
    
    
    class func cell() -> ProductDetailCell
    {
        let nib = Bundle.main.loadNibNamed("ProductDeatilCell", owner: self, options: nil)
        //let nib:NSArray = Bundle.mainBundle.loadNibNamed("ProductDetailCell", owner: self, options: nil)
        
        let cell = nib?.first as? ProductDetailCell
        //let cell = nib.object(at: 0) as? ProductDetailCell
        return cell!
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    class func heightForCell(_ str:String?) -> CGFloat
    {
        var str = str
        let cell = ProductDetailCell.cell()
        if str == nil {
            str = " "
        }
        cell.lblDescription.setHTMLFromString(str!)
        
        let rect = cell.lblDescription.attributedText?.boundingRect(with: CGSize(width: ScreenSize.SCREEN_WIDTH - 32, height: 10000), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        
        cell.lblDescription.sizeToFit()
        _ = cell.lblDescription.frame.height
        //let lblHt = cell.lblDescription.frame.height
        
        return rect!.height
    }
    
    
    
}
