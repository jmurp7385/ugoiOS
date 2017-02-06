//
//  ConfirmOrderViewController.swift
//  Ugo
//
//  Created by Sadiq on 24/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class ConfirmOrderViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var order : Cart!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Confirm Order"
        setCloseButton()
        // Do any additional setup after loading the view.
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - API calls
    
    func getPayAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETPay(access_token: userSession.access_token!)).response { (request, response, data, error) in
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.loadSuccessPage()
                })
                
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    // MARK: - Btn Taps
    @IBAction func btnConfirmTapped(sender: UIButton) {
        if order.needs_payment_now == true {
            var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WebViewViewController") as! WebViewViewController
            vc.strUrl = APIRouter.BASE_URL + "/checkout/pay?SOLUTIONTYPE=Sole&LANDINGPAGE=Billing&access_token=" + userSession.access_token!
            vc.isPayment = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else{
            
            getPayAPI()
        }
    }

    func loadSuccessPage(){

        var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CheckoutSuccessController") as! CheckoutSuccessController
        var nav = UINavigationController(rootViewController: vc)
        UIApplication.sharedApplication().keyWindow?.topMostController()?.presentViewController(nav, animated: true, completion: nil)
    }
    // MARK: - Table View Delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return order.products.count
        }else{
            return order.totals.count
        }

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("ConfirmOrderCell") as! ConfirmOrderCell
            cell.lblTitle.text = order.products[indexPath.row].name!
            cell.lblModel.text = order.products[indexPath.row].model!
            cell.lblQuantity.text = " x \(order.products[indexPath.row].quantity!)"
            cell.lblPrice.text = order.products[indexPath.row].price!
            cell.lblTotal.text = order.products[indexPath.row].total!
            return cell
        }else{
            var cell = tableView.dequeueReusableCellWithIdentifier("TotalTableViewCell") as! TotalTableViewCell
            cell.lblLabel.text = order.totals[indexPath.row].title!
            cell.lblValue.text = order.totals[indexPath.row].text!
            return cell
        }
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 72
        }else{
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }

}
