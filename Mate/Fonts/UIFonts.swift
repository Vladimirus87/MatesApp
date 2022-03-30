//
//  UIFonts.swift
//  Mate
//
//  Created by Vladimirus on 17.12.2021.
//

import UIKit

extension UIFont {
    
    class func bold(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Bold", size: fontSize)!
    }
    
    class func semibold(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Semibold", size: fontSize)!
    }
    
    static func medium(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: fontSize)!
    }
    
    class func regular(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Regular", size: fontSize)!
    }
    
    class func light(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Light", size: fontSize)!
    }
    
    class func thin(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "SFProDisplay-Thin", size: fontSize)!
    }
    
    
}
