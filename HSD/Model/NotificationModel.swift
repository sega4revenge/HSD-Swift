//
//  Notification.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/18/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import ObjectMapper
import RealmSwift
class NotificationModel: Object,Mappable {
    
    
    
    
    @objc dynamic var _id : String?
    @objc dynamic var type: Int = 0
    @objc dynamic  var content: String?
    @objc dynamic var created_at: Double = 0.0
    @objc dynamic  var productid: String?
    @objc dynamic var image: String?
    @objc dynamic  var iduser: String?
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    
    
    func mapping(map: Map) {
        _id <- map["_id"]
        type <- map["type"]
        content <- map["content"]
        productid <- map["productid"]
        image <- map["image"]
         iduser <- map["idUser"]
    }
}
