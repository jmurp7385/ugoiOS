//
//  TOEnums.swift
//  Tokri
//
//  Created by Sadiq on 29/04/15.
//  Copyright (c) 2015 Xstpl. All rights reserved.
//

import UIKit

enum AddressType  : Int{
    case billing = 0
    case shipping
    case billingWithLocation
    case shippingWithLocation
    case general
}

enum ProductList {
    case `default`
    case search
    case wishList
    case myOrders
}

enum dayType: Int
{
    case today = 1
    case tomorrow  = 2
    case yesterday  = 3
    case other = 0
}

enum barMenu {
    case sidemenu
    case logo
    case tokri
    case user
    case search
}

enum plusMenu {
    case chat
    case sms
    case whatsapp
    case call
    case camera
}

enum sideMenu {
    case offering
    case category
    case subcategory
    case products
}
class Enums: NSObject {
    
}

