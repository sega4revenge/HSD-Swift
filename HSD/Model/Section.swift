//
//  Section.swift
//  HSD
//
//  Created by Tô Tử Siêu on 6/29/18.
//  Copyright © 2018 Finger. All rights reserved.
//

import UIKit

struct Section {
    var name: String
    var items = [Product]()
    var collapsed: Bool
    
    init(name: String, items: [Product], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}
