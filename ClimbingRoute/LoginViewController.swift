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

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    let mainFrame = UIApplication.shared.keyWindow?.bounds
    var firebaseUser: FIRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FBSDKAccessToken.current() != nil {
            loginFirebase()
        }
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        if (FBSDKAccessToken.current() != nil) {
            print("FB Logined")
            print("FB Token: \(FBSDKAccessToken.current().tokenString)")
        }

        createFakeData()
    
    }
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        loginFirebase()
        
    }
    

    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginFirebase() {
        if FBSDKAccessToken.current() != nil {
            let fbToken = FBSDKAccessToken.current().tokenString
            let fireCredential = FIRFacebookAuthProvider.credential(withAccessToken: fbToken!)
            FIRAuth.auth()?.signIn(with: fireCredential, completion: {
                (user, error) in
                print("error: \(error?.localizedDescription)")
                print("Uid: \(user?.uid)")
                print("Name: \(user?.displayName)")
                
                DataSource.shareInstance.firebaseUser = user
                self.performSegue(withIdentifier: "SelectField", sender: self)
                
            })
        } else {
            //
        }

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
