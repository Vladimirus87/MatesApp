//
//  OrderInProgressVC.swift
//  Mate
//
//  Created by Владимир Моисеев on 12.02.2022.
//

import UIKit

struct ProductPreparing {
    let productID: Int
    let name: String
    let count: Int
    let totalSum: Double
    let photoURL: URL?
    
    var countString: String {
        return "\(count) шт."
    }
}

class OrderInProgressVC: FatherViewController {

    @IBOutlet weak var textView: CustomUITextView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var productPhoto: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var orderButton: DesignableButton!
    
    var product: ProductPreparing!
    
    private let placeholder = "Добавить комментарий"
    
    private lazy var networkManager = NetworkManager<UserProvider>()
    
    var messageText: String {
        return textView.text == placeholder ? "" : textView.text
    }
    
    override func viewDidLoad() {
        isActiveMainView = true
        isKeyboardObserving = true
        super.viewDidLoad()
        uiSettings()

    }
    
    private func uiSettings() {
        textView.leftSpace()
        textView.addCancelButton()
        textView.addBorder()
        textView.text = placeholder
        textView.textColor = .lightGray
        
        title = "Подтверждение заказа"
        descriptionLabel.text = "Укажите комментарий к заказу"
        updateProductData()
    }
    
    private func updateProductData() {
        productPhoto.kf.setImage(with: product.photoURL)
        productName.text = product.name
        count.text = product.countString
        sum.text = product.totalSum.toString()
    }
    
    
    override func keyboardWillShow(rect: CGRect) {
        let buttonMaxY = orderButton.frame.maxY
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
    

    @IBAction func createOrderPressed(_ sender: Any) {
        let companyID = AccessService.shared.companyShort?.companyID
        let userID = AccessService.shared.user?.userID
        let params = CreateOrderParams(companyID: companyID!, notes: messageText, productID: product.productID, quantity: product.count, userID: userID!)
        startAnimating()
        networkManager.request(service: .createOrder(params: params), decodable: Order.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let order):
                    NotificationCenter.default.post(name: NotifyIdentifiers.updateCardSum, object: nil)
                    let vc = OrderSuccessVC.fromStoryboard(.shop)
                    //MARK: maybee need check order status
                    vc.orderNumber = order.orderNumber
                    self.navigationController?.show(vc, sender: nil)
                case .failure(let error):
                    print("error", error)
                        MessageView.sharedInstance.showError(error)
                }
            }

        }
    }

}


extension OrderInProgressVC: UITextViewDelegate {
    
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

    }
}
