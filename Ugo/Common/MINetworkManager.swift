//
//  MINetworkManager.swift
//  CacheTestAlamofire
//
//  Created by Sadiq on 29/07/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

enum APIRouter: URLRequestConvertible
{
    static let BASE_URL = "https://www.ugollc.com/api/v1"
//    static let BASE_URL = "http://sadiq-mac.local/openupload/api/v1"
//    static let BASE_URL = "http://localhost/ugo/api/v1"
    static let API_KEY = "12"//api key, consumer secret for OAuth, etc
    
    case POSTToken
    case initApp(String)
    case GETCategories
    case GETSpecialProducts
    case GETProducts(limit : String?,page : String?,cat_id:String)
    case GETProductDetail(String)
    case GETSearchProduct(limit : String?,page : String?,order : String?,sort:String?,search:String?,descriptions:String?)
    case POSTAddtoCart(Product)
    case GETCart
    case POSTLogin(String,String)
    case DELETECart(String)
    case DELETEAddress(address_id : Int)
    case POSTPaymentAdd(Address)
    case POSTShippingAdd(Address)
    case GETAddress
    case GETShippingMethods
    case GETPaymentMethods
    case POSTShippingMethods(shipping_method:String,comment:String)
    case POSTPaymentMethods(payment_method:String,comment:String)
    case GETConfirm
    case GETPay(access_token: String)
    case GETSuccess
    case GETCountryZones(country_id:String)
    case GETOrder(page:String)
    case GETOrderWithId(String)
    case PUTAccount(account :Account) , PUTCart(key:String,quantity : Int)
    case POSTPWD(String, String)
    case POSTRegister(account :Account),POSTRegisterFB(account :Account) ,POSTForgotPwd(email:String),POSTSetOption(option : DriverTipOptions)
    case GETLogout
    
    var method: Method {
        switch self {
        case .POSTToken,.POSTAddtoCart,.POSTLogin,.POSTPaymentAdd,.POSTShippingAdd,.POSTShippingMethods,.POSTPaymentMethods,.POSTPWD,POSTRegister,POSTForgotPwd,.POSTRegisterFB,.POSTSetOption:
            return .POST
            
        case .initApp,.GETCountryZones , .GETOrder ,.GETOrderWithId,GETLogout,.GETCategories,.GETSpecialProducts,.GETSpecialProducts,.GETProducts,.GETProductDetail,.GETSearchProduct,.GETCart,.GETAddress,.GETShippingMethods,.GETPaymentMethods,.GETConfirm,.GETPay,.GETSuccess:
            
            return .GET
            
        case .DELETECart,.DELETEAddress:
            return .DELETE
            
        case .PUTAccount , PUTCart:
            return .PUT
            
            
            
        }
    }
    
    
    
