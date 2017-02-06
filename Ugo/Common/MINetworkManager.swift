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
    
    case postToken
    case initApp(String)
    case getCategories
    case getSpecialProducts
    case getProducts(limit : String?,page : String?,cat_id:String)
    case getProductDetail(String)
    case getSearchProduct(limit : String?,page : String?,order : String?,sort:String?,search:String?,descriptions:String?)
    case postAddtoCart(Product)
    case getCart
    case postLogin(String,String)
    case deleteCart(String)
    case deleteAddress(address_id : Int)
    case postPaymentAdd(Address)
    case postShippingAdd(Address)
    case getAddress
    case getShippingMethods
    case getPaymentMethods
    case postShippingMethods(shipping_method:String,comment:String)
    case postPaymentMethods(payment_method:String,comment:String)
    case getConfirm
    case getPay(access_token: String)
    case getSuccess
    case getCountryZones(country_id:String)
    case getOrder(page:String)
    case getOrderWithId(String)
    case putAccount(account :Account) , putCart(key:String,quantity : Int)
    case postpwd(String, String)
    case postRegister(account :Account),postRegisterFB(account :Account) ,postForgotPwd(email:String),postSetOption(option : DriverTipOptions)
    case getLogout
    
    var method: Method {
        switch self {
        case .postToken,.postAddtoCart,.postLogin,.postPaymentAdd,.postShippingAdd,.postShippingMethods,.postPaymentMethods,.postpwd,.postRegister,.postForgotPwd,.postRegisterFB,.postSetOption:
            return .POST
            
        case .initApp,.getCountryZones , .getOrder ,.getOrderWithId,.getLogout,.getCategories,.getSpecialProducts,.getSpecialProducts,.getProducts,.getProductDetail,.getSearchProduct,.getCart,.getAddress,.getShippingMethods,.getPaymentMethods,.getConfirm,.getPay,.getSuccess:
            
            return .GET
            
        case .deleteCart,.deleteAddress:
            return .DELETE
            
        case .putAccount , .putCart:
            return .PUT
            
            
            
        }
    }
    
    
    
    var URLRequest: Foundation.URLRequest
        {
            let (path: String, parameters: [String: AnyObject]) =
            { () -> (String, [String : AnyObject]) in 
                switch self
                {
                case .postToken:
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/oauth2/token", params)
                case .initApp(let str):
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/common/init?include=\(str)", params)
                case .getCategories(let str):
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/product/category", params)
                case .getSpecialProducts(let str):
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/product/special", params)
                case .getProducts(let limit,let page,let str):
                    var params :[String: AnyObject] = ["":"" as AnyObject]
                    params["limit"] = limit != nil ? limit : "20"
                    params["page"] = page != nil ? page : "1"

                    return ("/product/category/\(str)", params)
                    
                case .getProductDetail(let str):
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/product/product/\(str)", params)
                    
                case .getSearchProduct(let limit,let page,let order,let sort,let search,let descriptions):
                    
                    var params = Dictionary<String, String>()
                    
                    params["search"] = search != nil ? search : ""
                    params["limit"] = limit != nil ? limit : "15"
                    params["page"] = page != nil ? page : "1"
                    params["order"] = order != nil ? order : "ASC"
                    params["sort"] = sort != nil ? sort : "price"
                    params["description"] = descriptions != nil ? descriptions : "true"
                    
                    return ("/product/search", params as [String : AnyObject])
                    //CART APIS
                case .postAddtoCart(let product):
                    let params :[String: AnyObject] = ["product_id":product.product_id! as AnyObject,"quantity":product.quantity! as AnyObject]
                    return ("/cart/product", params)
                
                case .postSetOption(let option):
                    let params :[String: AnyObject] = ["\(option.title_en!.removeWhitespace().removeDots())[0]":option.title_admin!.removeWhitespace().removeDots() as AnyObject]
                    return ("/cart/cart/setOptions", params)
                    
                    
                case .getCart:
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/cart/cart", params)
                    
                case .deleteCart(let productkey):
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/cart/product/\(productkey)", params)
                 
                case .deleteAddress(let address_id):
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/account/address/\(address_id)", params)
                    
                    // Checkout
                case .postPaymentAdd(let address):
                    var params :[String: AnyObject]!
                    if address.payment_address == "new" {
                        params = ["payment_address": address.payment_address! as AnyObject,"firstname":address.firstname! as AnyObject,"lastname":address.lastname! as AnyObject,"address_1":address.address_1! as AnyObject,"city":address.city! as AnyObject,"postcode":address.postcode! as AnyObject,"country_id":address.country_id! as AnyObject,"zone_id":address.zone_id! as AnyObject]
                    }else{
                        params = ["payment_address": address.payment_address! as AnyObject,"address_id":Int(address.address_id!) as AnyObject]
                    }
                    
                    return ("/checkout/payment_address", params)
                    
                case .postShippingAdd(let address):
                    var params :[String: AnyObject]!
                    if address.shipping_address == "new" {
                        params = ["shipping_address": address.shipping_address! as AnyObject,"firstname":address.firstname! as AnyObject,"lastname":address.lastname! as AnyObject,"address_1":address.address_1! as AnyObject,"city":address.city! as AnyObject,"postcode":address.postcode! as AnyObject,"country_id":address.country_id! as AnyObject,"zone_id":address.zone_id! as AnyObject]
                    }else{
                        params = ["shipping_address": address.shipping_address! as AnyObject,"address_id":Int(address.address_id!) as AnyObject]
                    }
                    
                    return ("/checkout/shipping_address", params)
                    
                case .getShippingMethods:
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/checkout/shipping_method", params)
                case .getPaymentMethods:
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/checkout/payment_method", params)
                    
                case .postShippingMethods(let shipping_method,let comment):
                    let params :[String: AnyObject] = ["shipping_method":shipping_method as AnyObject,"comment":comment as AnyObject]
                    return ("/checkout/shipping_method", params)
                case .postPaymentMethods(let payment_method,let comment):
                    let params :[String: AnyObject] = ["payment_method":payment_method as AnyObject,"comment":comment as AnyObject]
                    return ("/checkout/payment_method", params)
                    
                case .getConfirm:
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/checkout/confirm", params)
                    
                case .getPay(let access_token):
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/checkout/pay?access_token=\(access_token)", params)
                case .getSuccess:
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/checkout/success", params)
                    
                case .getCountryZones(let cid):
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/common/country/\(cid)", params)
                    
                case .getAddress:
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/account/address", params)
                case .postLogin(let username,let pwd):
                    let params :[String: AnyObject] = ["email":username as AnyObject,"password":pwd as AnyObject]
                    return ("/account/login", params)
                    
                case .getLogout :
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/account/logout", params)
                    
                case .getOrder(let page):
                    let params :[String: AnyObject] = ["page":page as AnyObject]
                    return ("/account/order", params)
                case .getOrderWithId(let oid):
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("/account/order\(oid)", params)
                case .putAccount(let account):
                    let params :[String: AnyObject] = ["firstname":account.firstname! as AnyObject,"lastname":account.lastname! as AnyObject,"email":account.email! as AnyObject,"telephone":account.telephone! as AnyObject,"fax":account.fax! as AnyObject]
                    return ("/account/account", params)
                    
                case .POSTPWD(let pwd,let confirm):
                    let params :[String: AnyObject] = ["password":pwd as AnyObject,"confirm":confirm as AnyObject]
                    return ("/account/password", params)
                    
                case .postRegisterFB(let account):
                    var params = [
                    
                        "firstname" : account.firstname != nil ? account.firstname! : "",
                        "lastname" : account.lastname != nil ? account.lastname! : "NA",
                        "email" : account.email != nil ? account.email! : "NA",
                        "telephone" : account.telephone != nil ? account.telephone! : "123",
                        "fax" : account.fax != nil ? account.fax! : "",
                    
                        "password" : account.password != nil ? account.password! : "",
                        "confirm" : account.password != nil ? account.password! : "",
                    
                        "address_1" : "NAA",
                        "address_2" : "NA",
                        "city" : "NA",
                        "postcode" : "NA",
                        "country_id" : "223",
                        "zone_id" : "3613",
                        "custom_field[account][1]" : account.fb != nil ? account.fb! : ""]
                    
                    
                    return ("/account/registerfb", params as [String : AnyObject])
                    
                case .postRegister(let account):
                    var params = [
                        
                        "firstname" : account.firstname != nil ? account.firstname! : "",
                        "lastname" : account.lastname != nil ? account.lastname! : "NA",
                        "email" : account.email != nil ? account.email! : "NA",
                        "telephone" : account.telephone != nil ? account.telephone! : "123",
                        "fax" : account.fax != nil ? account.fax! : "",
                    
                        "password" : account.password != nil ? account.password! : "",
                        "confirm" : account.password != nil ? account.password! : "",
                    
                        "address_1" : "NAA",
                        "address_2" : "NA",
                        "city" : "NA",
                        "postcode" : "NA",
                        "country_id" : "223",
                        "zone_id" : "3613"]
                    
                    return ("/account/register", params as [String : AnyObject])
                    
                case .postForgotPwd(let email):
                    let params :[String: AnyObject] = ["email":email as AnyObject]
                    return ("/account/forgotten", params)
                    
                case .putCart(let key, let quantity):
                    let params :[String: AnyObject] = [key:quantity as AnyObject]
                    return ("/cart/product", params)
                    
                default:
                    let params :[String: AnyObject] = ["":"" as AnyObject]
                    return ("", params)
                    
                }
                }()
            
            
            let URL = Foundation.URL(string: APIRouter.BASE_URL)
            let URLRequest = NSMutableURLRequest(URL:URL!.URLByAppendingPathComponent(path))
            URLRequest.HTTPMethod = method.rawValue
            if let access_token = UserSessionInformation.sharedInstance.access_token{
                URLRequest.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
            }else{
                URLRequest.setValue("Basic VWdvQXV0aDMyMTY1NDpSVGdPQnN0QUJ4MjN4OTgxd3BvQQ==", forHTTPHeaderField: "Authorization")
                URLRequest.setValue("private", forHTTPHeaderField: "Cache-Control")
                
            }
            
            let encoding = ParameterEncoding.url
            //println("Headers ==== \(URLRequest.allHTTPHeaderFields!)")
            //println("parameters ==== \(parameters)")
            
            //println("Method ==== \(URLRequest.HTTPMethod)")
            //println("URL ==== \(URLRequest.URLString)")
            
            return encoding.encode(URLRequest, parameters: parameters).0
            
    }
    
    
    
}

class MINetworkManager: NSObject {
    
    private static var __once: () = {
            Static.instance = MINetworkManager()
        }()
    
    class var sharedInstance:MINetworkManager{
        
        struct Static{
            static var instance : MINetworkManager!
            static var token : Int = 0
        }
        
        _ = MINetworkManager.__once
        
        return Static.instance
    }
    
    
    var manager: Manager?
    
    override init() {
        // Create a shared URL cache
        let memoryCapacity = 500 * 1024 * 1024; // 500 MB
        let diskCapacity = 500 * 1024 * 1024; // 500 MB
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")
        
        // Create a custom configuration
        let configuration = URLSessionConfiguration.default
        let defaultHeaders = Manager.sharedInstance.session.configuration.httpAdditionalHeaders
        
        configuration.httpAdditionalHeaders = defaultHeaders
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
            // this is the default
        configuration.urlCache = cache
        
        // Create your own manager instance that uses your custom configuration
        manager = Manager(configuration: configuration)
        
    }
}
