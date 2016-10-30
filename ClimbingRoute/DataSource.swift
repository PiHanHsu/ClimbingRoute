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
                let value = childSnapshot.value as? NSDictionary
                let name = value?["name"] as! String
                
                let field = Field(name: name)
                self.fields.append(field)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FinishLoadingFieldData"), object: nil)
        })
    }
}
