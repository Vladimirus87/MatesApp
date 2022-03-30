//
//  ProductDetail.swift
//  Mate
//
//  Created by Владимир Моисеев on 11.02.2022.
//

import Foundation

// MARK: - ProductDetail
struct ProductDetail: Codable {
    let productID, categoryID: Int?
    let name, productDetailDescription: String?
    let photo: String?
    let enable, unlimited: Bool?
    let stock: Int?
    let price: Double?

    enum CodingKeys: String, CodingKey {
        case productID, categoryID, name
        case productDetailDescription = "description"
        case photo, enable, unlimited, price, stock
    }
    
    var photoURL: URL? {
        if let photo = photo, let url = URL(string: photo) {
            return url
        }
        return nil
    }
    
    var totalCount: String {
        if let _stock = stock {
            let valueString = _stock > 100 ? "100+" : String(_stock)
            return valueString
        } else {
            return "0"
        }
    }
}
