//
//  LoginViewController.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {

    let mainFrame = UIApplication.shared.keyWindow?.bounds
    
    //let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let childRouteRef = self.ref.child("Trainer").childByAutoId()
//        let value = ["trainer": "tester"]
//        childRouteRef.updateChildValues(value)
        createFakeData()
    
    }
    
    @IBAction func fbLogin(sender: AnyObject) {
                let facebookLogin = FBSDKLoginManager()
        
//        facebookLogin.logIn(withReadPermissions: ["email"], from: self, handler: {
//            (facebookresult, facebookError) -> Void in
//            
//            if facebookError != nil {
//                print("FaceBook login failed. Error: \(facebookError)")
//                
//            }else if (facebookresult?.isCancelled)!{
//                print("Facebook login was cancelled.")
//                
//            }else {
//                let accessToken = FBSDKAccessToken.current().tokenString
//                print(accessToken)
//                
//            }
//        })
        
    }


    func createFakeData() {
        //create Fake Data for testing
        let field1 = Field(name: "紅石")
        let field2 = Field(name: "攀岩小館")
        let fieldsArray = [field1, field2]
        let route1 = Route(creater: "PiHan", difficulty: "V0-1", targets: [Target]())
        let route2 = Route(creater: "PiHan", difficulty: "V0-2", targets: [Target]())
        let route3 = Route(creater: "PiHan", difficulty: "V0-3", targets: [Target]())
        field1.routes = [route1, route2, route3]
        field2.routes = [route1, route2, route3]
        
        for i in 0...17 {
            let randomNumX:UInt32 = arc4random_uniform(80) + 1
            let randomNumY:UInt32 = arc4random_uniform(70) + 1
            
            let target = Target()
            let x: CGFloat = (CGFloat(randomNumX)/100 + 0.1) * 667
            let y: CGFloat = (CGFloat(randomNumY)/100 + 0.2) * 375
            
            target.imageView.center = CGPoint(x: x, y: y)
            if i % 3 == 0 {
               route1.targets?.append(target)
            }else if i % 3 == 1 {
               route2.targets?.append(target)
            }else {
               route3.targets?.append(target)
            }
        }
        
        
        DataSource.shareInstance.Fields = fieldsArray
    }
}
