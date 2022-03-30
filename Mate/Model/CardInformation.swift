//
//  CardInformation.swift
//  Mate
//
//  Created by Vladimirus on 25.01.2022.
//

import Foundation

// MARK: - CardInformation
struct CardInformation: Codable {
    let employeeCount: Int?
    let balance: Double?
    let position, userName: String?
}
