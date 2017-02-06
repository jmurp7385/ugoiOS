//
//  Category.swift
//  Ugo
//
//  Created by Sadiq on 03/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit
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


class Category: NSObject {
    var category_id : Int?
    var name : String?
    var descriptions : String?
    var thumb_image : String?
    var total_products : Int?
    var categories : [Category] = []
    var isLoaded : Bool = false
    var products : [Product]  = []
    
    var page = 1
    var isCallAPI = true
    var scollToIndexPath : IndexPath?
    var index : Int?
}


class Product: NSObject {
    
    var product_id : Int?
    var name : String?
    var descriptions : String?
    var price : String?
    var special : String?
    var tax : String?
    var minimum : String?
    var rating : Int?
    var thumb_image : String?
    
    var categoryName : String?
    
    var title : String?
    var model : String?
    var image : String?
    var images : [Images] = []
    var discounts : [Discount] = []
    var options : [Option] = []
    var manufacturer : String?
    var reward_points : Int?
    var reward_points_needed_to_buy : Int?
    var attribute_groups : [AttributesGrp] = []
    var minimum_quantity : Int?
    var stock_status : String?
    var related_products : [Product] = []
    var reviews  : String?
    var review_enabled : Bool?
    var recurrings: [Recurring] = []
    
    //cart
    var key  : String?
    var recurring  : String?
    var quantity  : Int? = 1
    var reward  : String?
    var total  : String?
    var in_stock  : Bool?
}

class Images: NSObject {
    var image : String?
    var thumb_image : String?
}

class Discount: NSObject {
    var price : String?
    var quantity : Int?
}

class Option: NSObject {
    var name : String?
    var option_id : Int?
    var product_option_id : Int?
    var product_option_value : [ProductOptionValue] = []
    var required : Bool?
    var type : String?
    var value : String?
}

class ProductOptionValue: NSObject {
    var product_option_value_id : Int?
    var option_value_id : Int?
    var name : String?
    var image : String?
    var price : String?
    var price_prefix : String?
}


class AttributesGrp: NSObject {
    
    var attribute: [Attribute] = []
    var attribute_group_id : Int?
    var name : String?
    
}

class Attribute: NSObject {
    var attribute_id : Int?
    var name : String?
    var text : String?
}

class Recurring: NSObject {
    
}

class Totals: NSObject {
    var title : String?
    var text : String?
    
    init(dict:[String:AnyObject]) {
        title = dict["title"] as? String
        text = dict["text"] as? String
        title = title!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

    }
}

class Cart: BaseJsonModel {
    var products : [Product] = []
    var vouchers : [Product] = []
    var totals : [Totals] = []
    
    
    var tipOptions : [DriverTipOptions] = []

    var weight : String?
    var coupon_status : Bool?
    var coupon : String?
    var voucher_status : Bool?
    var voucher : String?
    var reward_status : Bool?
    var reward : Int?
    var max_reward_points_to_use : Int?
    var shipping_status : Bool?
    var error_warning : String?
    
    var payment_information : String?
    var needs_payment_now : Bool?
    
    
    override init() {
        super.init()
    }
    
    override init(JSON: AnyObject) {
        super.init(JSON: JSON)
        if status {
            if let dict = infoDict!["order"] as? NSDictionary {
                if let arr = dict["products"] as? NSArray{
                    products =  CommonParse.parseProducts(arr)
                    
                }
                if let arr = dict["vouchers"] as? NSArray{
                    
                }
                if let arr = dict["totals"] as? NSArray{
                    for obj in arr{
                        totals.append(Totals(dict: obj as! [String : AnyObject]))
                    }
                }
                
                payment_information = dict["payment_information"] as? String
                needs_payment_now = dict["needs_payment_now"] as? Bool
            }
        }
    }
}

class DMCart: BaseJsonModel {
    var cart :Cart = Cart()
    
