//
//  AuthorisationVC.swift
//  Mate
//
//  Created by Vladimirus on 17.12.2021.
//

import UIKit
import Firebase

class AuthorisationVC: FatherViewController {
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var enterButton: DesignableButton!
    @IBOutlet weak var forgetButton: UIButton!
    @IBOutlet weak var topConstant: NSLayoutConstraint!

    
    override func viewDidLoad() {
        isActiveMainView = true
        isKeyboardObserving = true
        super.viewDidLoad()
        uiSettings()
    }

    func uiSettings() {
        addSecureButton()
        emailField.setBorder()
        passField.setBorder()
        emailField.setLeftPaddingPoints(15)
        passField.setLeftPaddingPoints(15)
    }
    
    
    
    private func addSecureButton() {
        let padding: CGFloat = 3
        let width: CGFloat = 30
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: (padding * 2 + width), height: width))
        let showHideBtn = UIButton()
        showHideBtn.frame = CGRect(x: 0, y: 0, width: width, height: width)
        showHideBtn.setImage(UIImage(named: "invisibility.png"), for: .normal)
        showHideBtn.addTarget(self, action: #selector(self.showPassword), for: .touchUpInside)
        outerView.addSubview(showHideBtn)
        passField.rightViewMode = .always
        passField.rightView = outerView
        passField.rightView?.isHidden = true
    }
    
    override func keyboardWillShow(rect: CGRect) {
        let buttonToBottom = (backView.frame.height - 25) - enterButton.frame.maxY
        let underKeyboardSpacing: CGFloat = 15
        let dif = rect.height - buttonToBottom + underKeyboardSpacing
        guard dif > 0 else { return }
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -dif
            self.view.layoutIfNeeded()
        }
    }
    
    override func keyboardWillHide() {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func allFieldsFull() -> Bool  {
        var allFieldsCorrect = true
        if emailField.text?.isEmail == false {
            emailField.showMessage("Необходимо ввести e-mail", style: .error)
            allFieldsCorrect = false
        }
        
        if passField.checkEmpty() {
            allFieldsCorrect = false
        }
        
        return allFieldsCorrect
    }
    
    private func authorize() {
        startAnimating()
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passField.text!) { result, error in
            DispatchQueue.main.async {
                self.stopAnimating()
                if let _error = error {
                    print(_error.localizedDescription)
                    MessageView.sharedInstance.showError(_error)
                    return
                }

                EnterService.chooseStartController(animated: true)
            }
        }
    }
    
    
    
    @IBAction func showPassword(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setImage(UIImage(named: sender.isSelected ? "visibility" : "invisibility" ), for: .normal)
        self.passField.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func passEditingChange(_ sender: UITextField) {
        passField.rightView?.isHidden = sender.text?.isEmpty ?? true
    }
    

    @IBAction func enterPressed(_ sender: Any) {
        hideKeyboard()
        guard allFieldsFull() else { return }
        
        
        let queue = DispatchQueue.main
        queue.async {
            self.authorize()
        }

    }
    
    @IBAction func forgetPressed(_ sender: Any) {
        let vc = ForgetVC.fromStoryboard(.auth)
        navigationController?.show(vc, sender: nil)
    }
}


extension AuthorisationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passField.becomeFirstResponder()
        }
        
        if textField == passField {
            passField.resignFirstResponder()
        }
        
        return true
    }
}



