//
//  Categories.swift
//  Mate
//
//  Created by Владимир Моисеев on 11.02.2022.
//

import Foundation

// MARK: - Category
struct Category: Codable {
    let categoryID, companyID: Int?
    let name: String?
    let enable: Bool?
    let products: Int?
}



typealias Categories = [Category]


extension Category: Equatable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.categoryID == rhs.categoryID
    }
}
