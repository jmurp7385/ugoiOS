//
//  AddressListViewController.swift
//  Ugo
//
//  Created by Sadiq on 19/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

protocol AddressListViewDelegate{
    func addressSelected(_ type:AddressType,address:Address)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressListCell") as! AddressListCell
        
        let add = addresses[indexPath.row]
        cell.lblAddress.text = add.fulladdress
        cell.lblAddress.font = font12r
        cell.lblAddress.numberOfLines = 0
        
        cell.rightUtilityButtons = self.rightButtons() as [AnyObject]
        cell.delegate = self
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let add = addresses[indexPath.row]
        let label : UILabel = UILabel(frame: CGRect(x: 16, y: 0, width: (ScreenSize.SCREEN_WIDTH - 32), height: 10))
        label.numberOfLines = 0
        label.text = add.fulladdress
        label.font = font12r
        return label.expectedHeight()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if delegate != nil {
            delegate.addressSelected(addressType, address: addresses[indexPath.row])
        }
        
        //self.navigationController?.popViewController(animated: true)          //said it is not used
    }
    
    
    //MARK:- Swipable delegates
    
    //MARK:- SWCell
    
    func rightButtons()->NSArray
    {
        let rightUtilityButtons:NSMutableArray = NSMutableArray()
        rightUtilityButtons.sw_addUtilityButton(with: UIColor.clear, title: "Delete")
        
        return rightUtilityButtons
    }
    
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {        //added '_'
        //print("called")
        //println("Index \(index) \(tableView.indexPathForCell(cell)?.row)")
        deleteAddresssAPI(tableView.indexPath(for: cell)!.row)
    }
    
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, scrollingTo state: SWCellState) {         //added '_'
        
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
    
    // MARK: - API calls
    
    func deleteAddresssAPI(_ index : Int){
        
        let address_id = addresses[index].address_id!
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.deleteAddress(address_id: address_id)).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    
                    if JSON != nil {
                        let obj = BaseJsonModel(JSON: JSON!)
                        
                        if obj.status {
                        }else{
                            CommonUtility.showAlertView("Information", message: obj.errorMsg as NSString)
                        }
                    }else{
                        self.addresses.remove(at: index)
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
            MINetworkManager.sharedInstance.manager?.request(APIRouter.getAddress).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    if JSON != nil{
                        let resp = DMAccount(JSON: JSON!)
                        if resp.status {
                            self.addresses = resp.addresses
                            self.tableView.reloadData()
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                        }
                    }
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
}