    var URLRequest: NSURLRequest
        {
            let (path: String, parameters: [String: AnyObject]) =
            {
                switch self
                {
                case .POSTToken:
                    let params :[String: AnyObject] = ["":""]
                    return ("/oauth2/token", params)
                case .initApp(let str):
                    let params :[String: AnyObject] = ["":""]
                    return ("/common/init?include=\(str)", params)
                case .GETCategories(let str):
                    let params :[String: AnyObject] = ["":""]
                    return ("/product/category", params)
                case .GETSpecialProducts(let str):
                    let params :[String: AnyObject] = ["":""]
                    return ("/product/special", params)
                case .GETProducts(let limit,let page,let str):
                    var params :[String: AnyObject] = ["":""]
                    params["limit"] = limit != nil ? limit : "20"
                    params["page"] = page != nil ? page : "1"

                    return ("/product/category/\(str)", params)
                    
                case .GETProductDetail(let str):
                    let params :[String: AnyObject] = ["":""]
                    return ("/product/product/\(str)", params)
                    
                case .GETSearchProduct(let limit,let page,let order,let sort,let search,let descriptions):
                    
                    var params = Dictionary<String, String>()
                    
                    params["search"] = search != nil ? search : ""
                    params["limit"] = limit != nil ? limit : "15"
                    params["page"] = page != nil ? page : "1"
                    params["order"] = order != nil ? order : "ASC"
                    params["sort"] = sort != nil ? sort : "price"
                    params["description"] = descriptions != nil ? descriptions : "true"
                    
                    return ("/product/search", params)
                    //CART APIS
                case .POSTAddtoCart(let product):
                    let params :[String: AnyObject] = ["product_id":product.product_id!,"quantity":product.quantity!]
                    return ("/cart/product", params)
                
                case .POSTSetOption(let option):
                    let params :[String: AnyObject] = ["\(option.title_en!.removeWhitespace().removeDots())[0]":option.title_admin!.removeWhitespace().removeDots()]
                    return ("/cart/cart/setOptions", params)
                    
                    
                case .GETCart:
                    let params :[String: AnyObject] = ["":""]
                    return ("/cart/cart", params)
                    
                case .DELETECart(let productkey):
                    let params :[String: AnyObject] = ["":""]
                    return ("/cart/product/\(productkey)", params)
                 
                case .DELETEAddress(let address_id):
                    let params :[String: AnyObject] = ["":""]
                    return ("/account/address/\(address_id)", params)
                    
                    // Checkout
                case .POSTPaymentAdd(let address):
                    var params :[String: AnyObject]!
                    if address.payment_address == "new" {
                        params = ["payment_address": address.payment_address!,"firstname":address.firstname!,"lastname":address.lastname!,"address_1":address.address_1!,"city":address.city!,"postcode":address.postcode!,"country_id":address.country_id!,"zone_id":address.zone_id!]
                    }else{
                        params = ["payment_address": address.payment_address!,"address_id":Int(address.address_id!)]
                    }
                    
                    return ("/checkout/payment_address", params)
                    
                case .POSTShippingAdd(let address):
                    var params :[String: AnyObject]!
                    if address.shipping_address == "new" {
                        params = ["shipping_address": address.shipping_address!,"firstname":address.firstname!,"lastname":address.lastname!,"address_1":address.address_1!,"city":address.city!,"postcode":address.postcode!,"country_id":address.country_id!,"zone_id":address.zone_id!]
                    }else{
                        params = ["shipping_address": address.shipping_address!,"address_id":Int(address.address_id!)]
                    }
                    
                    return ("/checkout/shipping_address", params)
                    
                case .GETShippingMethods:
                    let params :[String: AnyObject] = ["":""]
                    return ("/checkout/shipping_method", params)
                case .GETPaymentMethods:
                    let params :[String: AnyObject] = ["":""]
                    return ("/checkout/payment_method", params)
                    
                case .POSTShippingMethods(let shipping_method,let comment):
                    let params :[String: AnyObject] = ["shipping_method":shipping_method,"comment":comment]
                    return ("/checkout/shipping_method", params)
                case .POSTPaymentMethods(let payment_method,let comment):
                    let params :[String: AnyObject] = ["payment_method":payment_method,"comment":comment]
                    return ("/checkout/payment_method", params)
                    
                case .GETConfirm:
                    let params :[String: AnyObject] = ["":""]
                    return ("/checkout/confirm", params)
                    
                case .GETPay(let access_token):
                    let params :[String: AnyObject] = ["":""]
                    return ("/checkout/pay?access_token=\(access_token)", params)
                case .GETSuccess:
                    let params :[String: AnyObject] = ["":""]
                    return ("/checkout/success", params)
                    
                case .GETCountryZones(let cid):
                    let params :[String: AnyObject] = ["":""]
                    return ("/common/country/\(cid)", params)
                    
                case .GETAddress:
                    let params :[String: AnyObject] = ["":""]
                    return ("/account/address", params)
                case .POSTLogin(let username,let pwd):
                    let params :[String: AnyObject] = ["email":username,"password":pwd]
                    return ("/account/login", params)
                    
                case .GETLogout :
                    let params :[String: AnyObject] = ["":""]
                    return ("/account/logout", params)
                    
                case .GETOrder(let page):
                    let params :[String: AnyObject] = ["page":page]
                    return ("/account/order", params)
                case .GETOrderWithId(let oid):
                    let params :[String: AnyObject] = ["":""]
                    return ("/account/order\(oid)", params)
                case .PUTAccount(let account):
                    let params :[String: AnyObject] = ["firstname":account.firstname!,"lastname":account.lastname!,"email":account.email!,"telephone":account.telephone!,"fax":account.fax!]
                    return ("/account/account", params)
                    
                case .POSTPWD(let pwd,let confirm):
                    let params :[String: AnyObject] = ["password":pwd,"confirm":confirm]
                    return ("/account/password", params)
                    
                case .POSTRegisterFB(let account):
                    var params = [String: AnyObject]()
                    
                    params["firstname"] = account.firstname != nil ? account.firstname! : ""
                    params["lastname"] = account.lastname != nil ? account.lastname! : "NA"
                    params["email"] = account.email != nil ? account.email! : "NA"
                    params["telephone"] = account.telephone != nil ? account.telephone! : "123"
                    params["fax"] = account.fax != nil ? account.fax! : ""
                    
                    params["password"] = account.password != nil ? account.password! : ""
                    params["confirm"] = account.password != nil ? account.password! : ""
                    
                    params["address_1"] = "NAA"
                    params["address_2"] = "NA"
                    params["city"] = "NA"
                    params["postcode"] = "NA"
                    params["country_id"] = "223"
                    params["zone_id"] = "3613"
                    params["custom_field[account][1]"] = account.fb != nil ? account.fb! : ""
                    
                    
                    return ("/account/registerfb", params)
                    
                case .POSTRegister(let account):
                    var params = [String: AnyObject]()
                    
                    params["firstname"] = account.firstname != nil ? account.firstname! : ""
                    params["lastname"] = account.lastname != nil ? account.lastname! : "NA"
                    params["email"] = account.email != nil ? account.email! : "NA"
                    params["telephone"] = account.telephone != nil ? account.telephone! : "123"
                    params["fax"] = account.fax != nil ? account.fax! : ""
                    
                    params["password"] = account.password != nil ? account.password! : ""
                    params["confirm"] = account.password != nil ? account.password! : ""
                    
                    params["address_1"] = "NAA"
                    params["address_2"] = "NA"
                    params["city"] = "NA"
                    params["postcode"] = "NA"
                    params["country_id"] = "223"
                    params["zone_id"] = "3613"
                    
                    return ("/account/register", params)
                    
                case POSTForgotPwd(let email):
                    let params :[String: AnyObject] = ["email":email]
                    return ("/account/forgotten", params)
                    
                case PUTCart(let key, let quantity):
                    let params :[String: AnyObject] = [key:quantity]
                    return ("/cart/product", params)
                    
                default:
                    let params :[String: AnyObject] = ["":""]
                    return ("", params)
                    
                }
                }()
            
            
            let URL = NSURL(string: APIRouter.BASE_URL)
            let URLRequest = NSMutableURLRequest(URL:URL!.URLByAppendingPathComponent(path))
            URLRequest.HTTPMethod = method.rawValue
            if let access_token = UserSessionInformation.sharedInstance.access_token{
                URLRequest.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
            }else{
                URLRequest.setValue("Basic VWdvQXV0aDMyMTY1NDpSVGdPQnN0QUJ4MjN4OTgxd3BvQQ==", forHTTPHeaderField: "Authorization")
                URLRequest.setValue("private", forHTTPHeaderField: "Cache-Control")
                
            }
            
            let encoding = ParameterEncoding.URL
            //println("Headers ==== \(URLRequest.allHTTPHeaderFields!)")
            //println("parameters ==== \(parameters)")
            
            //println("Method ==== \(URLRequest.HTTPMethod)")
            //println("URL ==== \(URLRequest.URLString)")
            
            return encoding.encode(URLRequest, parameters: parameters).0
            
    }
    
    
}

class MINetworkManager: NSObject {
    
    class var sharedInstance:MINetworkManager{
        
        struct Static{
            static var instance : MINetworkManager!
            static var token : dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token){
            Static.instance = MINetworkManager()
        }
        
        return Static.instance
    }
    
    
    var manager: Manager?
    
    override init() {
        // Create a shared URL cache
        let memoryCapacity = 500 * 1024 * 1024; // 500 MB
        let diskCapacity = 500 * 1024 * 1024; // 500 MB
        let cache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")
        
        // Create a custom configuration
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var defaultHeaders = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders
        
        configuration.HTTPAdditionalHeaders = defaultHeaders
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
            // this is the default
        configuration.URLCache = cache
        
        // Create your own manager instance that uses your custom configuration
        manager = Manager(configuration: configuration)
        
    }
}
