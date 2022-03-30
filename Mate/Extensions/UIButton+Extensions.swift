//
//  UIButton+Extensions.swift
//  Mate
//
//  Created by Vladimirus on 17.12.2021.
//

import UIKit

extension UIButton {
    func enableButton() {
        self.alpha = 1
        self.isUserInteractionEnabled = true
    }
    
    func disableButton() {
        self.alpha = 0.5
        self.isUserInteractionEnabled = false
    }

}
