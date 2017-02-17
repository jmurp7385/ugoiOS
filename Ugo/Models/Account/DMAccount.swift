//
//  DMAccount.swift
//  Ugo
//
//  Created by Sadiq on 18/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class Address: NSObject {
    let placeHolderText = " No address"
    var address_id : Int?
    var payment_address : String? {
        return address_id == nil ?  "new" : "existing"
    }
    var shipping_address : String? {
        return address_id == nil ?  "new" : "existing"
    }
    
    var geocode_add : String? {
        return "\(company!), \(address_1!),\(city!),\(zones!)"
    }
    
    var firstname : String? = ""
    var lastname : String? = ""
    var company : String? = ""
    var address_1 : String? = ""
    var address_2 : String? = ""
    var postcode : String? = ""
    var city : String? = ""
    var zone_id : Int?
    var zones : String? = ""
    var zone_code : String? = ""
    var country_id : Int?
    var country : String? = ""
    var iso_code_2 : String? = ""
    var iso_code_3 : String? = ""
    var address_format : String? = ""
    
    var validate : Bool {
        if firstname != "" && lastname != "" && country_id != nil && zone_id != nil && address_1 != "" && postcode != "" && city != ""{
            return true
        }else{
            return false
        }
    }
    
    var fulladdress : String {
        if firstname != "" {
            return "\(firstname!) \(lastname!)\r\n\(address_1!)\r\n\(postcode!) \(city!)\r\n\(country!)"
        }
        return placeHolderText
    }
}

class CustomerGroup: NSObject {
    var customer_group_id : Int?
    var name : String?
    var descriptions : String?
}

class CustomFieldsValue: NSObject {
    var custom_field_value_id: Int?
    var name: String?
}

class CustomFields: NSObject {
    
    var custom_field_id : Int?
    var custom_field_value: [CustomFieldsValue] = []
    var name : String?
    var type : String?
    var value : String?
    var required : Bool?
    
}

class Account: NSObject {
    
    var customer_id : Int?
    var firstname : String? = ""
    var lastname : String?
    var email : String? = ""
    var telephone : String?
    var fax : String? = ""
    var custom_fields : [CustomFields] = []
    var newsletter : String?
    var reward_points : Int?
    var balance : String?
    var password : String?
    
    var fb : String?
    
    var customer_group : CustomerGroup?
    
}

class DMAccount: BaseJsonModel {
    var account = Account()
    var addresses : [Address] = []
    override init(JSON : AnyObject) {
        super.init(JSON: JSON)
        if status {
            if let dict = infoDict!["account"] as? NSDictionary {
                
                if let arr1 = dict.object(forKey: "custom_fields") as? [[String : Any]] { //NSArray{
                    for dict1 in arr1 {
                        let cust = CustomFields()
                        cust.custom_field_id = dict1["firstname"] as? Int
                        if ((arr1 as AnyObject).object(forKey: "custom_field_value") as? [[String : Any]]) != nil { //NSArray{
                            for dict2 in arr1 {
                                let value = CustomFieldsValue()
                                value.custom_field_value_id = dict2["custom_field_value_id"] as? Int
                                value.name = dict2["name"] as? String
                                cust.custom_field_value.append(value)
                            }
                            cust.name = dict1["name"] as? String
                            cust.type = dict1["type"] as? String
                            cust.value = dict1["value"] as? String
                            cust.required = dict1["required"] as? Bool
                            self.account.custom_fields.append(cust)
                        }
                    }
                }
                
                account.firstname = dict["firstname"] as? String
                account.lastname = dict["lastname"] as? String
                account.email = dict["email"] as? String
                account.telephone = dict["telephone"] as? String
                account.fax = dict["fax"] as? String
                account.newsletter = dict["newsletter"] as? String
                account.reward_points = dict["reward_points"] as? Int
                account.balance = dict["balance"] as? String
                
                if let cid = dict["customer_id"] as? Int {
                    account.customer_id = cid
                }else if let cid = dict["customer_id"] as? String {
                    account.customer_id = Int(cid)
                }
                
                if let obj: AnyObject = dict["customer_id"] as AnyObject?{
                    let customer_group = CustomerGroup()
                    customer_group.customer_group_id = obj["customer_group_id"] as? Int
                    customer_group.name = obj["name"] as? String
                    customer_group.descriptions = obj["descriptions"] as? String
                    account.customer_group = customer_group
                }
                
            }else if let arr = infoDict!["addresses"] as? [[String : Any]] { //NSArray {
                for obj in arr {
                    let address = Address()
                    address.address_id = obj["address_id"] as? Int
                    address.firstname = obj["firstname"] as? String
                    address.lastname = obj["lastname"] as? String
                    address.company = obj["company"] as? String
                    address.address_1 = obj["address_1"] as? String
                    address.address_2 = obj["address_2"] as? String
                    address.postcode = obj["postcode"] as? String
                    address.city = obj["city"] as? String
                    address.zone_id = obj["zone_id"] as? Int
                    address.zones = obj["zones"] as? String
                    address.zone_code = obj["zone_code"] as? String
                    address.country = obj["country"] as? String
                    address.country_id = obj["country_id"] as? Int
                    address.iso_code_2 = obj["iso_code_2"] as? String
                    address.iso_code_3 = obj["iso_code_3"] as? String
                    address.address_format = obj["address_format"] as? String
                    
                    if address.address_1 != "NAA" {
                        addresses.append(address)
                    }
                }
            }
        }
        
    }
    
}


class Order: NSObject {
    var order_id  : Int? = 0
    var name  : String? = ""
    var status  : String? = ""
    var date_added  : String?
    var productsCount  : Int?
    var total  : String?
    
    var products : [Product] = []
    var detailStr : String {
        return "order_id : \(order_id!) \n Product \(name!)  \n Status \(status!)"
    }
    
    init(dict : NSDictionary) {
        order_id = dict["order_id"] as? Int
        name = dict["name"] as? String
        status = dict["status"] as? String
        date_added = dict["date_added"] as? String
        total = dict["total"] as? String
        
        if let count = dict["products"] as? Int {
            productsCount = count
        }else if let arr = dict["total"] as? NSArray
        {
            products = CommonParse.parseProducts(arr)
        }
        
    }
}

class DMOrder: BaseJsonModel {
    var orderes : [Order] = []
    
    override init(JSON: AnyObject) {
        super.init(JSON: JSON)
        if status {
            if let arr = infoDict!["orders"] as? NSArray {
                for dict in arr {
                    orderes.append(Order(dict: dict as! NSDictionary))
                }
            }
            
        }
    }
    
}
