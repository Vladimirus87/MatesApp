//
//  NotifyTransferVC.swift
//  Mate
//
//  Created by Vladimirus on 27.01.2022.
//

import UIKit

class NotifyTransferVC: NotificationsScreenVC {

    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var currencyLogo: UIImageView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var senderMessage: UILabel!
    @IBOutlet weak var sendBackButton: DesignableButton!
    @IBOutlet weak var corpShopButton: DesignableButton!
    
    var transfer: Transfer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCleanUI()
        
        DispatchQueue.main.async {
            self.fetchTransferData()
        }
    }
    
    override func localizations() {
        title = "Пополнение"
    }
    
    private func startCleanUI() {
        balance.text = ""
        senderName.text = ""
        senderMessage.text = ""
        navigationItem.backButtonTitle = ""
        sendBackButton.disableButton()
        corpShopButton.disableButton()
    }
    
    private func fetchTransferData() {
        guard let _id = entityID else {
            MessageView.sharedInstance.showOnView(message: "Unknown deposit id", theme: .warning)
            return
        }
        startAnimating()
        networkManager.request(service: .getTransfer(transferID: _id), decodable: Transfer.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let transfer):
                    self.updateTransferUI(transfer)
                    self.transfer = transfer
                case .failure(let error):
                    print("error", error)
                    MessageView.sharedInstance.showError(error)
                }
            }
        }
    }
    
    
    private func updateTransferUI(_ transfer: Transfer) {
        balance.text = transfer.amount?.toInt().toString()
        senderName.text = "Получено от " + (transfer.receiverFullName ?? "Unknown")
        senderMessage.text = transfer.transferDescription
        senderName.superview?.updateConstraintsIfNeeded()
        sendBackButton.enableButton()
        corpShopButton.enableButton()
    }
    
    
    @IBAction func sendBackPressed(_ sender: Any) {
        let vc = SendToPeopleVC.fromStoryboard(.people)
        vc.receiver = transfer?.receiver
        navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func toCorpShopPressed(_ sender: Any) {
        let vc = ShopVC.fromStoryboard(.shop)
        navigationController?.show(vc, sender: nil)
    }
}



    
