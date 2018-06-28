//
//  Result.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/27/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import ObjectMapper
import RealmSwift
class Result: Mappable {
    
    
    
    
     var _id: String?
    var expiretime: String?
    var description: String?
  var imagechanged: String?
  
    required convenience init?(map: Map) {
        self.init()
    }
    
   
    
    
    func mapping(map: Map) {
        _id <- map["_id"]
        expiretime <- map["expiretime"]
        description <- map["description"]
        imagechanged <- map["imagechanged"]
    
    }
}
