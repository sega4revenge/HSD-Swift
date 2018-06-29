//
//  RequestObject.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/23/18.
//  Copyright © 2018 Finger. All rights reserved.
//


import RealmSwift
class RequestObject: Object {
    
    
    
    
    @objc dynamic  var _id : String?
    @objc dynamic var url: String?
    @objc dynamic var type : String?
    var params : List<String>? = List<String>()
    
    

    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    
    

}
