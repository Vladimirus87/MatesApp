//
//  OrdersParams.swift
//  Mate
//
//  Created by Владимир Моисеев on 12.02.2022.
//

import Foundation

// MARK: - OrdersParams
struct OrdersParams: Codable {
    let companyID, itemsPerPage: Int
    let orderField, orderStatus: String
    let page, userID: Int
}
