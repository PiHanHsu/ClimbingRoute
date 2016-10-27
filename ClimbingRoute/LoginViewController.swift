//
//  LoginViewController.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    let mainFrame = UIApplication.shared.keyWindow?.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createFakeData()
        print("Fileds: \(DataSource.shareInstance.Fields.count)")
        print("Routes: \(DataSource.shareInstance.Fields[0].routes?.count)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func createFakeData() {
        //create Fake Data for testing
        var field1 = Field(name: "紅石")
        var field2 = Field(name: "攀岩小館")
        var fieldsArray = [field1, field2]
        var route1 = Route(creater: "PiHan", difficulty: "V0-1", targets: [Target]())
        var route2 = Route(creater: "PiHan", difficulty: "V0-2", targets: [Target]())
        var route3 = Route(creater: "PiHan", difficulty: "V0-3", targets: [Target]())
        field1.routes = [route1, route2, route3]
        field2.routes = [route1, route2, route3]
        
        for i in 0...17 {
            let randomNumX:UInt32 = arc4random_uniform(100) + 1
            let randomNumY:UInt32 = arc4random_uniform(100) + 1
            
            let target = Target()
            let x: CGFloat = CGFloat(randomNumX)/100 * 375
            let y: CGFloat = CGFloat(randomNumY)/100 * 667
            
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
