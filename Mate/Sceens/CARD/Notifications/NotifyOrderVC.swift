//
//  NotifyOrderVC.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit
import Kingfisher

class NotifyOrderVC: NotificationsScreenVC {

    @IBOutlet weak var orderPicture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desctiptionLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.fetchOrderData()
        }
    }
    

    override func localizations() {
        title = "Заказ"
    }

}



extension NotifyOrderVC {
    private func fetchOrderData() {
        guard let _id = entityID else {
            MessageView.sharedInstance.showOnView(message: "Unknown order id", theme: .warning)
            return
        }
        startAnimating()
        networkManager.request(service: .getOrder(orderID: _id), decodable: Order.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let order):
                    self.updateOrderUI(order)
                case .failure(let error):
                    print("error", error)
                    MessageView.sharedInstance.showError(error)
                }
            }
        }
    }
    
    private func updateOrderUI(_ orderData: Order?) {
        titleLabel.text = orderData?.productName
        desctiptionLabel.text = orderData?.productDescription
        orderPicture.kf.setImage(with: orderData?.photoURL, placeholder: UIImage(named: "no_image"))
    }
}
