//
//  Route.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 27/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

class Route: NSObject {

    var routeId: String?
    let creater: String
    let difficulty: String
    var rating: Double
    var targets: [Target]?
    
    init(creater: String, difficulty: String, targets: [Target]?) {
        self.creater = creater
        self.difficulty = difficulty
        self.targets = targets
        self.rating = 0.0
    }
    
}
