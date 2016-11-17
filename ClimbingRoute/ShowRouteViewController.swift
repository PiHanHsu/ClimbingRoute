//
//  ShowRouteViewController.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit
import Firebase

enum ShowRouteMode {
    case create
    case edit
    case playing
}

class ShowRouteViewController: UIViewController {
    
    var route: Route?
    var routeMode: ShowRouteMode?
    var targetArray = [Target]()
    let ref = FIRDatabase.database().reference()
    var currentField: Field?
    var currentUser: FIRUser?
    var pickerData = [String]()
    var difficulty: String?
    var haveRated = false
    var hasTempRoute = false
    var routeName: String?
    var startTarget: Target?
    var endTarget: Target?
    
    @IBOutlet var createButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var setDifficultyButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var routeNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        currentUser = DataSource.shareInstance.firebaseUser
        currentField = DataSource.shareInstance.selectField
        
        if let mode = routeMode {
            switch mode {
            case .create:
                createButton.isHidden = false
                doneButton.setTitle("儲存", for: .normal)
                cancelButton.setTitle("取消", for: .normal)
                
                startTarget = Target(targetCenter: CGPoint(x: 100, y: 200), isUserInteractionEnabled: true, type: .start)
                endTarget = Target(targetCenter: CGPoint(x: 500, y: 100), isUserInteractionEnabled: true, type: .end)
                
                view.addSubview(startTarget!)
                view.addSubview(endTarget!)
                
            case .edit:
                displayRoute()
                createButton.isHidden = false
                targetArray = route!.targets!
                difficulty = route!.difficulty
                doneButton.setTitle("儲存", for: .normal)
                cancelButton.setTitle("取消/刪除", for: .normal)
            case .playing:
                displayRoute()
                checkHaveRated()
                doneButton.setTitle("完攀", for: .normal)
                cancelButton.setTitle("下次再試", for: .normal)
                setDifficultyButton.isEnabled = false
                routeNameTextField.isEnabled = false
                
            }
        }
        
        //set pickerData
        pickerData = ["v0","v1","v2","v3","v4","v5","v6","v7","v8","v9","v10","v11","v12","v13","v14","v15"]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setUpButtonLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setUpButtonLayout() {
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.cyan.cgColor
        cancelButton.layer.cornerRadius = 15
        
        setDifficultyButton.layer.borderWidth = 1
        setDifficultyButton.layer.borderColor = UIColor.cyan.cgColor
        setDifficultyButton.layer.cornerRadius = 15
        
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = UIColor.cyan.cgColor
        doneButton.layer.cornerRadius = 15
        
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = UIColor.yellow.cgColor
        createButton.layer.cornerRadius = 15
        
        routeNameTextField.layer.cornerRadius = 5
    }
    
