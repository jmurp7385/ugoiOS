//
//  SelectAddressViewController.swift
//  Ugo
//
//  Created by Sadiq on 19/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit


class SelectAddressViewController: BaseViewController,AddressListViewDelegate ,UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate,UITextViewDelegate{

    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var toolBar: UIToolbar!
    var selectedTxt : AnyObject!
    var dataArray : [AnyObject] = []

    var contactNumber : String?
    var deliveryInstructions : String = ""
    var cart : Cart!
    var shippingMethod : DMShipping?
    var paymentMethod : DMPayment?
    
    var selectedPayment : Payment?
    var selectedShipping : Shipping?
    var selectedDriverTip : DriverTipOptions?
    
    var addresss : [Address] = [Address(),Address()] //Shipping ,Payment
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Billing/Delivery Details"
        contactNumber = self.getFormattedPhoneNumber(userSession.account!.telephone!)
        btnNext.enabled = false
        self.btnNext.alpha = 0.5
        setCloseButton()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    //MARK: Btn Events
    
    @IBAction func btnNextTapped(sender: UIButton) {
        if count(self.convertToNumber(contactNumber!)) == 10 {
            
            self.putAccountAPI()
        }else{
            CommonUtility.showAlertView("Information", message: "Please enter 10 digit Contact number")
        }
    }
    
    func btnSelectAddTapped(sender: UIButton){
        performSegueWithIdentifier("toAddressListViewController", sender: sender)
    }
    
    func addAddressTapped(sender:UIButton){
                
        var vw =  UIApplication.sharedApplication().keyWindow?.topMostController()
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc = storyboard.instantiateViewControllerWithIdentifier("AddAddressViewController") as! AddAddressViewController
        vc.delegate = self
        vc.type = AddressType(rawValue:sender.tag)
        vw!.addChildViewController(vc)
        vc.view.frame = UIScreen.mainScreen().bounds
        vw!.view.addSubview(vc.view)
        vc.didMoveToParentViewController(vw!)
    }
    
   
    // MARK: - Table View Delegates
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sections = 4
        var isShow = false
        if shippingMethod != nil && shippingMethod?.shipping_methods.count > 0{
            sections = sections + 1
            isShow = true
        }
        if paymentMethod != nil && paymentMethod?.payment_methods.count > 0{
            sections = sections + 1
            isShow = true
        }
        
        if isShow {
            sections = sections + 1
        }
        
