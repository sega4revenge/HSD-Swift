//
//  ProductType.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/5/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import ObjectMapper
import RealmSwift
class ProductType: Object,Mappable {
    
    
    
    
    @objc dynamic var _id : String?
    @objc dynamic var name: String?
    @objc dynamic  var image: String?
    @objc dynamic  var barcode : String?
    @objc dynamic     var check_barcode : Bool = false
    @objc dynamic var des : String?
    @objc dynamic   var created_at: Double = 0.0
    
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    
    
    func mapping(map: Map) {
        _id <- map["_id"]
        name <- map["name"]
        check_barcode <- map["check_barcode"]
        image <- map["image"]
        des <- map["description"]
        barcode <- map["barcode"]
        created_at <- map["created_at"]
    }
}
