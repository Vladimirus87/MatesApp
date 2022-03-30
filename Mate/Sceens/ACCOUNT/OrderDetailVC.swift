//
//  OrderDetailVC.swift
//  Mate
//
//  Created by Vladimirus on 26.12.2021.
//

import UIKit

class OrderDetailVC: FatherViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var orderDescription: UITextView!
    
    var order: Order?
    
    lazy private var networkManager = NetworkManager<UserProvider>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let queue = DispatchQueue(label: "orderDetailFetchQueue", attributes: .concurrent)
        queue.async {
            self.fetchData()
        }
    }
    
    private func fetchData() {
        guard let id = self.order?.orderID else {
            DispatchQueue.main.async {
                MessageView.sharedInstance.showOnView(message: "Unknown order id", theme: .warning)
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.startAnimating()
        }
        
        networkManager.request(service: .getOrder(orderID: id), decodable: Order.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let order):
                    self.updateData(order)
                case .failure(let error):
                    print("error", error)
                    MessageView.sharedInstance.showError(error)
                }
            }
        }
        
    }
    
    
    
    private func updateData(_ order: Order?) {
        photo.kf.setImage(with: order?.photoURL, placeholder: UIImage(named: "no_image"))
        name.text = order?.productName
        orderDescription.text = order?.productDescription
        status.text = order?.status?.prettyName
        status.textColor = order?.status?.color
        status.superview?.backgroundColor = order?.status?.backgroundColor
    }
    
    override func localizations() {
        title = "Заказ"
    }



}
