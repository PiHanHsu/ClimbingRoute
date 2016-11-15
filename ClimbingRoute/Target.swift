//
//  Target.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

class Target: NSObject, UIGestureRecognizerDelegate {

    var imageView: UIImageView!
    var nameLabel: UILabel!
    var targetCenter: CGPoint?
    let mainView = UIApplication.shared.keyWindow?.superview
    let mainFrame = UIApplication.shared.keyWindow?.bounds
    

    init(targetCenter: CGPoint?){
       super.init()
        
        if targetCenter != nil{
            self.targetCenter = targetCenter
        }else {
            self.targetCenter = CGPoint(x: 120, y: 60)
        }
        
        imageView = UIImageView(frame: CGRect(x: (self.targetCenter?.x)!, y: (self.targetCenter?.y)!, width: 40, height: 40))
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = UIColor.white
        imageView.layer.cornerRadius = self.imageView.frame.width / 2
        
        let dragBall = UIPanGestureRecognizer(target: self, action: #selector(self.dragTarget(_:)))
        imageView.addGestureRecognizer(dragBall)
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 10, width: self.imageView.frame.width, height: self.imageView.frame.height - 20))
        nameLabel.textAlignment = .center
        imageView.addSubview(self.nameLabel)
        
    }
    
    func dragTarget(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: mainView)
        imageView.center.x = point.x
        imageView.center.y = point.y
    }

}

