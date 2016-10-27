//
//  Target.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

class Target: NSObject, UIGestureRecognizerDelegate {

    var imageView = UIImageView(frame: CGRect(x: 120, y: 60, width: 40, height: 40))
    let mainView = UIApplication.shared.keyWindow?.superview
    let mainFrame = UIApplication.shared.keyWindow?.bounds
    
    override init(){
       super.init()
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.yellow
        imageView.layer.cornerRadius = 20
        
        let dragBall = UIPanGestureRecognizer(target: self, action: #selector(self.dragTarget(_:)))
        imageView.addGestureRecognizer(dragBall)
        //dragBall.delegate = self
        
    }
    
    func dragTarget(_ recognizer: UIPanGestureRecognizer) {
        print("drag")
        let point = recognizer.location(in: mainView)
        imageView.center.x = point.x
        imageView.center.y = point.y
    
    }


}
