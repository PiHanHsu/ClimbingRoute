//
//  DataSource.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 27/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit
import Firebase

class DataSource: NSObject {
   
    static let shareInstance = DataSource()
    
    var Fields = [Field]()
    var selectRoute: Route?
    var firebaseUser: FIRUser?

}
