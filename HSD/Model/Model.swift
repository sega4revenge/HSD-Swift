//
//  Model.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/3/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import ObjectMapper
import RealmSwift

class Model: Object, Mappable {
    @objc dynamic var name = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        name <- map["name"]
    }
}
