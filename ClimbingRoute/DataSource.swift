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
    var finishRoutes = [String]()
    var selectRoute: Route?
    var selectField: Field?
    var firebaseUser: FIRUser?
    let mainWidth = UIScreen.main.bounds.width
    let mainHeight = UIScreen.main.bounds.height
    
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
                let routesCount = value?["routesCount"] as! Int
                
                let field = Field(fieldId: fieldId, name: name)
                field.routesCount = routesCount
                self.fields.append(field)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FinishLoadingFieldData"), object: nil)
        })
        
        loadingFinishRouteFromFirebase()
    }
    
    func loadingRouteFromFirebase(fieldId: String) {
        guard firebaseUser != nil else {
            return
        }
        
        loadingTempRouteDataFromFirebase(fieldId: fieldId)

        self.ref.child("Route").child(fieldId).observe(.value, with: { (snapshot) in
            if let field = self.selectField {
                field.routes.removeAll()
                field.myRoutes.removeAll()
                for child in snapshot.children {
                    
                    let childSnapshot = snapshot.childSnapshot(forPath: (child as AnyObject).key)
                    let routeId = childSnapshot.key
                    let value = childSnapshot.value as? NSDictionary
                    let name = value?["name"] as! String
                    let creater = value?["creater"] as! String
                    let difficulty = value?["difficulty"] as! String
                    let path = value?["path"] as! [String]
                    let rating = value?["rating"] as! Double
                    var targets = [Target]()
                    for center in path {
                        let targetCenter = CGPointFromString(center)
                        let pointCenter = self.convertScaleToPoint(point: targetCenter)
                        let target = Target(targetCenter: pointCenter, isUserInteractionEnabled: false, type: .normal)
                        targets.append(target)
                    }
                    
                    let startPoint = value?["startPoint"] as! String
                    let endPoint = value?["endPoint"] as! String
                    let startCenter = self.convertScaleToPoint(point: CGPointFromString(startPoint))
                    let endCenter = self.convertScaleToPoint(point: CGPointFromString(endPoint))
                    
                    let startTarget = Target(targetCenter: startCenter, isUserInteractionEnabled: false, type: .start)
                    let endTarget = Target(targetCenter: endCenter, isUserInteractionEnabled: false, type: .end)
                    
                    targets.append(startTarget)
                    targets.append(endTarget)

                    let route = Route(name: name, creater: creater, difficulty: difficulty, targets: targets)
                    
                    route.routeId = routeId
                    route.rating = rating
                    field.routes.append(route)
                    if creater == self.firebaseUser?.displayName! {
                        field.myRoutes.append(route)
                    }
                }
                self.updateRoutesCountToFirebase(field: field)
            }
        })
    }
    
    func updateRoutesCountToFirebase(field: Field) {
        let fieldRef = ref.child("Field").child(field.fieldId)
        let routesCount = ["routesCount" : field.routes.count] as [String : Any]
        fieldRef.updateChildValues(routesCount)
       NotificationCenter.default.post(name: Notification.Name(rawValue: "FinishLoadingRouteData"), object: nil)
    }
 
    func loadingTempRouteDataFromFirebase(fieldId: String) {
        ref.child("Temp").child(firebaseUser!.uid).child(fieldId).observe(.value, with: { snapshot in
            
            if let value = snapshot.value as? NSDictionary {
                let difficulty = value["difficulty"] as! String
                let name = value["name"] as! String
                let path = value["path"] as! [String]
                var targets = [Target]()
                for center in path {
                    let targetCenter = CGPointFromString(center)
                    let pointCenter = self.convertScaleToPoint(point: targetCenter)
                    let target = Target(targetCenter: pointCenter, isUserInteractionEnabled: false, type: .normal)
                    targets.append(target)
                }
                let startPoint = value["startPoint"] as! String
                let endPoint = value["endPoint"] as! String
                let startCenter = self.convertScaleToPoint(point: CGPointFromString(startPoint))
                let endCenter = self.convertScaleToPoint(point: CGPointFromString(endPoint))
                
                let startTarget = Target(targetCenter: startCenter, isUserInteractionEnabled: false, type: .start)
                let endTarget = Target(targetCenter: endCenter, isUserInteractionEnabled: false, type: .end)
                
                targets.append(startTarget)
                targets.append(endTarget)
                
                let route = Route(name: name, creater: self.firebaseUser!.displayName!, difficulty: difficulty, targets: targets)
                self.selectField!.tempRoute = route
            }else{
                self.selectField!.tempRoute = nil
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FinishLoadingRouteData"), object: nil)
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
        
        let routeRef = ref.child("Route").child(field.fieldId).child(route.routeId!)
        let updateRating = ["rating": route.rating] as [String : Any]
        routeRef.updateChildValues(updateRating)
    }
    
    func loadingFinishRouteFromFirebase() {
        ref.child("FinishedRoute").child(firebaseUser!.uid).observe(.value, with: { snapshot in
            
            let value = snapshot.value as? NSDictionary
            if let finishRoute = value as? Dictionary<String, Any> {
                self.finishRoutes = [String](finishRoute.keys)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FinishLoadingRouteData"), object: nil)
        })
    }
    
    func convertPointToScale(point: CGPoint) -> CGPoint {
        
        return CGPoint(x: point.x / mainHeight, y: point.y / mainWidth)
    }
    
    func convertScaleToPoint(point: CGPoint) -> CGPoint {
       
        return CGPoint(x: point.x * mainHeight, y: point.y * mainWidth)
    }
    
    
}


