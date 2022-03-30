//
//  Deposit.swift
//  Mate
//
//  Created by Vladimirus on 27.01.2022.
//

import Foundation

// MARK: - Deposit
struct Deposit: Codable {
    let allUsers: Bool?
    let amount: Double?
    let companyID, depositID: Int?
    let depositDescription, status: String?
    let userIDS: [Int]?

    enum CodingKeys: String, CodingKey {
        case allUsers, amount, companyID, depositID
        case depositDescription = "description"
        case status
        case userIDS = "userIds"
    }
}
