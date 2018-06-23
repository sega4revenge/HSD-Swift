//
//  Setting.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/21/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import ObjectMapper
import RealmSwift
class Setting: Object,Mappable {
    
    
    
    
    @objc dynamic  var _id : String?
    @objc dynamic var timezone: Int = 0
    @objc dynamic  var user_id: String?
    var frame_time = List<Double>()
   
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    
    
    func mapping(map: Map) {
        _id <- map["_id"]
        timezone <- map["timezone"]
        frame_time <- map["frame_time"]
        user_id <- map["user_id"]
      
    }
}
