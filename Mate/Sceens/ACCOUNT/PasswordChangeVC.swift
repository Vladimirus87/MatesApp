//
//  PasswordChangeVC.swift
//  Mate
//
//  Created by Vladimirus on 25.12.2021.
//

import UIKit

class PasswordChangeVC: FatherViewController {

    @IBOutlet weak var oldPassField: UITextField!
    @IBOutlet weak var newPassField: UITextField!
    @IBOutlet weak var repeatPassField: UITextField!
    @IBOutlet weak var actionButton: DesignableButton!
    
    private var reqieredFields: [UITextField] {
        [ oldPassField,
          newPassField,
          repeatPassField ]
    }
    
    
    override func viewDidLoad() {
        isActiveMainView = true
        isKeyboardObserving = true
        super.viewDidLoad()
        uiSettings()
    }
    
    func uiSettings() {
        title = "Изменить пароль"
        reqieredFields.forEach { field in
            addSecureButton(field: field)
            field.setBorder()
            field.delegate = self
            field.setLeftPaddingPoints(15)
        }
    }
    
    private func addSecureButton(field: UITextField) {
        let padding: CGFloat = 3
        let width: CGFloat = 30
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: (padding * 2 + width), height: width))
        let showHideBtn = UIButton()
        showHideBtn.tag = field.tag
        showHideBtn.frame = CGRect(x: 0, y: 0, width: width, height: width)
        showHideBtn.setImage(UIImage(named: "invisibility.png"), for: .normal)
        showHideBtn.addTarget(self, action: #selector(self.showPassword), for: .touchUpInside)
        outerView.addSubview(showHideBtn)
        field.rightViewMode = .always
        field.rightView = outerView
        field.rightView?.isHidden = true
    }

    @IBAction func showPassword(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setImage(UIImage(named: sender.isSelected ? "visibility" : "invisibility" ), for: .normal)
        switch sender.tag {
        case 1:
            oldPassField.isSecureTextEntry = !sender.isSelected
        case 2:
            newPassField.isSecureTextEntry = !sender.isSelected
        case 3:
            repeatPassField.isSecureTextEntry = !sender.isSelected
        default:
            break
        }
    }
    
    private func allFieldsFull() -> Bool  {
        var allFieldsCorrect = true
        reqieredFields.forEach { tf in
            if tf.checkEmpty() {
                allFieldsCorrect = false
                print(tf)
            }
        }
        return allFieldsCorrect
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        hideKeyboard()
        print(allFieldsFull())
        guard allFieldsFull() else { return }
        
        
        
        guard newPassField.text == repeatPassField.text else {
            newPassField.showMessage("Пароли не совпадают", style: .error)
            repeatPassField.showMessage("Пароли не совпадают", style: .error)
            return
        }
        
        let networkManager = NetworkManager<UserProvider>()
        let params = PasswordParams(password: newPassField.text!, passwordConfirmation: repeatPassField.text!)
        networkManager.empty(service: .updateUserPass(params: params)) { [weak self] isSuccess in
            DispatchQueue.main.async {
                if isSuccess {
                    MessageView.sharedInstance.showOnView(message: "Пароль успешно изменен", theme: .success)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    MessageView.sharedInstance.showOnViewWithError("Упс, ошибка сервера(")
                }
            }
            
        }
        
    }
    
}


extension PasswordChangeVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 3:
            textField.resignFirstResponder()
        default:
            reqieredFields[textField.tag].becomeFirstResponder()
        }
        
        return true
    }
}
