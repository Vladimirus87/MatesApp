//
//  Order.swift
//  Mate
//
//  Created by Vladimirus on 26.01.2022.
//

import UIKit

// MARK: - Order
struct Order: Codable {
    let createdDate, notes: String?
    let orderID: Int?
    let orderNumber, orderStatus: String?
    let productID: Int?
    let productName, productDescription, productPhoto: String?
    let totalPrice, userID: Int?
    let userName: String?
    
    var photoURL: URL? {
        if let photo = productPhoto, let url = URL(string: photo) {
            return url
        }
        return nil
    }
    
    var status: OrderStatus? {
        return OrderStatus(rawValue: orderStatus ?? "")
    }
    
    enum OrderStatus: String {
        case new = "NEW"
        case inProgress = "IN_PROGRESS"
        case done = "DONE"
        case declined = "DECLINED"
        
        var prettyName: String {
            switch self {
            case .new:
                return "Новый"
            case .inProgress:
                return "В обработке"
            case .done:
                return "Получено"
            case .declined:
                return "Отклоненный"
            }
        }
        
        var color: UIColor? {
            switch self {
            case .new:
                return UIColor(named: "deepBlue")
            case .inProgress:
                return UIColor(named: "orange")
            case .done:
                return UIColor(named: "green")
            case .declined:
                return UIColor(named: "red")
            }
        }
        
        var backgroundColor: UIColor? {
            switch self {
            case .new:
                return UIColor(hexString: "#E3E2F8")
            case .inProgress:
                return UIColor(hexString: "#FFF0DB")
            case .done:
                return UIColor(hexString: "#E2F8ED")
            case .declined:
                return UIColor(hexString: "#FFDBDB")
            }
        }
    }
}
