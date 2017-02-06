//
//  OrderHistoryViewController.swift
//  Ugo
//
//  Created by Sadiq on 26/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class OrderHistoryViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var dataArray : [Order] = []
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        page = 1
        isCallAPI = true
        
        setCloseButton()
        self.title = "Order History"
        getOrderHistoryAPI()
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table View Delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OrderCell") as! OrderCell

        let obj = dataArray[indexPath.row]
        cell.lblAmount.text = obj.total!
        cell.lblOrderNo.text = "Order No \(obj.order_id!)"
        cell.lblStatus.text = "Your order status \(obj.status!)"
        cell.lblDate.text = obj.date_added!
        cell.lblProductCount.text =  "# of products in order \(obj.productsCount!)"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
         if CommonUtility.isNetworkAvailable() {
            if dataArray.count-1 == indexPath.row {
                page += 1
                if isCallAPI {
                    getOrderHistoryAPI(page: "\(page)")
                }
            }
        }
    }
    // MARK: - API calls
    
    func getOrderHistoryAPI(page : String = ""){
        
        
        //print("page \(page)")
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETOrder(page: page)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                if JSON != nil{
                    var resp = DMOrder(JSON: JSON!)
                    
                    if resp.status {
                        if resp.orderes.count == 0 {
                            self.isCallAPI = false
                        }
                        self.dataArray = self.dataArray.count == 0 ? resp.orderes : self.dataArray + resp.orderes
                        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
