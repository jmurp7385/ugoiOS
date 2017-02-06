//
//  Shipping.swift
//  Ugo
//
//  Created by Sadiq on 24/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class Quote: NSObject {
    var code : String?
    var title : String?
    var cost : Int?
    var display_cost : String?
    
    init(dict : [String:AnyObject]) {
        code = dict["code"] as? String
        title = dict["title"] as? String
        cost = dict["cost"] as? Int
        display_cost = dict["display_cost"] as? String
    }
}

class Shipping: NSObject {
    var title : String?
    var quote : [Quote] = []
    var error : String?
    var displayString : String {
        return "\(title!) - \(quote[0].display_cost!)"
    }
    init(dict : [String:AnyObject]) {
        title = dict["title"] as? String
        error = dict["error"] as? String

        if let arr = dict["quote"] as? NSArray {
            for obj in arr {
                quote.append(Quote(dict: obj as! [String : AnyObject]))
            }
        }
    }
}

class DMShipping: BaseJsonModel {
    var shipping_methods : [Shipping] = []
    override init(JSON: AnyObject) {
        super.init(JSON: JSON)
        
        if status {
            if let arr = infoDict!["shipping_methods"] as? NSArray {
                for dict in arr {
                    shipping_methods.append(Shipping(dict: dict as! [String : AnyObject]))
                }
            }
        }
    }
}


class Payment: NSObject {

    var code : String?
    var title : String?
    var terms : String?
    
    init(dict : [String:AnyObject]) {
        code = dict["code"] as? String
        title = dict["title"] as? String
        terms = dict["terms"] as? String
        
        if code == "pp_express" {
            title = "Credit Card"
        }else
        if code == "pp_pro" {
            title = "Debit/Credit Card"
        }

    }
}

class DMPayment: BaseJsonModel {
    var payment_methods : [Payment] = []
    override init(JSON: AnyObject) {
        super.init(JSON: JSON)
        
        if status {
            if let arr = infoDict!["payment_methods"] as? NSArray {
                for dict in arr {
                    payment_methods.append(Payment(dict: dict as! [String : AnyObject]))
                }
            }
        }
    }
}
