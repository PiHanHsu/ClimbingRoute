//
//  Field.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 27/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

class Field: NSObject {
    let name: string
    var routes: [Route]? = nil
    
    init(name: string) {
        self.name = name
    }
    
}
