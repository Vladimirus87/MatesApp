//
//  CompanyShort.swift
//  Mate
//
//  Created by Vladimirus on 25.01.2022.
//

import Foundation

// MARK: - CardInformation
struct CompanyShort: Codable {
    let companyID: Int?
    let name, photo: String?
    let productCount: Int?
}
