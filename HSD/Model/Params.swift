//
//  Params.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/28/18.
//  Copyright © 2018 Finger. All rights reserved.
//


import RealmSwift
class Params: Object {
    
    
    
    
    @objc dynamic  var _id : String?
     @objc dynamic  var  key : String?
    @objc dynamic   var value : String?
    

    override static func primaryKey() -> String? {
        return "_id"
    }
  
    
    convenience init(key : String,value : String) {
        self.init()
        self.key = key
        self.value = value
      
    }
    
}
