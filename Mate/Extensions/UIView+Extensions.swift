//
//  UIView+Extensions.swift
//  Yoozby
//
//  Created by Vladimirus on 07.09.2020.
//  Copyright © 2020 Moses. All rights reserved.
//

import UIKit

extension UIView {
    
    class func fromNib<T: UIView>(ownerVC: UIViewController? = nil) -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: ownerVC, options: nil)![0] as! T
    }
    
    func roundCorners(corners: UIRectCorner = .allCorners, radius: CGFloat, curve: CALayerCornerCurve = .continuous) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.cornerCurve = curve
        layer.mask = mask
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat, rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.cornerCurve = .continuous
        layer.mask = mask
    }
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    func simpleShadow(color: UIColor = .gray) {
        addShadow(offset: .zero, color: color, radius: 3, opacity: 0.4)
    }
    
    
    func addBorder(color: UIColor = UIColor(named: "greyBlue")!, width: CGFloat = 1, radius: CGFloat = 5) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        self.layer.cornerRadius = radius
    }
    
    func rotate(_ toValue: CGFloat = CGFloat.pi, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(animation, forKey: nil)
    }
}




