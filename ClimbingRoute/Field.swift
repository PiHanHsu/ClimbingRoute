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
    var routes = [Route]()
    
    init(fieldId: String, name: String) {
        self.fieldId = fieldId
        self.name = name
    }
    
}
