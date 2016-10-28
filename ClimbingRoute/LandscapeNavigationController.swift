//
//  LandscapeNavigationController.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 28/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

class LandscapeNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UIInterfaceOrientationMask.landscape.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
}
