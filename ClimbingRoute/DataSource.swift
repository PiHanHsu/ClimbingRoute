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
    
    var fields = [Field]()
    var selectRoute: Route?
    var selectField: Field?
    var firebaseUser: FIRUser?

    let ref = FIRDatabase.database().reference()
    
    func loadDataFromFirebase() {
      
        guard firebaseUser != nil else {
            return
        }
        
        self.ref.child("Field").observe(.value, with: { (snapshot) in
            self.fields.removeAll()
            for child in snapshot.children {
                
                let childSnapshot = snapshot.childSnapshot(forPath: (child as AnyObject).key)
                let fieldId = childSnapshot.key
                let value = childSnapshot.value as? NSDictionary
                let name = value?["name"] as! String
                
                let field = Field(fieldId: fieldId, name: name)
                self.fields.append(field)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FinishLoadingFieldData"), object: nil)
        })
    }
    
    func loadingRouteFromFirebase(filedId: String) {
        guard firebaseUser != nil else {
            return
        }

        self.ref.child("Route").child(filedId).observe(.value, with: { (snapshot) in
            if let field = self.selectField {
                for child in snapshot.children {
                    
                    let childSnapshot = snapshot.childSnapshot(forPath: (child as AnyObject).key)
                    //let routeId = childSnapshot.key
                    let value = childSnapshot.value as? NSDictionary
                    let creater = value?["creater"] as! String
                    let difficulty = value?["difficulty"] as! String
                    let path = value?["path"] as! [String]
                    var targets = [Target]()
                    for center in path {
                        let targetCenter = CGPointFromString(center)
                        let target = Target(targetCenter: targetCenter)
                        targets.append(target)
                    }
                    
                    let route = Route(creater: creater, difficulty: difficulty, targets: targets)
                    
                    field.routes.append(route)
                    //self.selectField!.routes = routes
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "FinishLoadingRouteData"), object: nil)
            }
        })
        
        
    }
    
}
