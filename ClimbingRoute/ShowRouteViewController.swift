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
    var selectedTarget: Target?
    weak var actionToEnable : UIAlertAction?
    
    @IBOutlet var createButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    
    @IBOutlet var ratioStepper: UIStepper!
    @IBOutlet var deleteButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //disable sleep mode
        UIApplication.shared.isIdleTimerDisabled = true
        
        //data
        currentUser = DataSource.shareInstance.firebaseUser
        currentField = DataSource.shareInstance.selectField
        
        //set up view
        view.backgroundColor = UIColor.black
        ratioStepper.isHidden = true
        deleteButton.isHidden = true
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(self.tapScreen(_:)))
        
        if let mode = routeMode {
            switch mode {
            case .create:
                createButton.isHidden = false
                
                startTarget = Target(targetCenter: CGPoint(x: 100, y: 200), isUserInteractionEnabled: true, type: .start)
                endTarget = Target(targetCenter: CGPoint(x: 500, y: 100), isUserInteractionEnabled: true, type: .end)
                
                targetArray.append(startTarget!)
                targetArray.append(endTarget!)
                
                view.addSubview(startTarget!)
                view.addSubview(endTarget!)
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(tapScreen)
                
            case .edit:
                displayRoute()
                createButton.isHidden = false
                targetArray = route!.targets!
                difficulty = route!.difficulty
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(tapScreen)
                
            case .playing:
                displayRoute()
                checkHaveRated()
                                
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
    
    // MARK: Setup view
    
    func setUpButtonLayout() {
                
        createButton.layer.borderWidth = 1
        createButton.layer.borderColor = UIColor.yellow.cgColor
        createButton.layer.cornerRadius = 15
        
    }
    
    func displayRoute() {
        for target in (route?.targets)! {
            target.delegate = self
            if target.type == .start {
                startTarget = target
            }else if target.type == .end {
                endTarget = target
            }
            
            if target.isSelected {
                target.layer.borderWidth = 2.0
                target.layer.borderColor = UIColor.red.cgColor
            }else {
                target.layer.borderWidth = 0
                
            }
            view.addSubview(target)
        }
        
    }

    //MARK: IBAction

    @IBAction func menuButton(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let subview = alert.view.subviews.first! as UIView
        
        let alertContentView = subview.subviews.first! as UIView
        
        alertContentView.backgroundColor = UIColor.white
        alertContentView.layer.cornerRadius = 15
        alert.view.tintColor = UIColor.green
        
        let tempSave = UIAlertAction(title: "暫存", style: .default, handler: { UIAlertAction in
            self.saveTempRouteToFirebase()
            self.dismiss(animated: true, completion: nil)
        })
        let save = UIAlertAction(title: "儲存發佈", style: .default, handler: { UIAlertAction in
            self.setRouteName()
        })
        let cancel = UIAlertAction(title: "取消", style: .default, handler: {  UIAlertAction in
            self.dismiss(animated: true, completion: nil)
        })
        
        let deleteTemp = UIAlertAction(title: "刪除路線", style: .default, handler: {  UIAlertAction in
            self.deleteTempRoute()
            self.dismiss(animated: true, completion: nil)
        })
        
        let finishRoute = UIAlertAction(title: "完攀", style: .default, handler: {  UIAlertAction in
            
            let finishRef = self.ref.child("FinishedRoute").child(self.currentUser!.uid)
            let routeFinised = [self.route!.routeId! : true] as [String : Any]
            finishRef.updateChildValues(routeFinised)
            self.showRatingAlert()
        })
        
        let tryNextTime = UIAlertAction(title: "下次再嘗試", style: .default, handler: {  UIAlertAction in
            self.showRatingAlert()
        })

        
        if let mode = routeMode {
            switch mode {
            case .create:
                
                alert.addAction(tempSave)
                alert.addAction(save)
                alert.addAction(cancel)
                
                self.present(alert, animated: true, completion: nil)
            case .edit:
                
                alert.addAction(tempSave)
                alert.addAction(save)
                alert.addAction(cancel)
                alert.addAction(deleteTemp)
                
                self.present(alert, animated: true, completion: nil)
                
            case .playing:
                alert.addAction(finishRoute)
                alert.addAction(tryNextTime)
                
                self.present(alert, animated: true, completion: nil)
            }
        }

    }
    
    @IBAction func stepperPressed(_ sender: Any) {
        if let target = selectedTarget {
            target.ratio = ratioStepper.value
            refresh()
        }
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if let target = selectedTarget {
            target.removeFromSuperview()
            targetArray.remove(object: target)
        }
        ratioStepper.isHidden = true
        deleteButton.isHidden = true
    }
    
    @IBAction func createButtonPressed(_ sender: AnyObject) {
        let target = Target(targetCenter: CGPoint(x: 120, y: 60), isUserInteractionEnabled: true, type: .normal)
        target.delegate = self
        targetArray.append(target)
        view.addSubview(target)
    }
    
    func tapScreen(_ recognizer: UITapGestureRecognizer) {
        
        ratioStepper.isHidden = true
        deleteButton.isHidden = true
        
        for target in targetArray {
            target.isSelected = false
        }
        refresh()
    }
    
    //MARK: prepare to Save
    
    func setRouteName() {
        let alert = UIAlertController(title: "設定路線名稱", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "輸入路線名稱"
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)

        }
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                let textField = alert.textFields![0] as UITextField
                self.routeName = textField.text
                
                self.setDifficulty()
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
        
            self.actionToEnable = okAction
            okAction.isEnabled = false
        
            present(alert, animated: true, completion: nil)
    }
    
    func textChanged(_ sender:UITextField) {
        self.actionToEnable?.isEnabled  = (sender.text!.characters.count >= 1 )
    }
    
    func setDifficulty() {
        
        let alert = UIAlertController(title: "設定難度", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        
        let pickerFrame = CGRect(x: 15, y: 52, width: 240, height: 150)
        let picker: UIPickerView = UIPickerView(frame: pickerFrame)
        
        picker.delegate = self
        picker.dataSource = self
        
        alert.view.addSubview(picker)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.difficulty = self.pickerData[picker.selectedRow(inComponent: 0)]
            
            self.saveRouteToFireBase()
            self.dismiss(animated: true, completion: nil)
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
    
    //MARK: Save to Firebase
    
    func saveTempRouteToFirebase() {
        let tempRef = self.ref.child("Temp").child(self.currentUser!.uid).child(self.currentField!.fieldId)
        
        var path = [[String: Any]]()
        for target in targetArray {
            if target.type == .normal {
                let scaleCenter = DataSource.shareInstance.convertPointToScale(point: target.center)
                let center = NSStringFromCGPoint(scaleCenter)
                let targetInfo = ["position" : center, "ratio" : target.ratio] as [String: Any]
                path.append(targetInfo)
            }
            
        }
        let startCenter = DataSource.shareInstance.convertPointToScale(point: self.startTarget!.center)
        let startPoint = NSStringFromCGPoint(startCenter)
        let endCenter = DataSource.shareInstance.convertPointToScale(point: self.endTarget!.center)
        let endPoint = NSStringFromCGPoint(endCenter)
        
        let tempRoute = [ "path" : path, "startPoint" : startPoint, "endPoint" : endPoint] as [String : Any]
        
        tempRef.setValue(tempRoute)
        self.hasTempRoute = true
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveRouteToFireBase() {
        var path = [[String: Any]]()
        for target in targetArray {
            if target.type == .normal {
                let scaleCenter = DataSource.shareInstance.convertPointToScale(point: target.center)
                let center = NSStringFromCGPoint(scaleCenter)
                let targetInfo = ["position" : center, "ratio" : target.ratio] as [String: Any]
                path.append(targetInfo)
            }
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
        dismiss(animated: true, completion: nil)
        
    }
}

extension ShowRouteViewController: TargetDelegate {
    func tapTarget(tapTarget: Target) {
        
        ratioStepper.isHidden = false
        deleteButton.isHidden = false
        
        for target in targetArray {
            target.isSelected = false
        }
        
        tapTarget.isSelected = true
        selectedTarget = tapTarget
        ratioStepper.value = selectedTarget!.ratio
        refresh()
    }
    
    func refresh() {
        for target in targetArray {
            target.removeFromSuperview()
        }
        
        for target in targetArray {
            if target.type == .start {
                startTarget = target
            }else if target.type == .end {
                endTarget = target
            }
            
            if target.isSelected {
                target.layer.borderWidth = 2.0
                target.layer.borderColor = UIColor.red.cgColor
            }else {
                target.layer.borderWidth = 0
                
            }
            view.addSubview(target)
        }
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

