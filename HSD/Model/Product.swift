//
//  Product.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/1/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import ObjectMapper
import RealmSwift
class Product: Object,Mappable {
    
    
    
    
    @objc dynamic var _id : String?
    @objc dynamic  var daybefore: Int = 0
    @objc dynamic  var delete: Int = 0
    @objc dynamic var producttype_id: ProductType?
    @objc dynamic   var namechanged: String?
    @objc dynamic  var expiretime: Double = 0.0
    @objc dynamic   var imagechanged: String?
    @objc dynamic  var barcode : String?
    @objc dynamic  var des : String?
    @objc dynamic  var created_at: Double = 0.0
    
    
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    
    
    func mapping(map: Map) {
        _id <- map["_id"]
        producttype_id <- map["producttype_id"]
        daybefore <- map["daybefore"]
        delete <- map["delete"]
        namechanged <- map["namechanged"]
        expiretime <- map["expiretime"]
        imagechanged <- map["imagechanged"]
        des <- map["description"]
        barcode <- map["barcode"]
    }
}
