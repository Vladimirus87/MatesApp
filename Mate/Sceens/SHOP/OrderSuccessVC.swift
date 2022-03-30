//
//  OrderSuccessVC.swift
//  Mate
//
//  Created by Владимир Моисеев on 12.02.2022.
//

import UIKit

class OrderSuccessVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var orderNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func updateData() {
        if let numb = orderNumber, !numb.isEmpty {
            titleLabel.text = "Заказ № \(numb) успешно оформлен"
        } else {
            titleLabel.text = "Заказ успешно оформлен"
        }
    }
    
    
    @IBAction func goToOrdersPressed(_ sender: Any) {
        let controllers = self.navigationController?.viewControllers
        for vc in controllers! {
            if vc is ShopVC {
                (vc as! ShopVC).goToMyOrders = true
                self.navigationController?.popToViewController(vc as! ShopVC, animated: true)
            }
        }
    }
    
    @IBAction func backToShopPressed(_ sender: Any) {
        let controllers = self.navigationController?.viewControllers
        for vc in controllers! {
            if vc is ShopVC {
                self.navigationController?.popToViewController(vc as! ShopVC, animated: true)
            }
        }
    }
    
}
