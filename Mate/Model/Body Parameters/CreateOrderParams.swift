//
//  CreateOrderParams.swift
//  Mate
//
//  Created by Владимир Моисеев on 12.02.2022.
//

import Foundation

// MARK: - CreateOrderParams
struct CreateOrderParams: Codable {
    let companyID: Int
    let notes: String
    let productID, quantity, userID: Int?
}
