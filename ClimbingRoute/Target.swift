//
//  Target.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 26/10/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import UIKit

protocol TargetDelegate {
    func tapTarget(tapTarget: Target)
}

class Target: UIImageView {
    var nameLabel: UILabel!
    var targetCenter: CGPoint
    var type: TargetType
    let mainView = UIApplication.shared.keyWindow?.superview
    var targetSize:CGFloat = 40 {
        willSet(newValue) {
            
            let x = self.center.x - newValue / 2
            let y = self.center.y - newValue / 2
            self.frame = CGRect(x: x, y: y, width: newValue, height: newValue)
           
            self.layer.cornerRadius = self.frame.width / 2
        }
    }
    var isSelected = false
    var delegate: TargetDelegate?
    var ratio = 1.0 {
        willSet(newValue) {
            self.targetSize = CGFloat(40.0 * newValue)
        }
    }
    
    
    init(targetCenter: CGPoint, isUserInteractionEnabled: Bool, type: TargetType) {
        
        self.targetCenter = targetCenter
        self.type = type
        
        let x = targetCenter.x - targetSize / 2
        let y = targetCenter.y - targetSize / 2
        
        super.init(frame: CGRect(x: x, y: y, width: targetSize, height: targetSize))
        self.isUserInteractionEnabled = isUserInteractionEnabled
        
        
        let drag = UIPanGestureRecognizer(target: self, action: #selector(self.dragTarget(_:)))
        self.addGestureRecognizer(drag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapTarget(_:)))
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 10, width: self.frame.width, height: self.frame.height - 20))
        nameLabel.textAlignment = .center
        nameLabel.font = nameLabel.font.withSize(14)
        
        switch type {
        case .normal:
            self.image = UIImage(named: "target")
            //self.backgroundColor = UIColor.white
            //self.layer.cornerRadius = self.frame.width / 2
            self.addGestureRecognizer(tap)
            
        case .start:
            self.image = UIImage(named: "start")
        case .end:
            self.image = UIImage(named: "finish")
        }
        
        self.addSubview(self.nameLabel)
        
    }
    
    func dragTarget(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: mainView)
        self.center.x = point.x
        self.center.y = point.y
    }
    
    func tapTarget(_ recognizer: UITapGestureRecognizer) {
        self.delegate?.tapTarget(tapTarget: self)
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
