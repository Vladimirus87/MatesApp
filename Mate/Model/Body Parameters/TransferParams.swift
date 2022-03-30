//
//  TransferParams.swift
//  Mate
//
//  Created by Vladimirus on 27.01.2022.
//

import Foundation

// MARK: - TransferParams
struct TransferParams: Codable {
    let amount: Double?
    let transferParamsDescription: String?
    let receiverID: Int?
    let smile: String?

    enum CodingKeys: String, CodingKey {
        case amount
        case transferParamsDescription = "description"
        case receiverID, smile
    }
}
