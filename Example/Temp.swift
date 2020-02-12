//
//  Temp.swift
//  MantisExample
//
//  Created by Tèo Lực on 2/11/20.
//  Copyright © 2020 Echo. All rights reserved.
//


import UIKit
import ObjectiveC.runtime

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}
extension Reusable {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}
extension UIViewController: Reusable {}
extension UIViewController {
    static func load<T>(ofType viewcontrollerType: T.Type = T.self) -> T where T: UIViewController {
        let vc = viewcontrollerType.init(nibName: viewcontrollerType.reuseIdentifier,
                                         bundle : nil)
        return vc
    }
}


extension NSLayoutConstraint {
    
    // MARK: - Properties
    
    private struct Defined {
        static let enableScalingKey = "enableScalingKey"
        static let didScaleKey = "didScaleKey"
    }
    @IBInspectable var enableScaling: Bool {
        get {
            return objc_getAssociatedObject(self, Defined.enableScalingKey) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, Defined.enableScalingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            //
            if newValue == true && self.didScale == false {
                if self.constant != 0 {
                    let newConstraint = NSLayoutConstraint.scale(from: self.constant)
                    self.constant = newConstraint
                }
                self.didScale = true
            }
            //
        }
    }
    private var didScale: Bool {
        get {
            return objc_getAssociatedObject(self, Defined.didScaleKey) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, Defined.didScaleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: -
    static func scale(from originValue: CGFloat) -> CGFloat {
        let scaleWidth: CGFloat = 1
        return originValue * scaleWidth
    }
}


extension UIView {

    /**
     Rotate a view by specified degrees

     - parameter angle: angle in degrees
     */
    func rotate(in angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }

}
