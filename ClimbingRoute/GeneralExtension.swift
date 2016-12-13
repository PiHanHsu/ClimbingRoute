//
//  GeneralExtension.swift
//  ClimbingRoute
//
//  Created by PiHan Hsu on 16/11/2016.
//  Copyright © 2016 PiHan Hsu. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}

extension Array where Element: FloatingPoint {
    // Returns the sum of all elements in the array
    var total: Element {
        return reduce(0, +)
    }
    // Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
