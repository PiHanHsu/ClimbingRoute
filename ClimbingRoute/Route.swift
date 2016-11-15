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
    var finished = false
    var name: String
    var startTarget = Target(targetCenter: CGPoint(x: 100, y: 160))
    var endTarget = Target(targetCenter: CGPoint(x: 300, y: 100))
    
    init(name: String, creater: String, difficulty: String, targets: [Target]?) {
        self.name = name
        self.creater = creater
        self.difficulty = difficulty
        self.targets = targets
        self.rating = 0.0
        self.startTarget.imageView.backgroundColor = UIColor.green
        self.startTarget.nameLabel.text = "起攀"
        self.endTarget.imageView.backgroundColor = UIColor.red
        self.endTarget.nameLabel.text = "完攀"
    }
    
}
