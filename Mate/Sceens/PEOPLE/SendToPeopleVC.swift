//
//  SendToPeopleVC.swift
//  Mate
//
//  Created by Vladimirus on 22.12.2021.
//

import UIKit
import ISEmojiView

class SendToPeopleVC: FatherViewController {

    @IBOutlet weak var inputSumField: UITextField!
    @IBOutlet weak var textView: CustomUITextView!
    @IBOutlet weak var sendButton: DesignableButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var receiver: ReceiverShort?
    private var emojiView: EmojiView?

    private let placeholder = "Написать сообщение"

    private lazy var networkManager = NetworkManager<UserProvider>()
    
    var descriptionText: String {
        return textView.text == placeholder ? "" : textView.text
    }
    
    override func viewDidLoad() {
        isActiveMainView = true
        isKeyboardObserving = true
        super.viewDidLoad()
        uiSettings()
        title = receiver?.receiverName
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationController?.navigationBar.isHidden == true {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
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
        textView.inputView = nil
        let defaultValue: CGFloat = 37
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
        inputSumField.text = "0"
        checkButton()
        setEmojiUI()
    }
    
    private func setEmojiUI() {
        let keyboardSettings = KeyboardSettings(bottomType: .categories)
        keyboardSettings.countOfRecentsEmojis = 20
        keyboardSettings.updateRecentEmojiImmediately = true
        keyboardSettings.needToShowAbcButton = true
        emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView?.translatesAutoresizingMaskIntoConstraints = false
        emojiView?.delegate = self
    }
    
    private func checkButton() {
        if let text = inputSumField.text?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil),
           let sum = Int(text),
           sum > 0 {
            sendButton.enableButton()
        } else {
            sendButton.disableButton()
        }
    }
    
    @IBAction func emodzyPressed(_ sender: Any) {
        textView.inputView = emojiView
        textView.reloadInputViews()
        textView.becomeFirstResponder()
    }
    
    @IBAction func InputSumEditingChange(_ sender: UITextField) {
        guard let text = sender.text else { return }
        
        if text.first == "0", text.count > 1 {
            sender.text = String(text.dropFirst())
        }
        sender.text = Int(text)?.formattedWithSeparator
        checkButton()
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        guard let id = receiver?.receiverID else {
            MessageView.sharedInstance.showOnView(message: "Unknown receier id", theme: .warning)
            return
        }
        
        guard let sum = inputSumField.text?.toDouble(), sum > 0 else {
            MessageView.sharedInstance.showOnView(message: "Сумма должна быть больше 0", theme: .warning)
            return
        }
        
        let params = TransferParams(amount: sum.rounded(toPlaces: 2),
                                    transferParamsDescription: descriptionText,
                                    receiverID: id,
                                    smile: "")
        startAnimating()
        networkManager.request(service: .sendTransfer(params: params), decodable: Transfer.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let transferMD):
                    NotificationCenter.default.post(name: NotifyIdentifiers.updateCardSum, object: nil)
                    MessageView.sharedInstance.showOnView(message: "Сумма: \(transferMD.amount?.toInt().toString() ?? "") успешно отправлена для \(transferMD.receiverFullName ?? "")", theme: .success)
                    self.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    print("error", error)
                        MessageView.sharedInstance.showError(error)
                }
            }
            
        }
    }
    
    
}


extension SendToPeopleVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                  return false
              }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        if count > 5 {
            return false
        }
        print(string)
        if string != "" && Int(string) == nil {
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text == "" {
            textField.text = "0"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension SendToPeopleVC: UITextViewDelegate {
    
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
        if textView.text.count > 0 {
//            saveData.enabled()
        }
    }
}

// MARK: - EmojiViewDelegate
extension SendToPeopleVC: EmojiViewDelegate {
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        textView.insertText(emoji)
    }
    
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        textView.inputView = nil
        textView.keyboardType = .default
        textView.reloadInputViews()
    }
    
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        textView.deleteBackward()
    }
    
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        textView.resignFirstResponder()
    }
}
                                
                                
                                

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()
}
extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}
