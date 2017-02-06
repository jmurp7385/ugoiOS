//
//  AddressListViewController.swift
//  Ugo
//
//  Created by Sadiq on 19/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

protocol AddressListViewDelegate{
    func addressSelected(type:AddressType,address:Address)
}

class AddressListViewController: BaseViewController,SWTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var addresses : [Address] = []
    var addressType : AddressType!
    var delegate : AddressListViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Address"
        setBackButton()
        getAddressAPI()
        
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
        return addresses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AddressListCell") as! AddressListCell
        
        let add = addresses[indexPath.row]
        cell.lblAddress.text = add.fulladdress
        cell.lblAddress.font = font12r
        cell.lblAddress.numberOfLines = 0
        
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
        cell.delegate = self
        return cell
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let add = addresses[indexPath.row]
        var label : UILabel = UILabel(frame: CGRectMake(16, 0, (ScreenSize.SCREEN_WIDTH - 32), 10))
        label.numberOfLines = 0
        label.text = add.fulladdress
        label.font = font12r
        return label.expectedHeight()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if delegate != nil {
            delegate.addressSelected(addressType, address: addresses[indexPath.row])
        }
        
        self.navigationController?.popViewControllerAnimated(true)
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
        //println("Index \(index) \(tableView.indexPathForCell(cell)?.row)")
        deleteAddresssAPI(tableView.indexPathForCell(cell)!.row)
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
    
    // MARK: - API calls
    
    func deleteAddresssAPI(index : Int){
        
        var address_id = addresses[index].address_id!
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.DELETEAddress(address_id: address_id)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    if JSON != nil {
                        var obj = BaseJsonModel(JSON: JSON!)
                        
                        if obj.status {
                        }else{
                            CommonUtility.showAlertView("Information", message: obj.errorMsg)
                        }
                    }else{
                        self.addresses.removeAtIndex(index)
                        self.tableView.reloadData()
                        
                    }
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    func getAddressAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETAddress).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    if JSON != nil{
                        var resp = DMAccount(JSON: JSON!)
                        if resp.status {
                            self.addresses = resp.addresses
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
    
}