    override init(JSON : AnyObject) {
        super.init(JSON: JSON)
        if status {
            if let dict = infoDict!["cart"] as? NSDictionary {
                if let obj = dict.object(forKey: "products") as? NSArray{
                    cart.products = CommonParse.parseProducts(obj)                    
                }
                
                if let arr = dict["totals"] as? NSArray{
                    for dict1 in arr {
                        cart.totals.append(Totals(dict: dict1 as! [String : AnyObject]))
                    }
                }
                
                cart.weight = dict["weight"] as? String
                cart.coupon_status = dict["coupon_status"] as? Bool
                cart.coupon = dict["coupon"] as? String
                cart.voucher = dict["voucher"] as? String
                cart.voucher_status = dict["voucher_status"] as? Bool
                cart.reward_status = dict["reward_status"] as? Bool
                cart.reward = dict["reward"] as? Int
                cart.max_reward_points_to_use = dict["max_reward_points_to_use"] as? Int
                cart.shipping_status = dict["shipping_status"] as? Bool
                cart.error_warning = dict["error_warning"] as? String
                
            }
            
            if let dict1 = infoDict!["optional_fee_discount"] as? NSDictionary {
                if let dict2 = dict1["settings"] as? NSDictionary {
                    if let dict3 = dict2["charge"] as? NSDictionary {
                        
                        for obj in dict3.allKeys {
                            var tip = DriverTipOptions()
                            
                            if let tipObj = dict3.value(forKey: obj as! String) as? NSDictionary {
                                tip.option_type = tipObj["option_type"] as? String
                                tip.option_text_en = tipObj["option_text_en"] as? String
                                tip.title_admin = tipObj["title_admin"] as? String
                                tip.title_en = tipObj["title_en"] as? String
                                tip.group = (tipObj["group"] as? String)?.toInt()
                                cart.tipOptions.append(tip)
                            }
                        }
                        
                    }

                    
                }
                
            }
            
        }
    }
    
}

class DriverTip : NSObject {
    
}

class DriverTipOptions: NSObject {
    var option_type : String?
    var option_text_en : String?
    var title_admin : String?
    var title_en : String?
    var group : Int?
}


class DMProduct: BaseJsonModel {
    var products : [Product] = []
    var product : Product!
    
    override init(JSON : AnyObject) {
        super.init(JSON: JSON)
        if status {
            if let arr = infoDict!["products"] as? NSArray {
                products = CommonParse.parseProducts(arr)
            }else if let obj = infoDict!["product"] as? NSDictionary {
                product = CommonParse.parseProduct(obj)
            }
        }
        
        
    }
    
}

class DMCategory: BaseJsonModel {
    var categories : [Category] = []
    var category : Category!
    override init(JSON : AnyObject) {
        
        
        
        
        super.init(JSON: JSON)
        if status {
            if let arr = infoDict!["categories"] as? NSArray {
                categories = CommonParse.parseCategory(arr)
            }else if let obj = infoDict!["category"] as? NSDictionary {
                let category = Category()
                category.category_id = obj["category_id"] as? Int
                category.name = obj["name"] as? String
                category.descriptions = obj["description"] as? String
                category.thumb_image = obj["thumb_image"] as? String
                
                category.products = CommonParse.parseProducts(obj["products"] as! NSArray)
                self.category = category            }
        }
        
    }
    
    
}

class CommonParse: NSObject {
    static func parseCategory(_ arr : NSArray) -> [Category]{
        var categories : [Category] = []
        for cat in arr {
            var category = Category()
            category.category_id = cat["category_id"] as? Int
            category.name = cat["name"] as? String
            category.descriptions = cat["description"] as? String
            category.thumb_image = cat["thumb_image"] as? String
            category.total_products = cat["total_products"] as? Int
            var arr = cat["categories"] as? NSArray
            if arr?.count > 0 {
                category.categories = CommonParse.parseCategory(arr!)
            }
            categories.append(category)
        }
        return categories
    }
    
