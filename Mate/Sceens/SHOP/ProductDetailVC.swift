//
//  ProductDetailVC.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit

class ProductDetailVC: UIViewController {

    @IBOutlet weak var productPhoto: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var totalCount: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var balanceTitle: UILabel!
    @IBOutlet weak var userBalance: UILabel!
    @IBOutlet weak var currencyImage: UIImageView!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var descriptionBody: UITextView!
    @IBOutlet weak var orderButton: DesignableButton!
    
    var productID: Int?
    
    private lazy var networkManager = NetworkManager<UserProvider>()
    
    private var countValue: Int! {
        didSet {
            updateCountUI()
        }
    }
    
    
    private var totalOrderSum: Double {
        return (Double(countValue) * (product?.price ?? 0)).rounded(toPlaces: 2)
    }
    
    private var product: ProductDetail?
    
    private var cardInfo: CardInformation? {
        return AccessService.shared.cardInfo
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        
        let queue = DispatchQueue(label: "productDetailFetchQueue", attributes: .concurrent)
        queue.async {
            self.getProductDetailInfo()
        }
    }
    

    private func getProductDetailInfo() {
        guard let id = productID else {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        networkManager.request(service: .getProduct(productID: id), decodable: ProductDetail.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let productDetail):
                    self.updateData(productDetail)
                case .failure(let error):
                    MessageView.sharedInstance.showError(error)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func updateData(_ product: ProductDetail) {
        productPhoto.kf.setImage(with: product.photoURL, placeholder: UIImage(named: "no_image"))
        name.text = product.name
        totalCount.text = product.totalCount
        descriptionBody.text = product.productDetailDescription
        userBalance.text = cardInfo?.balance?.toString()
        descriptionTitle.text = "О товаре"
        self.product = product
        countValue = 1
        currencyImage.image = currencyImage.image?.withRenderingMode(.alwaysTemplate)
    }

    private func updateCountUI() {
        count.text = countValue.toString()
        
        orderButton.setTitle("Заказать за \(totalOrderSum)", for: .normal)
        
        let isEnoughMoney = totalOrderSum < (cardInfo?.balance ?? 0)
        updateBalanceColor(isEnoughMoney: isEnoughMoney)
    }
    
    private func updateBalanceColor(isEnoughMoney: Bool) {
        if isEnoughMoney {
            userBalance.textColor = .black
            balanceTitle.textColor = .black
            currencyImage.tintColor = .black
            orderButton.enableButton()
        } else {
            userBalance.textColor = .red
            balanceTitle.textColor = .red
            currencyImage.tintColor = .red
            orderButton.disableButton()
        }
    }
    
    @IBAction func minusPressed(_ sender: Any) {
        guard countValue > 1 else {
            return
        }
        countValue -= 1
    }
    
    @IBAction func plusPressed(_ sender: Any) {
        guard countValue < (product?.stock ?? 0) else {
            return
        }
        countValue += 1
    }
    
    @IBAction func orderPressed(_ sender: Any) {
        let productPreparing = ProductPreparing(productID: productID!,
                                                name: product?.name ?? "",
                                                count: countValue,
                                                totalSum: totalOrderSum,
                                                photoURL: product?.photoURL)
        
        let vc = OrderInProgressVC.fromStoryboard(.shop)
        vc.product = productPreparing
        navigationController?.show(vc, sender: nil)
    }
    
}
