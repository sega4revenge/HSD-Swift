//
//  User.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/4/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit

import ObjectMapper
import RealmSwift
class User: Object,Mappable {
    
    
    
    
    @objc dynamic var _id : String?
    @objc dynamic var phone: String?
    @objc dynamic  var create_at: Double = 0.0
    var listnotification = List<NotificationModel>()
    var listgroup = List<Group>()
     @objc dynamic  var setting: Setting?
    @objc dynamic var type_login : Int = 0
    required convenience init?(map: Map) {
        self.init()
    }
    
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    
    
    func mapping(map: Map) {
        _id <- map["_id"]
        phone <- map["phone"]
        create_at <- map["create_at"]
         listgroup <- (map["listgroup"], ListTransform<Group>())
         listnotification <- (map["listnotification"], ListTransform<NotificationModel>())
          type_login <- map["type_login"]
    }
}
