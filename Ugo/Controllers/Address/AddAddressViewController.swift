//
//  AddAddressViewController.swift
//  Ugo
//
//  Created by Sadiq on 21/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit
import CoreLocation

class AddAddressViewController: BaseViewController ,CLLocationManagerDelegate,UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate{
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bgContentView: UIView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var txtAdd1: UITextField!
    @IBOutlet weak var txtAdd2: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtPostCode: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtZone: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton!
    let locationManager = CLLocationManager()
    
    var selectedTxt : UITextField!
    var dataArray : [AnyObject]! = []
    
    
    
    var delegate : AddressListViewDelegate!
    var type : AddressType!
    var address : Address!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        address = Address()
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(AddAddressViewController.Done(_:)))
        self.bgView.gestureRecognizers = [gesture]
        scrollView.contentSize = CGSize(width: 300, height: 400)
        
        txtCountry.inputAccessoryView = toolBar
        txtCountry.inputView = pickerView
        txtZone.inputAccessoryView = toolBar
        txtZone.inputView = pickerView
        
        txtCountry.text = "United States"
        self.address.country_id = 223
        self.getZonesAPI("\(self.address.country_id!)")
        
        
        if type.rawValue > 1 {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            if (locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))) {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.startUpdatingLocation()
        }
        
        
        btnSubmit._गोल_करा(5)
        scrollView.layer.cornerRadius = 10
        bgContentView.layer.shadowColor = UIColor.black.cgColor
        bgContentView.layer.shadowOpacity = 1
        bgContentView.layer.shadowRadius = 5
        
        bgContentView.layer.shadowOffset = CGSize(width: 1 , height: 1)
        bgContentView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    //MARK:- Btn Events
    
    @IBAction func btnSubmitTapped(_ sender: UIButton) {
        address.firstname = userSession.account?.firstname
        address.lastname = userSession.account?.lastname
        address.address_1 = self.txtAdd1.text
        address.address_2 = self.txtAdd2.text
        address.postcode = self.txtPostCode.text
        address.city = self.txtCity.text
        
        if address.validate {
            //println(address.geocode_add)
            let addressPoint = geoCodeUsingAddress(address.geocode_add!)
            let currentLoc = CLLocation(latitude: addressPoint.latitude, longitude: addressPoint.longitude)
            let distanceKM = (currentLoc.distance(from: storePoint) / 1000)
            let distMiles = distanceKM * 0.6214
            
            //println("distanceKM : \(distanceKM)  distMiles : \(distMiles)")
            
            //println("storeDistRadius : \(storeDistRadius)")
            if distMiles < storeDistRadius {
                self.Done(nil)
                self.delegate.addressSelected(type, address: self.address)

            }else{
                CommonUtility.showAlertView("Information", message: "We do not deliver to your location")
            }
            
            
        }else{
            CommonUtility.showAlertView("Information", message: "Please enter all the details")
        }
    }
    
    //MARK: toolbar btn events
    @IBAction func btnCancelTapped(_ sender: AnyObject) {
        selectedTxt.resignFirstResponder()
    }
    
    @IBAction func btnDoneTapped(_ sender: AnyObject) {
        
        if dataArray.count > 0{
            let loc: AnyObject = dataArray[pickerView.selectedRow(inComponent: 0)]
            if selectedTxt == txtCountry {
                self.txtCountry.text = loc.name!
                self.address.country_id = (loc as! Country).country_id!
                self.getZonesAPI("\(self.address.country_id!)")
                self.address.zone_id = nil
            } else{
                self.txtZone.text = loc.name!
                self.address.zone_id = (loc as! Zone).zone_id!
            }
        }
        
        selectedTxt.resignFirstResponder()
    }
    
    //MARK:- gesture function
    func Done(_ sender:UITapGestureRecognizer?){
        let vw =  UIApplication.shared.keyWindow?.topMostController()
        let vc = vw!.childViewControllers.last as? AddAddressViewController
        vc?.willMove(toParentViewController: nil)
        vc?.view.removeFromSuperview()
        vc?.removeFromParentViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Location delegates
    //added @nonobjc
    @nonobjc func locationManager(_ manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //println("did update \(locations)")
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                //println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0] as CLPlacemark!
                self.displayLocationInfo(pm!)
            } else {
                //println("Problem with the data received from geocoder")
            }
        })
        
        
    }
    
    func displayLocationInfo(_ placemark: CLPlacemark) {
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        
        //        ddress dictionary properties
        //        var name: String! { get } // eg. Apple Inc.
        //        var thoroughfare: String! { get } // street address, eg. 1 Infinite Loop
        //        var subThoroughfare: String! { get } // eg. 1
        //        var locality: String! { get } // city, eg. Cupertino
        //        var subLocality: String! { get } // neighborhood, common name, eg. Mission District
        //        var administrativeArea: String! { get } // state, eg. CA
        //        var subAdministrativeArea: String! { get } // county, eg. Santa Clara
        //        var postalCode: String! { get } // zip code, eg. 95014
        //        var ISOcountryCode: String! { get } // eg. US
        //        var country: String! { get } // eg. United States
        //        var inlandWater: String! { get } // eg. Lake Tahoe
        //        var ocean: String! { get } // eg. Pacific Ocean
        //        var areasOfInterest: [AnyObject]! { get } // eg. Golden Gate Park
        
        
        self.txtAdd1.text = placemark.name // + "," + placemark.thoroughfare
        self.txtAdd2.text = placemark.subLocality
        self.txtCity.text = placemark.locality
        self.txtPostCode.text =  placemark.postalCode
        
        //        delegate.addressAdded(type, address: add)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //println(error.description)
    }
    
    
    func geoCodeUsingAddress(_ add : String) -> CLLocationCoordinate2D {
        var latitude : Double = 0
        var longitude : Double = 0
        var esc_addr = add.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) //String.Encoding.utf8 to .urlHostAllowed
        var str = "http://maps.google.com/maps/api/geocode/json?sensor=false&address=\(esc_addr!)"
        var result = String(contentsOf: URL(string: str)!, encoding: String.Encoding.utf8, error: nil)
        var scanner = Scanner(string: result!)
        if scanner.scanUpToString("\"lat\" :", intoString: nil) && scanner.scanString("\"lat\" :", intoString: nil)
        {
            scanner.scanDouble(&latitude)
        }
        if scanner.scanUpToString("\"lng\" :", intoString: nil) && scanner.scanString("\"lng\" :", intoString: nil)
        {
            scanner.scanDouble(&longitude)
        }
        
        
        var center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //println(center.latitude)
        //println(center.longitude)
        return center
        
    }
    
    
    // MARK: - Text Field Delegaate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectedTxt.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        selectedTxt = textField
        if textField == txtCountry {
            dataArray = userSession.appInit.countries
            self.txtCountry.text = ""
            self.txtZone.text = ""
            pickerView.selectRow(0, inComponent: 0, animated: false)
            pickerView.reloadAllComponents()
            
        } else {
        }
        
    }
    
    // MARK: - API calls
    
    
    
    
    func getZonesAPI(_ country_id:String){
        if CommonUtility.isNetworkAvailable() {
            
            CommonUtility().showLoadingWithMessage(self.navigationController!.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.getCountryZones(country_id: country_id)).responseString { _, _, string, _ in
                if string != nil {
                    //println(str)
                }
                }.responseJSON { _, _, JSON, _ in
                    CommonUtility().hideLoadingIndicator(self.navigationController!.view)
                    if JSON != nil{
                        let resp = Country(JSON: JSON!)
                        if resp.status {
                            self.dataArray = resp.zones
                            self.pickerView.selectRow(0, inComponent: 0, animated: false)
                            self.pickerView.reloadAllComponents()
                        }else{
                            CommonUtility.showAlertView("Information", message: resp.errorMsg as NSString)
                        }
                        
                    }
                    
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
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
        
        //        if selectedTxt == txtCountry {
        //            return dataArray[row].name
        //        } else {
        return dataArray[row].name
        //        }
        
    }
}
