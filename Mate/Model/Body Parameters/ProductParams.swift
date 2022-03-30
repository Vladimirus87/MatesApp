//
//  ProductParams.swift
//  Mate
//
//  Created by Владимир Моисеев on 11.02.2022.
//

import Foundation

// MARK: - ProductParams
struct ProductParams: Encodable {
    let companyID: Int
    let direction: String
    let itemsPerPage: Int
    let name, orderField: String
    let page: Int
    var productCategoryIDs: [Int]?
    
}
