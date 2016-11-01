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
    var pickerData = [String]()
    var difficulty: String?
    
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
        
        //set pickerData
        pickerData = ["v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15"]
        
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
          let alert = UIAlertController(title: "設定難度", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            //Create a frame (placeholder/wrapper) for the picker and then create the picker
            
            let pickerFrame = CGRect(x: 15, y: 52, width: 240, height: 150)
            let picker: UIPickerView = UIPickerView(frame: pickerFrame)
            
            //set the pickers datasource and delegate
            picker.delegate = self
            picker.dataSource = self
            
            //Add the picker to the alert controller
            alert.view.addSubview(picker)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                self.difficulty = self.pickerData[picker.selectedRow(inComponent: 0)]
                self.saveRoute()
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)

          present(alert, animated: true, completion: nil)
            
        }else {
            let alert = UIAlertController(title: "給這條路線一個評分吧！", message: "\n\n\n", preferredStyle: .alert)
            let ratingView = CosmosView(frame: CGRect(x: 60, y: 70, width: 210, height: 30))
            ratingView.starSize = 25
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
                let ratingRef = self.ref.child("Rating").child(self.route!.routeId!).childByAutoId()
                
                let stars = ratingView.rating
                let rating = ["name" : self.currentUser!.uid,"stars" : stars] as [String : Any]
                
                ratingRef.setValue(rating)
                DataSource.shareInstance.updateRatingDataToRoute(field: self.currentField!, route: self.route!)
                self.dismiss(animated: true, completion: nil)
                
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alert.view.addSubview(ratingView)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func saveRoute() {
        let alert = UIAlertController(title: "儲存此路線", message: nil, preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "儲存完離開", style: .default, handler: { (UIAlertAction) in
            self.saveRouteToFireBase()
            self.dismiss(animated: true, completion: nil)
        })
        
        let continueAction = UIAlertAction(title: "儲存完繼續新增路線", style: .default, handler: { (UIAlertAction) in
            self.saveRouteToFireBase()
            for target in self.targetArray{
                target.imageView.removeFromSuperview()
            }
            self.targetArray.removeAll()
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(continueAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveRouteToFireBase() {
        var path = [String]()
        for target in self.targetArray {
            let center = NSStringFromCGPoint(target.imageView.center)
            path.append(center)
        }
        
        let fieldId = self.currentField?.fieldId
        
        let routeRef = self.ref.child("Route").child(fieldId!).childByAutoId()
        
        if let name = self.currentUser?.displayName {
            if let difficulty = self.difficulty {
                let routeInfo = ["creater" : name, "difficulty" : difficulty, "path" : path, "rating" : 0.0] as [String : Any]
                routeRef.setValue(routeInfo)
            }
        }
    }
    
    @IBAction func createButtonPressed(_ sender: AnyObject) {
        let target = Target(targetCenter: nil)
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


extension ShowRouteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return 16
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let difficulty = pickerData[row]
        return difficulty
            
        }

}
