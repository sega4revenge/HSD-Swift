//
//  RequestObject.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/23/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import ObjectMapper
import RealmSwift
class RequestObject: Object,Mappable {
    
    
    
    
    @objc dynamic  var _id : String?
    @objc dynamic var url: String?
    @objc dynamic  var params: String?
   
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    
    
    func mapping(map: Map) {
        _id <- map["_id"]
      
        
    }
}
