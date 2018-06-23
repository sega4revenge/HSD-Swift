//
//  Response.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/4/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import ObjectMapper

struct Response: Mappable {
    
    var message: String?
    var status: Int?
    var listproduct = [Product]()
    var producttype : ProductType?
        var product : Product?
    var user : User?
    init() {
        
    }
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        message <- map["message"]
        status <- map["status"]
        listproduct <- map["ListProduct"]
         user <- map["user"]
          producttype <- map["ProductType"]
        product <- map["product"]
    }
}
