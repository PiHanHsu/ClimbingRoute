//
//  Field.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 27/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

class Field: NSObject {
    var name: String
    var fieldId: String
    var routesCount: Int
    var myRoutes = [Route]()
    var routes = [Route]() {
        willSet(newValue) {
           self.routesCount = newValue.count
        }
    }
    
    init(fieldId: String, name: String) {
        self.fieldId = fieldId
        self.name = name
        self.routesCount = 0
    }
    
}
