//
//  CheckoutSuccessController.swift
//  Ugo
//
//  Created by Sadiq on 25/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class CheckoutSuccessController: BaseViewController {
    @IBOutlet weak var btnContinue: UIButton!

    @IBOutlet weak var lblText: UITextView!

    @IBAction func btnContinueTapped(sender: UIButton) {
        self.btnCloseTappedFromBase()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Order Placed"
        lblText.layer.borderColor = UIColor.lightGrayColor().CGColor
        lblText.layer.borderWidth = 1
        lblText.layer.cornerRadius = 7
        lblText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        setCloseButton()
        getSuccessAPI()
        // Do any additional setup after loading the view.
    }

    override func btnCloseTappedFromBase(){
        (UIApplication.sharedApplication().delegate as! AppDelegate).initVC()
        UIApplication.sharedApplication().keyWindow?.topMostController()?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - API calls
    
    func getSuccessAPI(){
        if CommonUtility.isNetworkAvailable() {
            CommonUtility().showLoadingWithMessage(self.view, message: "Loading...")
            MINetworkManager.sharedInstance.manager?.request(APIRouter.GETSuccess).response { (request, response, data, error) in
                self.userSession.cartCount = 0
                CommonUtility().hideLoadingIndicator(self.view)
            }
            
        }else{
            CommonUtility.showAlertView("Network Unavailable", message: "Please check your internet connectivity and try again.")
        }
    }
  

}
