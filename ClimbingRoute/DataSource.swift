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
                    let routeId = childSnapshot.key
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
                    route.routeId = routeId
                    field.routes.append(route)
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: "FinishLoadingRouteData"), object: nil)
            }
        })
    }
 
    func updateRatingDataToRoute(field: Field, route: Route) {
        var starArray = [Double]()
        
        ref.child("Rating").child(route.routeId!).observe(.value, with: { (snapshot) in
            for child in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (child as AnyObject).key)
                let ratingValue = childSnapshot.value as? NSDictionary
                let star = ratingValue?["stars"] as! Double
                starArray.append(Double(star))
            }
            route.rating = starArray.average
            self.writeRatingToFireBase(field: field, route: route)
        })
    
    }
    
    func writeRatingToFireBase(field: Field, route: Route) {
        guard route.rating != nil else{
            return
        }
        let routeRef = ref.child("Route").child(field.fieldId).child(route.routeId!)
        let updateRating = ["rating": route.rating!] as [String : Any]
        routeRef.updateChildValues(updateRating)
        print("rating: \(route.rating!)")
    }
    
    
}

extension Array where Element: FloatingPoint {
    /// Returns the sum of all elements in the array
    var total: Element {
        return reduce(0, +)
    }
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}
