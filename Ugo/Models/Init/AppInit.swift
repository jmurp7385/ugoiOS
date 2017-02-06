//
//  Languages.swift
//  Ugo
//
//  Created by Sadiq on 03/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

struct Language {
    var name : String
    var code : String
    var image : String
}

struct Currency {
    var title : String
    var code : String
    var symbol : String
}

class Zone: NSObject {
    var zone_id  :Int?
    var name : String?
    var code : String?
    
    init(dict: NSDictionary) {
        zone_id = dict["zone_id"] as? Int
        name = dict["name"] as? String
        code = dict["code"] as? String
    }
}

class Country : BaseJsonModel {
    var country_id  :Int?
    var name : String?
    var iso_code_2 : String?
    var iso_code_3 : String?
    var address_format : String?
    var postcode_required : Bool?
    var zones : [Zone] = []    
    
    init(dict: NSDictionary) {
        super.init()
        country_id = dict["country_id"] as? Int
        name = dict["name"] as? String
        iso_code_2 = dict["iso_code_2"] as? String
        iso_code_3 = dict["iso_code_3"] as? String
        address_format = dict["address_format"] as? String
        postcode_required = dict["postcode_required"] as? Bool
        
        if let arr = dict["zones"] as? NSArray {
            for dict1 in arr {
                zones.append(Zone(dict: dict1 as! NSDictionary))
            }
        }

    }
    
    override init(JSON: AnyObject) {
        super.init(JSON: JSON)
        
        if status {
            if let dict = infoDict!["country"] as? NSDictionary {
                country_id = dict["country_id"] as? Int
                name = dict["name"] as? String
                iso_code_2 = dict["iso_code_2"] as? String
                iso_code_3 = dict["iso_code_3"] as? String
                address_format = dict["address_format"] as? String
                postcode_required = dict["postcode_required"] as? Bool
                
                if let arr = dict["zones"] as? NSArray {
                    for dict1 in arr {
                        zones.append(Zone(dict: dict1 as! NSDictionary))
                    }
                }
            }           
            
        }
    }
    
}

struct Settings {
    var store_title : String
    var store_name : String
    var store_owner : String
    var store_address : String
    var store_email : String
    var store_telephone : String
    var store_fax : String
    var store_logo : String
    var display_product_count : String
    var default_customer_group_id : String
    var account_terms : String
    var guest_checkout_allowed : String
    var checkout_terms : String
    var no_stock_checkout : Bool
}

struct Wishlist {
    
}

class AppInit: BaseJsonModel {
    var languages : [Language] = []
    var currencies : [Currency] = []
    var countries : [Country] = []
    var settings : Settings!
    var cart : Cart!
    var wishlist : Wishlist!    
    
    override init(JSON : AnyObject) {
        super.init(JSON: JSON)
        let info = JSON as? NSDictionary
        if let arr = info?.objectForKey("countries") as? NSArray {
            for dict in arr{
                countries.append(Country(dict: dict as! NSDictionary))
            }
        }
        
        var dmcart = DMCart(JSON:  JSON)
        self.cart = dmcart.cart
        UserSessionInformation.sharedInstance.cartCount = self.cart.products.count
        NSNotificationCenter.defaultCenter().postNotificationName("setbadge", object: nil)
        
    }
}