        //println("sections : \(sections)")
        return sections
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cart.totals.count
        }else{
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0 :
            let cell = tableView.dequeueReusableCellWithIdentifier("TotalTableViewCell") as! TotalTableViewCell
            cell.lblLabel.text = cart.totals[indexPath.row].title!
            cell.lblValue.text = cart.totals[indexPath.row].text!
            
            return cell
            
        case 1 :
            let cell = tableView.dequeueReusableCellWithIdentifier("ContactTableViewCell") as! ContactTableViewCell
            cell.txtContactNo.text = contactNumber
            cell.txtContactNo.tag = 123456
            cell.txtContactNo.delegate = self
            return cell
            
        case 2:
            // Driver Tips
            let cell = tableView.dequeueReusableCellWithIdentifier("SelectBoxCell") as! SelectBoxCell
            cell.txtSelect.delegate = self
            cell.txtSelect.inputAccessoryView = toolBar
            cell.txtSelect.inputView = pickerView
            cell.txtSelect.text = self.selectedDriverTip != nil ? self.selectedDriverTip?.option_text_en : "Select Driver Tip"

            
            return cell
            
        case 3 :
            let cell = tableView.dequeueReusableCellWithIdentifier("SelectAddressCell") as! SelectAddressCell
            cell.lblTitle.text = "Shipping address"
            cell.lblAddress.text = addresss[0].fulladdress
            
            cell.btnGetLocation.tag = AddressType.ShippingWithLocation.rawValue
            cell.btnAddAddress.tag = AddressType.Shipping.rawValue
            cell.btnRecentAddress.tag = AddressType.Shipping.rawValue
            
            cell.btnGetLocation.addTarget(self, action: Selector("addAddressTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnAddAddress.addTarget(self, action: Selector("addAddressTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnRecentAddress.addTarget(self, action: Selector("btnSelectAddTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            
            return cell
        case 4 ,5:
            let cell = tableView.dequeueReusableCellWithIdentifier("SelectBoxCell") as! SelectBoxCell
            cell.txtSelect.delegate = self
            cell.txtSelect.inputAccessoryView = toolBar
            cell.txtSelect.inputView = pickerView
            
            if shippingMethod != nil && shippingMethod?.shipping_methods.count > 0  && indexPath.section != 5{
                cell.txtSelect.text = self.selectedShipping != nil ? self.selectedShipping?.displayString : "Select Shipping Method"
            }else if paymentMethod != nil && paymentMethod?.payment_methods.count > 0 {
                cell.txtSelect.text = self.selectedPayment != nil ? self.selectedPayment?.title : "Select Payment Method"
            }
            
            return cell
            
        case 6 :
            let cell1 = tableView.dequeueReusableCellWithIdentifier("DeliveryInstructionCell") as! DeliveryInstructionCell
            cell1.txtView.backgroundColor = UIColor.whiteColor()
            cell1.txtView.layer.borderWidth = 0.5
            cell1.txtView.layer.borderColor = UIColor.lightGrayColor().CGColor
            cell1.txtView.layer.cornerRadius = 5
            cell1.txtView.delegate = self
            cell1.txtView.inputAccessoryView = toolBar
            cell1.txtView.tag = 654321
            
            return cell1

            
        default:
            return UITableViewCell()
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        switch indexPath.section {
        case 0,1,4,5 :
            return 44
        case 2 :
            if cart.tipOptions.count > 0 {
                return 44
            }else{
                return 0
            }
        case 3 :
            return 110
        case 6 :
            return 110

        default :
            return 0
            
        }
        
    }
    
    
    //MARK: toolbar btn events
    @IBAction func btnCancelTapped(sender: AnyObject) {
        selectedTxt.resignFirstResponder()
    }
    
    @IBAction func btnDoneTapped(sender: AnyObject) {
        
        if selectedTxt .isKindOfClass(UITextField) {
            if dataArray.count > 0{
                var data: AnyObject = dataArray[pickerView.selectedRowInComponent(0)]
                
                if let obj =  data as? Shipping{
                    selectedShipping = obj
                    self.tableView.reloadData()
                }else if let obj =  data as? Payment{
                    selectedPayment = obj
                    self.tableView.reloadData()
                }else if let obj =  data as? DriverTipOptions{
                    selectedDriverTip = obj
                    self.setOptionAPI()
                    self.tableView.reloadData()
                }
                
                if cart.shipping_status! {
                    selectedShipping != nil && selectedPayment != nil ? (self.btnNext.enabled = true,self.btnNext.alpha = 1) : (self.btnNext.enabled = false,self.btnNext.alpha = 0.5)
                }else{
                    self.btnNext.enabled = true
                    self.btnNext.alpha = 1
                }
            }
        }
        
        
        
        selectedTxt.resignFirstResponder()
    }
    
    // MARK: - Text View Delegaate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if textView.tag == 654321 {
            self.deliveryInstructions = textView.text + text
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.selectedTxt = textView
    }
    
    // MARK: - format telephon to number string
    
    func convertToNumber(var phoneNumber : String)-> String{
        phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)

        return phoneNumber
    }
    
    // MARK: - Text Field Delegaate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        selectedTxt.resignFirstResponder()
        return true
    }
    
       
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 123456 {
            
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString : String =  "".join(components)
            let length = count(decimalString)
            let decimalStr = decimalString as NSString
            let hasLeadingOne = length > 0 && decimalStr.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalStr.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalStr.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalStr.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            contactNumber = textField.text
        }
        return false
    }
    
    func getFormattedPhoneNumber(phoneNumber : String)-> String {
        
        let components = phoneNumber.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let decimalString : String =  "".join(components)
        let length = count(decimalString)
        let decimalStr = decimalString as NSString
        let hasLeadingOne = length > 0 && decimalStr.characterAtIndex(0) == (1 as unichar)
        var index = 0 as Int
        let formattedString = NSMutableString()
        if hasLeadingOne
        {
            formattedString.appendString("1 ")
            index += 1
        }
        if (length - index) > 3
        {
            let areaCode = decimalStr.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("(%@)", areaCode)
            index += 3
        }
        if length - index > 3
        {
            let prefix = decimalStr.substringWithRange(NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        
        let remainder = decimalStr.substringFromIndex(index)
        formattedString.appendString(remainder)
        return formattedString as String
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        let pointInTable = textField.convertPoint(textField.bounds.origin, toView: self.tableView)
        let indexpath = self.tableView.indexPathForRowAtPoint(pointInTable)
        
        selectedTxt = textField
        
        if indexpath?.section == 2 {
            cart.tipOptions.sort{
                return $0.group < $1.group
            }
            dataArray = cart.tipOptions
        }else{
            if shippingMethod != nil && shippingMethod!.shipping_methods.count > 0 && indexpath?.section != 5{
                dataArray = shippingMethod!.shipping_methods
            }else if paymentMethod != nil {
                dataArray = paymentMethod!.payment_methods
            }
        }
        
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.reloadAllComponents()
        
    }
    
    // MARK:  picker dataSource
    // ^^^^^^^^^^^^^^^^^^^^^^^
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        var title = ""

        if let obj =  dataArray[row] as? Shipping{
            title = "\(obj.title!) - \(obj.quote[0].display_cost!)"
        }else if let obj =  dataArray[row] as? Payment{
            title = "\(obj.title!)"
        }else if let obj =  dataArray[row] as? DriverTipOptions{
            title = "\(obj.option_text_en!)"
        }
        
        return title
        
    }

    // MARK: - API calls
    
    
    func putAccountAPI(){
        if CommonUtility.isNetworkAvailable() {
            
            userSession.account?.telephone = self.convertToNumber(contactNumber!)
            userSession.storeData()
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.PUTAccount(account: userSession.account!)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
//                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    if JSON != nil{
                        var resp = DMAccount(JSON: JSON!)
                        
                        if resp.status {
                            var account = DMAccount(JSON: JSON!)
                            self.userSession.account = account.account
                            self.userSession.storeData()
                            
                            if self.cart.shipping_status! == true {
                                if self.selectedShipping != nil && self.selectedPayment != nil {
                                    self.postShippingMethodAPI()
                                }else{
                                    CommonUtility.showAlertView("Information", message: "Please select shipping / payment method")
                                }
                                
                                
                            }else{
                                if self.selectedPayment != nil {
                                    CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
                                    self.postPaymentMethodAPI()
                                }else{
                                    CommonUtility.showAlertView("Information", message: "Please select payment method")
                                }
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

    
    func setOptionAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTSetOption(option: selectedDriverTip!)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    if JSON != nil{

                    }
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }

    
    func postPaymentAddressAPI(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTPaymentAdd(addresss[1])).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                self.getShippingMethodsAPI()

                if JSON != nil{
                    var resp = BaseJsonModel(JSON: JSON!)
                    if resp.status {
                        
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg)
                    }
                }
                
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    
    func postShippingAddressAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")

            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTShippingAdd(addresss[1])).responseString { _, _, string, _ in
                //println(string)
                }.responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                self.postPaymentAddressAPI()
                if JSON != nil{
                    var resp = BaseJsonModel(JSON: JSON!)
                    if resp.status {
                        
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg)
                    }
                }else{
                }
                
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
      
    }
    
    func getShippingMethodsAPI(){
        
        MINetworkManager.sharedInstance.manager?.request(APIRouter.GETShippingMethods).responseString { _, _, string, _ in
            //println(string)
        }.responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                self.getPaymentMethodsAPI()
            if JSON != nil{
                var resp = DMShipping(JSON: JSON!)

                if resp.status {
                    self.shippingMethod = resp
                }else{
                    CommonUtility.showAlertView("Information", message: resp.errorMsg)
                }
            }else{
            }
            
        }
    }
    
    func getPaymentMethodsAPI(){
        
        MINetworkManager.sharedInstance.manager?.request(APIRouter.GETPaymentMethods).responseString { _, _, string, _ in
            //println(string)
            }.responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
            CommonUtility().hideLoadingIndicator(self.navigationController!.view)
            
            if JSON != nil{
                var resp = DMPayment(JSON: JSON!)
                if resp.status {
                    self.paymentMethod = resp
                    self.tableView.reloadData()

                }else{
                    CommonUtility.showAlertView("Information", message: resp.errorMsg)
                }
            }else{
            }
            
        }
    }

    func postShippingMethodAPI(){
        if CommonUtility.isNetworkAvailable() {
//            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            
            
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTShippingMethods(shipping_method: selectedShipping!.quote[0].code!,comment: deliveryInstructions)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                self.postPaymentMethodAPI()
                if JSON != nil{
                    var resp = BaseJsonModel(JSON: JSON!)
                    if resp.status {
                        
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg)
                    }
                }
                
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    func postPaymentMethodAPI(){
        //println("Payment Method -> \(selectedPayment!.code!)")
        if CommonUtility.isNetworkAvailable() {
            
            MINetworkManager.sharedInstance.manager?.request(APIRouter.POSTPaymentMethods(payment_method: selectedPayment!.code!,comment: deliveryInstructions)).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                

                self.getCheckoutConfirmAPI()
                if JSON != nil{
                    var resp = BaseJsonModel(JSON: JSON!)
                    if resp.status {
                        
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg)
                    }
                }
                
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    
    func getCheckoutConfirmAPI(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETConfirm).responseString { _, _, string, _ in
                if let str = string {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                
                CommonUtility().hideLoadingIndicator(self.navigationController!.view)

                if JSON != nil{
                    var resp = Cart(JSON: JSON!)
                    if resp.status {
                        
                        var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ConfirmOrderViewController") as! ConfirmOrderViewController
                        vc.order = resp
                        self.navigationController!.pushViewController(vc, animated: true)
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg)
                    }
                }
                
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
  
    
    func addressSelected(type: AddressType, address: Address) {
        switch type {
        case AddressType.Shipping , AddressType.ShippingWithLocation:
            addresss[0] = address
            addresss[1] = address

        case AddressType.Billing :
            addresss[1] = address
            
        default :
            print("")
        }
        if cart.shipping_status! == true {
            postShippingAddressAPI()
        }else{
            
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            postPaymentAddressAPI()
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toAddressListViewController" {
            var vc = segue.destinationViewController as! AddressListViewController
            vc.delegate = self
            vc.addressType = AddressType(rawValue: sender!.tag)
        }
    }
}