    @IBAction func quitButton(_ sender: AnyObject) {
        
        if let mode = routeMode {
            switch mode {
            case .create:
                self.dismiss(animated: true, completion: nil)
            case .edit:
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cancel = UIAlertAction(title: "取消修改", style: .default, handler: { (UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                })
                
                let deleteTemp = UIAlertAction(title: "刪除路線", style: .default, handler: { (UIAlertAction) in
                    self.deleteTempRoute()
                    self.dismiss(animated: true, completion: nil)
                })
                
                alert.addAction(cancel)
                alert.addAction(deleteTemp)
                
                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = cancelButton
                    popoverController.sourceRect = cancelButton.bounds
                }
                
                present(alert, animated: true, completion: nil)
                
                
            case .playing:
                showRatingAlert()
                
            }
            
        }
        
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        
        if let mode = routeMode {
            if mode == .create || mode == .edit {
                
                guard targetArray.count > 0 else {
                    
                    let alert = UIAlertController(title: "岩點數不足", message: "請新增岩點後再儲存", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                guard difficulty != nil else{
                    setDiffuculty(self)
                    return
                }
                
                routeName = routeNameTextField.text
                guard (routeName != nil && (routeName?.characters.count)! > 0) else {
                    setRouteName()
                    return
                }
                
                showSaveOpiton()
            }else if mode == .playing {
                
                let finishRef = self.ref.child("FinishedRoute").child(currentUser!.uid)
                let routeFinised = [route!.routeId! : true] as [String : Any]
                finishRef.updateChildValues(routeFinised)
                showRatingAlert()
            }
        }
        
    }
    
    func showSaveOpiton() {
        
        let alert = UIAlertController(title: "請選擇暫存或發佈", message: "路線發佈後即無法修改", preferredStyle: .alert)
        let tempSave = UIAlertAction(title: "暫存", style: .default, handler: { (UIAlertAction) in
            let tempRef = self.ref.child("Temp").child(self.currentUser!.uid).child(self.currentField!.fieldId)
            var path = [String]()
            for target in self.targetArray {
                let scaleCenter = DataSource.shareInstance.convertPointToScale(point: target.center)
                let center = NSStringFromCGPoint(scaleCenter)
                path.append(center)
            }
            let startCenter = DataSource.shareInstance.convertPointToScale(point: self.startTarget!.center)
            let startPoint = NSStringFromCGPoint(startCenter)
            let endCenter = DataSource.shareInstance.convertPointToScale(point: self.endTarget!.center)
            let endPoint = NSStringFromCGPoint(endCenter)
            
            let tempRoute = ["name" : self.routeName! ,"path" : path, "difficulty" : self.difficulty!, "startPoint" : startPoint, "endPoint" : endPoint] as [String : Any]
            
            tempRef.setValue(tempRoute)
            self.hasTempRoute = true
            self.dismiss(animated: true, completion: nil)
        })
        let saveAction = UIAlertAction(title: "儲存發佈", style: .default, handler: { (UIAlertAction) in
            self.saveRouteToFireBase()
            self.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(tempSave)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func setDiffuculty(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "設定難度", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let pickerFrame = CGRect(x: 15, y: 52, width: 240, height: 150)
        let picker: UIPickerView = UIPickerView(frame: pickerFrame)
        
        picker.delegate = self
        picker.dataSource = self
        
        alert.view.addSubview(picker)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.difficulty = self.pickerData[picker.selectedRow(inComponent: 0)]
            self.setDifficultyButton.setTitle("\(self.difficulty!)", for: .normal)
            
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func setRouteName() {
        let alert = UIAlertController(title: "請輸入路線名稱", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
            self.routeNameTextField.becomeFirstResponder()
        })
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func checkHaveRated() {
        
        ref.child("Rating").child(route!.routeId!).observe(.value, with: { (snapshot) in
            for child in snapshot.children {
                let childSnapshot = snapshot.childSnapshot(forPath: (child as AnyObject).key)
                let value = childSnapshot.value as? NSDictionary
                let userId = value?["name"] as? String
                if self.currentUser!.uid == userId {
                    self.haveRated = true
                }
            }
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
    
    
    func saveRouteToFireBase() {
        var path = [String]()
        for target in self.targetArray {
            let scaleCenter = DataSource.shareInstance.convertPointToScale(point: target.center)
            let center = NSStringFromCGPoint(scaleCenter)
            path.append(center)
        }
        
        let fieldId = self.currentField?.fieldId
        let startCenter = DataSource.shareInstance.convertPointToScale(point: startTarget!.center)
        let startPoint = NSStringFromCGPoint(startCenter)
        let endCenter = DataSource.shareInstance.convertPointToScale(point: endTarget!.center)
        let endPoint = NSStringFromCGPoint(endCenter)
        
        let routeRef = self.ref.child("Route").child(fieldId!).childByAutoId()
        
        if let creater = self.currentUser?.displayName {
            if let difficulty = self.difficulty {
                let routeInfo = ["name" : routeName!, "creater" : creater, "difficulty" : difficulty, "path" : path, "rating" : 0.0, "startPoint" : startPoint, "endPoint" : endPoint] as [String : Any]
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
        let target = Target(targetCenter: CGPoint(x: 120, y: 60), isUserInteractionEnabled: true, type: .normal)
        targetArray.append(target)
        view.addSubview(target)
    }
    
    func displayRoute() {
        for target in (route?.targets)! {
            if target.type == .start {
                startTarget = target
            }else if target.type == .end {
                endTarget = target
            }
            
            view.addSubview(target)
        }
        
        if let difficulty = route?.difficulty {
            setDifficultyButton.setTitle("\(difficulty)", for: .normal)
        }
        routeNameTextField.text = route?.name
        
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

