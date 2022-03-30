//
//  Transfer.swift
//  Mate
//
//  Created by Vladimirus on 27.01.2022.
//

import Foundation

// MARK: - Transfer
struct Transfer: Codable {
    let amount: Double?
    let creationTime, transferDescription, receiverFullName: String?
    let receiverID: Int?
    let smile: String?
    let transferID: Int?

    enum CodingKeys: String, CodingKey {
        case amount, creationTime
        case transferDescription = "description"
        case receiverFullName, receiverID, smile, transferID
    }
    
    var receiver: ReceiverShort? {
        guard let id = receiverID else { return nil }
        return ReceiverShort(receiverID: id, receiverName: receiverFullName)
    }
}


struct ReceiverShort {
    let receiverID: Int
    let receiverName: String?
}
