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
        nameLabel.font = nameLabel.font.withSize(14)
        imageView.addSubview(self.nameLabel)
        
    }
    
    func dragTarget(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: mainView)
        imageView.center.x = point.x
        imageView.center.y = point.y
    }

}

class TargetPoint: UIImageView, UIGestureRecognizerDelegate {
    var nameLabel: UILabel!
    var targetCenter: CGPoint
    var type: TargetType
    let mainView = UIApplication.shared.keyWindow?.superview
    
    
    init(targetCenter: CGPoint, isUserInteractionEnabled: Bool, type: TargetType) {
        
        self.targetCenter = targetCenter
        self.type = type
        
        super.init(frame: CGRect(x: targetCenter.x, y: targetCenter.y, width: 40, height: 40))
        self.isUserInteractionEnabled = isUserInteractionEnabled
        
        self.layer.cornerRadius = self.frame.width / 2
        
        let drag = UIPanGestureRecognizer(target: self, action: #selector(self.dragTarget(_:)))
        self.addGestureRecognizer(drag)
        
        let delete = UILongPressGestureRecognizer(target: self, action: #selector(self.deleteTarget(_:)))
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 10, width: self.frame.width, height: self.frame.height - 20))
        nameLabel.textAlignment = .center
        nameLabel.font = nameLabel.font.withSize(14)
        
        switch type {
        case .normal:
            self.backgroundColor = UIColor.white
            self.addGestureRecognizer(delete)
        case .start:
            self.backgroundColor = UIColor.green
            self.nameLabel.text = "起攀"
        case .end:
            self.backgroundColor = UIColor.red
            self.nameLabel.text = "完攀"
        }
        
        self.addSubview(self.nameLabel)
        
    }
    
    
    func dragTarget(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: mainView)
        self.center.x = point.x
        self.center.y = point.y
    }
    
    func deleteTarget(_ recognizer: UILongPressGestureRecognizer) {
        self.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum TargetType {
    case normal
    case start
    case end
}
