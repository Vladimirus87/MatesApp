//
//  MessageParams.swift
//  Mate
//
//  Created by Vladimirus on 27.01.2022.
//

import Foundation

// MARK: - MessageParams
struct MessageParams: Codable {
    let message, messageType: String?
    let nominatedUserID: Int?
}
