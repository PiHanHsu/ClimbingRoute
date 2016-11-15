//
//  ShowRouteViewController.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit
import Firebase

enum showRouteMode {
    case create
    case edit
    case playing
}

class ShowRouteViewController: UIViewController {
    
    var route: Route?
    var isCreateMode = false
    var isEditMode = false
    var isPlayingMode = false
    var targetArray = [Target]()
    let ref = FIRDatabase.database().reference()
    var currentField: Field?
    var currentUser: FIRUser?
    var pickerData = [String]()
    var difficulty: String?
    var haveRated = false
    var hasTempRoute = false
    
    @IBOutlet var cancelBarButton: UIBarButtonItem!
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var setDifficultyBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        currentUser = DataSource.shareInstance.firebaseUser
        currentField = DataSource.shareInstance.selectField
        
        if isCreateMode {
            createButton.isHidden = false
            doneBarButton.title = "儲存"
            cancelBarButton.title = "取消"
        }else if isEditMode {
            displayRoute()
            createButton.isHidden = false
            targetArray = route!.targets!
            difficulty = route!.difficulty
            doneBarButton.title = "儲存"
            cancelBarButton.title = "取消"
            
        }else {
            
            displayRoute()
            checkHaveRated()
            doneBarButton.title = "完攀"
            cancelBarButton.title = "下次再試"
        }
        
        //set pickerData
        pickerData = ["v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15"]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     @IBAction func quitButton(_ sender: AnyObject) {
        
        if isPlayingMode {
            showRatingAlert()
        }else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        if isCreateMode || isEditMode {
            if difficulty != nil {
                let alert = UIAlertController(title: "請選擇暫存或發佈", message: "路線發佈後即無法修改", preferredStyle: .alert)
                let tempSave = UIAlertAction(title: "暫存", style: .default, handler: { (UIAlertAction) in
                    let tempRef = self.ref.child("Temp").child(self.currentUser!.uid).child(self.currentField!.fieldId)
                    var path = [String]()
                    for target in self.targetArray {
                        let scaleCenter = DataSource.shareInstance.convertPointToScale(point: target.imageView.center)
                        let center = NSStringFromCGPoint(scaleCenter)
                        path.append(center)
                    }
                    let tempRoute = ["path": path, "difficulty" : self.difficulty!] as [String : Any]
                    
                    tempRef.setValue(tempRoute)
                    self.hasTempRoute = true
                    self.dismiss(animated: true, completion: nil)
                })
                let saveAction = UIAlertAction(title: "儲存發佈", style: .default, handler: { (UIAlertAction) in
                     self.saveRoute()
                })
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                alert.addAction(tempSave)
                alert.addAction(saveAction)
                
                present(alert, animated: true, completion: nil)
                
            }else {
                setDiffuculty(sender: self)
            }
            
        }else if isEditMode{
            if difficulty != nil {
                saveRoute()
            }else {
                setDiffuculty(sender: self)
            }
        }else {
            
            let finishRef = self.ref.child("FinishedRoute").child(currentUser!.uid)
            let routeFinised = [route!.routeId! : true] as [String : Any]
            finishRef.updateChildValues(routeFinised)
            self.showRatingAlert()
        }
    }
    
    @IBAction func setDiffuculty(_ sender: Any) {
        
        guard !isPlayingMode else {
            return
        }
        
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
            self.setDifficultyBarButton.title = "\(self.difficulty!)    "
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func checkHaveRated() {
        
        ref.child("Rating").child(route!.routeId!).observe(.value, with: { (snapshot) in
            for child in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (child as AnyObject).key)
                let value = childSnapshot.value as? NSDictionary
                let userId = value?["name"] as? String
                if self.currentUser!.uid == userId {
                    //print("find")
                    self.haveRated = true
                }
            }
            //print("not find!!")
        })
        
}
    
    func showRatingAlert() {
        
        if haveRated {
            dismiss(animated: true, completion: nil)
        }else{
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
            
            let cancelAction = UIAlertAction(title: "下次再評分", style: .default, handler: { alertAction in
                self.dismiss(animated: true, completion: nil)
            })
            
            alert.view.addSubview(ratingView)
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func saveRoute() {
        var title = ""
        
        if isCreateMode || isEditMode {
            
            if targetArray.count < 2 {
                let alert = UIAlertController(title: "岩點數不足", message: "請新增岩點後在儲存", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(okAction)
                
                present(alert, animated: true, completion: nil)
                
                return
            }
            saveRouteToFireBase()
            dismiss(animated: true, completion: nil)
            
//            let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
//            title = "儲存此路線"
//            
//            let okAction = UIAlertAction(title: "儲存完離開", style: .default, handler: { (UIAlertAction) in
//                self.saveRouteToFireBase()
//                self.dismiss(animated: true, completion: nil)
//            })
//            
//            let continueAction = UIAlertAction(title: "儲存完繼續新增路線", style: .default, handler: { (UIAlertAction) in
//                self.saveRouteToFireBase()
//                for target in self.targetArray{
//                    target.imageView.removeFromSuperview()
//                }
//                self.targetArray.removeAll()
//            })
//            
//            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
//            
//            alert.addAction(okAction)
//            alert.addAction(continueAction)
//            alert.addAction(cancelAction)
//            
//            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func saveRouteToFireBase() {
        var path = [String]()
        for target in self.targetArray {
            let scaleCenter = DataSource.shareInstance.convertPointToScale(point: target.imageView.center)
            let center = NSStringFromCGPoint(scaleCenter)
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
        
        if hasTempRoute {
            deleteTempRoute()
        }
        
    }
    
    func deleteTempRoute() {
        let tempRef = ref.child("Temp").child(currentUser!.uid).child(currentField!.fieldId)
        tempRef.setValue(nil)
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
        setDifficultyBarButton.title = "\(route!.difficulty)    "
    }
    
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
