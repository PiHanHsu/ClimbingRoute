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

    @IBOutlet var indicator: UIActivityIndicatorView!
    let mainFrame = UIApplication.shared.keyWindow?.bounds
    var firebaseUser: FIRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = CGPoint(x: view.center.x, y: view.center.y * 1.5)
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        //createFakeData()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if FBSDKAccessToken.current() != nil {
            print("FB login")
            indicator.isHidden = false
            indicator.startAnimating()
            loginFirebase()
        }else{
            indicator.isHidden = true
        }
    }
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        loginFirebase()
        
    }
    

    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
         indicator.isHidden = true
    }
    
    func loginFirebase() {
        if FBSDKAccessToken.current() != nil {
            let fbToken = FBSDKAccessToken.current().tokenString
            let fireCredential = FIRFacebookAuthProvider.credential(withAccessToken: fbToken!)
            FIRAuth.auth()?.signIn(with: fireCredential, completion: {
                (user, error) in
                //print("error: \(error?.localizedDescription)")
                //print("Uid: \(user?.uid)")
                //print("Name: \(user?.displayName)")
                
                DataSource.shareInstance.firebaseUser = user
                self.performSegue(withIdentifier: "SelectField", sender: self)
                self.indicator.stopAnimating()
             DataSource.shareInstance.loadDataFromFirebase()   
            })
        } else {
            //
        }

    }
    
 }
