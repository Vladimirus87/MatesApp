//
//  PaginationParams.swift
//  Mate
//
//  Created by Vladimirus on 25.01.2022.
//

import Foundation

// MARK: - PaginationParams
struct PaginationParams: Codable {
    let itemsPerPage: Int?
    let orderField: String? //parameter for sorting data
    let page: Int?
    var query: String? = nil
}
