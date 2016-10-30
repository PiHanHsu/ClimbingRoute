//
//  ShowRouteViewController.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit
import Firebase

class ShowRouteViewController: UIViewController {

    var route: Route?
    var isEditMode = false
    var targetArray = [Target]()
    let ref = FIRDatabase.database().reference()
    var currentField: Field?
    var currentUser: FIRUser?
    
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        currentUser = DataSource.shareInstance.firebaseUser
        currentField = DataSource.shareInstance.selectField
        
        if isEditMode {
           createButton.isHidden = false
           doneBarButton.title = "儲存"
        }
        
        if route != nil {
            displayRoute()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func quitButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        if isEditMode {
          let alert = UIAlertController(title: "儲存此路線", message: nil, preferredStyle: .actionSheet)
          let okAction = UIAlertAction(title: "儲存完離開", style: .default, handler: { (UIAlertAction) in
            
            var path = [String]()
            for target in self.targetArray {
                let center = NSStringFromCGPoint(target.imageView.center)
                path.append(center)
            }
            
            let fieldId = self.currentField?.fieldId
            
            let routeRef = self.ref.child("Route").child(fieldId!).childByAutoId()
            
            if let name = self.currentUser?.displayName {
                let routeInfo = ["creater" : name, "path" : path] as [String : Any]
                routeRef.setValue(routeInfo)
            }
             self.dismiss(animated: true, completion: nil)
          })
            
          let continueAction = UIAlertAction(title: "儲存完繼續新增路線", style: .default, handler: { (UIAlertAction) in
                
           })
            
          let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
          alert.addAction(okAction)
          alert.addAction(continueAction)
          alert.addAction(cancelAction)
            
          present(alert, animated: true, completion: nil)
            
        }else {
            let alert = UIAlertController(title: "給這條路線一個評分吧！", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func createButtonPressed(_ sender: AnyObject) {
        let target = Target()
        targetArray.append(target)
        view.addSubview(target.imageView)
    }
    
    func displayRoute() {
        for target in (route?.targets)! {
            view.addSubview(target.imageView)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
