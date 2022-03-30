//
//  CustomTextView.swift
//  Mate
//
//  Created by Vladimirus on 22.12.2021.
//

import UIKit

class CustomUITextView: UITextView {
    func leftSpace() {
        self.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func addCancelButton() {
        let accessoryDoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.close, target: self, action: #selector(self.donePressed))
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let accessoryToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        accessoryToolBar.setItems([flexButton, accessoryDoneButton], animated: true)
        accessoryToolBar.sizeToFit()
        inputAccessoryView = accessoryToolBar
    }
    
    @objc func donePressed() {
        resignFirstResponder()
    }
}
