//
//  AskingVC.swift
//  Mate
//
//  Created by Vladimirus on 22.12.2021.
//

import UIKit

class AskingVC: FatherViewController {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var textView: CustomUITextView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var sendButton: DesignableButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    
    var employee: Employee?
    
    private lazy var networkManager = NetworkManager<UserProvider>()
    
    private let placeholder = "Напишите причину начисления бонусов данном сотруднику"
    
    var messageText: String {
        return textView.text == placeholder ? "" : textView.text
    }
    
    override func viewDidLoad() {
        isActiveMainView = true
        isKeyboardObserving = true
        super.viewDidLoad()
        uiSettings()
        
    }
    
    override func keyboardWillShow(rect: CGRect) {
        let buttonMaxY = sendButton.frame.maxY
        let keyboardMinY = UIScreen.main.bounds.height - rect.height
        let dif = buttonMaxY - keyboardMinY
        guard dif > 0 else { return }
        UIView.animate(withDuration: 0.3) {
            self.topConstraint.constant = -dif
            self.view.layoutIfNeeded()
        }
    }
    
    override func keyboardWillHide() {
        let defaultValue: CGFloat = 26
        guard topConstraint.constant < defaultValue else { return }
        UIView.animate(withDuration: 0.3) {
            self.topConstraint.constant = defaultValue
            self.view.layoutIfNeeded()
        }
    }
    
    func uiSettings() {
        textView.leftSpace()
        textView.addCancelButton()
        textView.addBorder()
        textView.text = placeholder
        textView.textColor = .lightGray
        checkButton()
        
        title = "Начислить бонусы"
        userName.text = employee?.fullName
        userPhoto.kf.setImage(with: employee?.photoURL, placeholder: UIImage(named: "User-Photo"))
    }

    private func checkButton() {
        if textView.textColor == .lightGray {
            sendButton.disableButton()
        } else {
            sendButton.enableButton()
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        guard let _id = employee?.userID else {
            MessageView.sharedInstance.showOnView(message: "Unknown user id", theme: .warning)
            return
        }
        
        let params = MessageParams(message: messageText, messageType: "MESSAGE", nominatedUserID: _id)
        startAnimating()
        networkManager.request(service: .sendMessage(params: params), decodable: Message.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(_):
                    MessageView.sharedInstance.showOnView(message: "Ваше сообщение отправлено", theme: .success)
                    self.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    print("error", error)
                        MessageView.sharedInstance.showError(error)
                }
            }
            
        }
    }


}

extension AskingVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkButton()

    }
}
