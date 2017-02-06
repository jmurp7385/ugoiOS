//
//  BaseJsonModel.swift
//  Ugo
//
//  Created by Sadiq on 17/08/15.
//  Copyright (c) 2015 Mobinett Interactive Inc. All rights reserved.
//

import UIKit

class Errors : NSObject {
    var message : String?
    var code : String?
}

class BaseJsonModel: NSObject {
    var infoDict : NSDictionary?
    var errors : [Errors] = []
    var status : Bool {
       return errors.count > 0 ? false : true
    }
    
    var errorMsg : String = ""
    override init() {
        
    }
    
    init(JSON : AnyObject){
        if let dict = JSON as? NSDictionary {
            if let arr = dict["errors"] as? NSArray {
                for obj in arr {
                    var err = Errors()
                    err.message = obj["message"] as? String
                    err.code = obj["code"] as? String
                    errors.append(err)
                    errorMsg += err.message! + "\n"
                }
            }else{
                if dict["heading_title"] as? String == "Maintenance" {
                    var err = Errors()
                    err.message = "Sorry for inconvenience. Our backend is currently undergoing scheduled maintenance"
                    err.code = "Maintenance"
                    errors.append(err)
                    errorMsg += err.message! + "\n"
                }else{
                    infoDict = dict
                }
            }
        }
        
    }
}
