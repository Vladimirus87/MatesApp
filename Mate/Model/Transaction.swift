//
//  Transaction.swift
//  Mate
//
//  Created by Vladimirus on 27.01.2022.
//

import Foundation
import UIKit


// MARK: - Transaction
struct Transaction: Codable {
    let transactionID: Int?
    let transactionAmount: Double?
    let transactionDescription: String?
    let transactionType: OrderType?
    let creationDate: String?

    enum CodingKeys: String, CodingKey {
        case transactionID, transactionAmount
        case transactionDescription = "description"
        case transactionType, creationDate
    }
    
    var date: Date? {
        creationDate?.getDate(format: "dd-MM-yyyy")
    }
    
    var dateString: String? {
        date?.getString(format: "dd.MM.yyyy")
    }
    
    var datePrettyString: String? {
        guard let _date = date else { return nil }
        
        if Calendar.current.isDateInToday(_date) {
            return "Сегодня"
        } else if Calendar.current.isDateInYesterday(_date) {
            return "Вчера"
        } else {
            return dateString
        }
    }
    

    
    var titleText: String {
        switch transactionType {
        case.transfer:
            return isTransactionToMe ? "Поступление" : "Перевод"
        case .deposit:
            return "Поступление"
        case .order:
            return "Покупка в магазине"
        default:
            return "Unknown transaction"
        }
    }
    
    var isTransactionToMe: Bool {
        return (transactionAmount ?? 0) > 0
    }
        
    var logo: UIImage? {
        switch transactionType {
        case .transfer:
            return UIImage(named: "Icon_history_2")
        case .deposit:
            return UIImage(named: "Icon_history_1")
        default:
            return UIImage(named: "Icon_history_1")
        }
    }
}

typealias Transactions = [Transaction]
