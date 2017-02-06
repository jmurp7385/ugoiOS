//
//  TOEnums.swift
//  Tokri
//
//  Created by Sadiq on 29/04/15.
//  Copyright (c) 2015 Xstpl. All rights reserved.
//

import UIKit

enum AddressType  : Int{
    case Billing = 0
    case Shipping
    case BillingWithLocation
    case ShippingWithLocation
    case General
}

enum ProductList {
    case Default
    case Search
    case WishList
    case MyOrders
}

enum dayType: Int
{
    case TODAY = 1
    case TOMORROW  = 2
    case YESTERDAY  = 3
    case OTHER = 0
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

