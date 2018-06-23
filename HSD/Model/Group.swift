//
//  Group.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/20/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import ObjectMapper
import RealmSwift
class Group: Object,Mappable {
    
    
    
    
    @objc dynamic  var _id : String?
    @objc dynamic var name: String?
    @objc dynamic  var owner: String?
    @objc dynamic   var created_at: Double = 0.0
    var listuser = List<User>()
    var listproduct  = List<Product>()
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    
    
    func mapping(map: Map) {
        _id <- map["_id"]
        name <- map["name"]
        owner <- map["owner"]
        created_at <- map["created_at"]
        listproduct <- (map["listproduct"], ListTransform<Product>())
        listuser <- (map["listuser"], ListTransform<User>())
    }
}
