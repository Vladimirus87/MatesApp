//
//  FatherViewController.swift
//  Yoozby
//
//  Created by Vladimirus on 07.09.2020.
//  Copyright © 2020 Moses. All rights reserved.
//

import UIKit

class FatherViewController: UIViewController {
    
    var isActiveMainView = false
    var isKeyboardObserving = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAllXibs()
        setUI()
        localizations()
        
        if isActiveMainView {
            let gs = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//            gs.cancelsTouchesInView = false
            self.view.addGestureRecognizer(gs)
        }
        
        if isKeyboardObserving {
            addKeyboardNotifications()
        }
        
        statusBarBackColor()
    }
    
    
    deinit {
        removeNotifications()
        NotificationCenter.default.removeObserver(self)
    }
        
    func initAllXibs() {}
    func setUI() {}
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbwWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbwWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func setText() {
        localizations()
    }

    @objc func kbwWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let kbFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardWillShow(rect: kbFrame)
    }
    
    @objc func kbwWillHide(_ notification: Notification) {
        keyboardWillHide()
    }
    
    func keyboardWillShow(rect: CGRect) {}
    func keyboardWillHide() {}
    func localizations() {}
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}
