//
//  SelectAddressViewController.swift
//  Ugo
//
//  Created by Sadiq on 19/08/15.
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



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
        btnNext.isEnabled = false
        self.btnNext.alpha = 0.5
        setCloseButton()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    //MARK: Btn Events
    
    @IBAction func btnNextTapped(_ sender: UIButton) {
        if self.convertToNumber(contactNumber!).characters.count == 10 {
           
            self.putAccountAPI()
        }else{
            CommonUtility.showAlertView("Information", message: "Please enter 10 digit Contact number")
        }
    }
    
    func btnSelectAddTapped(_ sender: UIButton){
        performSegue(withIdentifier: "toAddressListViewController", sender: sender)
    }
    
    func addAddressTapped(_ sender:UIButton){
                
        let vw =  UIApplication.shared.keyWindow?.topMostController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
        vc.delegate = self
        vc.type = AddressType(rawValue:sender.tag)
        vw!.addChildViewController(vc)
        vc.view.frame = UIScreen.main.bounds
        vw!.view.addSubview(vc.view)
        vc.didMove(toParentViewController: vw!)
    }
    
   
    // MARK: - Table View Delegates
    
    override func numberOfSections(in tableView: UITableView) -> Int {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cart.totals.count
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalTableViewCell") as! TotalTableViewCell
            cell.lblLabel.text = cart.totals[indexPath.row].title!
            cell.lblValue.text = cart.totals[indexPath.row].text!
            
            return cell
            
        case 1 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
            cell.txtContactNo.text = contactNumber
            cell.txtContactNo.tag = 123456
            cell.txtContactNo.delegate = self
            return cell
            
        case 2:
            // Driver Tips
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectBoxCell") as! SelectBoxCell
            cell.txtSelect.delegate = self
            cell.txtSelect.inputAccessoryView = toolBar
            cell.txtSelect.inputView = pickerView
            cell.txtSelect.text = self.selectedDriverTip != nil ? self.selectedDriverTip?.option_text_en : "Select Driver Tip"

            
            return cell
            
        case 3 :
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectAddressCell") as! SelectAddressCell
            cell.lblTitle.text = "Shipping address"
            cell.lblAddress.text = addresss[0].fulladdress
            
            cell.btnGetLocation.tag = AddressType.shippingWithLocation.rawValue
            cell.btnAddAddress.tag = AddressType.shipping.rawValue
            cell.btnRecentAddress.tag = AddressType.shipping.rawValue
            
            cell.btnGetLocation.addTarget(self, action: #selector(SelectAddressViewController.addAddressTapped(_:)), for: UIControlEvents.touchUpInside)
            cell.btnAddAddress.addTarget(self, action: #selector(SelectAddressViewController.addAddressTapped(_:)), for: UIControlEvents.touchUpInside)
            cell.btnRecentAddress.addTarget(self, action: #selector(SelectAddressViewController.btnSelectAddTapped(_:)), for: UIControlEvents.touchUpInside)
            
            
            return cell
        case 4 ,5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectBoxCell") as! SelectBoxCell
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
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "DeliveryInstructionCell") as! DeliveryInstructionCell
            cell1.txtView.backgroundColor = UIColor.white
            cell1.txtView.layer.borderWidth = 0.5
            cell1.txtView.layer.borderColor = UIColor.lightGray.cgColor
            cell1.txtView.layer.cornerRadius = 5
            cell1.txtView.delegate = self
            cell1.txtView.inputAccessoryView = toolBar
            cell1.txtView.tag = 654321
            
            return cell1

            
        default:
            return UITableViewCell()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

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
    @IBAction func btnCancelTapped(_ sender: AnyObject) {
        selectedTxt.resignFirstResponder()
    }
    
    @IBAction func btnDoneTapped(_ sender: AnyObject) {
        
        if selectedTxt.isKind(of: UITextField.self) {
            if dataArray.count > 0{
                let data: AnyObject = dataArray[pickerView.selectedRow(inComponent: 0)]
                
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
                    selectedShipping != nil && selectedPayment != nil ? (self.btnNext.isEnabled = true,self.btnNext.alpha = 1) : (self.btnNext.isEnabled = false,self.btnNext.alpha = 0.5)
                }else{
                    self.btnNext.isEnabled = true
                    self.btnNext.alpha = 1
                }
            }
        }
        
        
        
        selectedTxt.resignFirstResponder()
    }
    
    // MARK: - Text View Delegaate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.tag == 654321 {
            self.deliveryInstructions = textView.text + text
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.selectedTxt = textView
    }
    
    // MARK: - format telephon to number string
    
    func convertToNumber(_ phoneNumber : String)-> String{
        var phoneNumber = phoneNumber
        phoneNumber = phoneNumber.replacingOccurrences(of: "(", with: "", options: NSString.CompareOptions.literal, range: nil)
        phoneNumber = phoneNumber.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
        phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)

        return phoneNumber
    }
    
    // MARK: - Text Field Delegaate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectedTxt.resignFirstResponder()
        return true
    }
    
       
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 123456 {
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            
            //let decimalString : String =  "".join(components)
            let decimalString : String =  components.joined(separator: "")
            let length = decimalString.characters.count
            let decimalStr = decimalString as NSString
            let hasLeadingOne = length > 0 && decimalStr.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalStr.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalStr.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalStr.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            contactNumber = textField.text
        }
        return false
    }
    
    func getFormattedPhoneNumber(_ phoneNumber : String)-> String {
        
        let components = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted)
        //let decimalString : String =  "".join(components)
        let decimalString : String =  components.joined(separator: "")
        let length = decimalString.characters.count
        let decimalStr = decimalString as NSString
        let hasLeadingOne = length > 0 && decimalStr.character(at: 0) == (1 as unichar)
        var index = 0 as Int
        let formattedString = NSMutableString()
        if hasLeadingOne
        {
            formattedString.append("1 ")
            index += 1
        }
        if (length - index) > 3
        {
            let areaCode = decimalStr.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("(%@)", areaCode)
            index += 3
        }
        if length - index > 3
        {
            let prefix = decimalStr.substring(with: NSMakeRange(index, 3))
            formattedString.appendFormat("%@-", prefix)
            index += 3
        }
        
        let remainder = decimalStr.substring(from: index)
        formattedString.append(remainder)
        return formattedString as String
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tableView)
        let indexpath = self.tableView.indexPathForRow(at: pointInTable)
        
        selectedTxt = textField
        
        if indexpath?.section == 2 {
            cart.tipOptions = cart.tipOptions.sorted{       //added cart.tipOptons =
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
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
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
            MINetworkManager.sharedInstance.manager?.request(APIRouter.putAccount(account: userSession.account!)).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
//                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    if JSON != nil{
                        let resp = DMAccount(JSON: JSON!)
                        
                        if resp.status {
                            let account = DMAccount(JSON: JSON!)
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
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
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
            
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postSetOption(option: selectedDriverTip!)).responseString { _, _, string, _ in
                if string != nil {
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
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postPaymentAdd(addresss[1])).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                self.getShippingMethodsAPI()

                if JSON != nil{
                    let resp = BaseJsonModel(JSON: JSON!)
                    if resp.status {
                        
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
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

            MINetworkManager.sharedInstance.manager?.request(APIRouter.postShippingAdd(addresss[1])).responseString { _, _, string, _ in
                //println(string)
                }.responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                self.postPaymentAddressAPI()
                if JSON != nil{
                    let resp = BaseJsonModel(JSON: JSON!)
                    if resp.status {
                        
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                    }
                }else{
                }
                
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
        
      
    }
    
    func getShippingMethodsAPI(){
        
        MINetworkManager.sharedInstance.manager?.request(APIRouter.getShippingMethods).responseString { _, _, string, _ in
            //println(string)
        }.responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                self.getPaymentMethodsAPI()
            if JSON != nil{
                let resp = DMShipping(JSON: JSON!)

                if resp.status {
                    self.shippingMethod = resp
                }else{
                    CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                }
            }else{
            }
            
        }
    }
    
    func getPaymentMethodsAPI(){
        
        MINetworkManager.sharedInstance.manager?.request(APIRouter.getPaymentMethods).responseString { _, _, string, _ in
            //println(string)
            }.responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
            CommonUtility().hideLoadingIndicator(self.navigationController!.view)
            
            if JSON != nil{
                let resp = DMPayment(JSON: JSON!)
                if resp.status {
                    self.paymentMethod = resp
                    self.tableView.reloadData()

                }else{
                    CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                }
            }else{
            }
            
        }
    }

    func postShippingMethodAPI(){
        if CommonUtility.isNetworkAvailable() {
//            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            
            
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postShippingMethods(shipping_method: selectedShipping!.quote[0].code!,comment: deliveryInstructions)).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                self.postPaymentMethodAPI()
                if JSON != nil{
                    let resp = BaseJsonModel(JSON: JSON!)
                    if resp.status {
                        
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
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
            
            MINetworkManager.sharedInstance.manager?.request(APIRouter.postPaymentMethods(payment_method: selectedPayment!.code!,comment: deliveryInstructions)).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                

                self.getCheckoutConfirmAPI()
                if JSON != nil{
                    let resp = BaseJsonModel(JSON: JSON!)
                    if resp.status {
                        
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                    }
                }
                
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
    
    
    func getCheckoutConfirmAPI(){
        if CommonUtility.isNetworkAvailable() {
            MINetworkManager.sharedInstance.manager?.request(APIRouter.getConfirm).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                
                CommonUtility().hideLoadingIndicator(self.navigationController!.view)

                if JSON != nil{
                    let resp = Cart(JSON: JSON!)
                    if resp.status {
                        
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConfirmOrderViewController") as! ConfirmOrderViewController
                        vc.order = resp
                        self.navigationController!.pushViewController(vc, animated: true)
                    }else{
                        CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                    }
                }
                
            }
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
  
    
    func addressSelected(_ type: AddressType, address: Address) {
        switch type {
        case AddressType.shipping , AddressType.shippingWithLocation:
            addresss[0] = address
            addresss[1] = address

        case AddressType.billing :
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddressListViewController" {
            let vc = segue.destination as! AddressListViewController
            vc.delegate = self
            vc.addressType = AddressType(rawValue: (sender! as AnyObject).tag)
        }
    }
}
