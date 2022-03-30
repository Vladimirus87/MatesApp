//
//  NotifyDepositVC.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit

class NotifyDepositVC: NotificationsScreenVC {

    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var currencyLogo: UIImageView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var purposeOfPayment: UILabel!
    @IBOutlet weak var corpShopButton: DesignableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCleanUI()
        
        DispatchQueue.main.async {
            self.fetchDepositData()
        }
    }
    
    override func localizations() {
        title = "Пополнение"
    }
    
    private func startCleanUI() {
        balance.text = ""
        senderName.text = ""
        purposeOfPayment.text = ""
        navigationItem.backButtonTitle = ""
        corpShopButton.disableButton()
    }
    
    private func fetchDepositData() {
        guard let _id = entityID else {
            MessageView.sharedInstance.showOnView(message: "Unknown deposit id", theme: .warning)
            return
        }
        startAnimating()
        networkManager.request(service: .getDeposit(depositID: _id), decodable: Deposit.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let message):
                    self.updateDepositUI(message)
                case .failure(let error):
                    print("error", error)
                    MessageView.sharedInstance.showError(error)
                }
            }
        }
    }
    
    
    private func updateDepositUI(_ deposit: Deposit) {
        balance.text = deposit.amount?.toInt().toString()
        
        var companyName: String? {
            let isOurCompany = AccessService.shared.companyShort?.companyID == deposit.companyID
            return isOurCompany ? AccessService.shared.companyShort?.name : deposit.companyID?.toString()
        }
        
        senderName.text = "Получено от " + (companyName ?? "Unknown")
        purposeOfPayment.text = deposit.depositDescription
        
        corpShopButton.enableButton()
    }
    
    
    
    @IBAction func toCorpShopPressed(_ sender: Any) {
        let vc = ShopVC.fromStoryboard(.shop)
        navigationController?.show(vc, sender: nil)
    }
    
}