    static func parseProducts(_ arr : NSArray) -> [Product]{
        var products : [Product] = []
        for dict in arr {
            products.append(CommonParse.parseProduct(dict as AnyObject))
        }
        return products
    }
    
    
    static func parseProduct(_ dict:AnyObject) -> Product{
        var product = Product()
        product.product_id = dict["product_id"] as? Int
        product.name = dict["name"] as? String
        product.descriptions = dict["description"] as? String
        product.price = dict["price"] as? String
        product.special = dict["special"] as? String
        product.tax = dict["tax"] as? String
        product.minimum = dict["minimum"] as? String
        product.rating = dict["rating"] as? Int
        product.thumb_image = dict["thumb_image"] as? String
        
        
        product.title = dict["title"] as? String
        product.model = dict["model"] as? String
        product.image = dict["image"] as? String
        
        product.manufacturer = dict["manufacturer"] as? String
        product.reward_points = dict["reward_points"] as? Int
        product.reward_points = dict["reward_points"] as? Int
        product.minimum_quantity = dict["minimum_quantity"] as? Int
        product.stock_status = dict["stock_status"] as? String
        product.reviews = dict["reviews"] as? String
        product.review_enabled = dict["review_enabled"] as? Bool
        //            product.recurrings
        
        
        
        product.key = dict["key"] as? String
        
        product.recurring = dict["recurring"] as? String
        product.quantity = dict["quantity"] as? Int
        product.reward = dict["reward"] as? String
        product.total = dict["total"] as? String
//        //print(dict["in_stock"] as? Bool)
        product.in_stock = dict["in_stock"] as? Bool
        
        
        if let arr = dict["images"] as? NSArray{
            for img in arr{
                var image = Images()
                image.image = img["image"] as? String
                image.thumb_image = img["thumb_image"] as? String
                product.images.append(image)
            }
        }
        
        if let arr = dict["discounts"] as? NSArray{
            for dict in arr{
                var discount = Discount()
                discount.price = dict["price"] as? String
                discount.quantity = dict["quantity"] as? Int
                product.discounts.append(discount)
            }
        }
        // check for option & options
        if let arr = dict["options"] as? NSArray{
            for dict1 in arr {
                var option = Option()
                option.name = dict1["name"] as? String
                option.option_id = dict1["option_id"] as? Int
                option.product_option_id = dict1["product_option_id"] as? Int
                option.required = dict1["required"] as? Bool
                option.type = dict1["type"] as? String
                option.value = dict1["value"] as? String
                
                if let arr = dict1["product_option_value"] as? NSArray{
                    for dict2 in arr{
                        var product_option_value = ProductOptionValue()
                        product_option_value.product_option_value_id = dict2["product_option_value_id"] as? Int
                        product_option_value.option_value_id = dict2["option_value_id"] as? Int
                        product_option_value.name = dict2["name"] as? String
                        product_option_value.image = dict2["image"] as? String
                        product_option_value.price = dict2["price"] as? String
                        product_option_value.price_prefix = dict2["price_prefix"] as? String
                        option.product_option_value.append(product_option_value)
                    }
                }
                product.options.append(option)
            }
        }
        
        if let arr = dict["attribute_groups"] as? NSArray{
            for dict1 in arr {
                var attribute_groups = AttributesGrp()
                attribute_groups.attribute_group_id = dict1["attribute_group_id"] as? Int
                attribute_groups.name = dict1["name"] as? String
                
                if let arr = dict1["attribute"] as? NSArray{
                    for dict2 in arr{
                        var attribute = Attribute()
                        attribute.attribute_id = dict2["attribute_id"] as? Int
                        attribute.name = dict2["name"] as? String
                        attribute.text = dict2["text"] as? String
                        attribute_groups.attribute.append(attribute)
                    }
                }
                
                product.attribute_groups.append(attribute_groups)
            }
        }
        
        if let arr = dict["related_products"] as? NSArray{
            product.related_products = CommonParse.parseProducts(arr)
        }
        
        return product
    }
}
