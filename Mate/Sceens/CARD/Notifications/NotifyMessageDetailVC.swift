//
//  NotifyMessageDetailVC.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit
import Kingfisher

class NotifyMessageDetailVC: NotificationsScreenVC {
    @IBOutlet weak var fromName: UILabel!
    @IBOutlet weak var fromPhoto: UIImageView!
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var message: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.fetchMessageData()
        }
    }
    
    override func localizations() {
        title = "Сообщение"
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}



extension NotifyMessageDetailVC {

    
    private func fetchMessageData() {
        guard let _id = entityID else {
            MessageView.sharedInstance.showOnView(message: "Unknown message id", theme: .warning)
            return
        }
        startAnimating()
        networkManager.request(service: .getMessage(messageID: _id), decodable: Message.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let message):
                    self.updateMessageUI(message)
                case .failure(let error):
                    print("error", error)
                    MessageView.sharedInstance.showError(error)
                }
            }
        }
    }
    
    private func updateMessageUI(_ messageData: Message?) {
        fromName.text = messageData?.userName
        message.text = messageData?.message
        fromPhoto.kf.setImage(with: messageData?.photoURL)
        
        if let dateString = messageData?.dateString,
            let timeString = messageData?.timeString {
            messageTime.text = dateString + " в " + timeString
        } else {
            messageTime.text = messageData?.createdDate
        }
        
    }
}
