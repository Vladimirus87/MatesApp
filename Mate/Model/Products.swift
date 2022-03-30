//
//  Products.swift
//  Mate
//
//  Created by Владимир Моисеев on 11.02.2022.
//

import Foundation

// MARK: - Product
struct Product: Codable {
    let productID: Int?
    let name: String?
    let photo: String?
    let enable: Bool?
    let price: Double?
    
    var photoURL: URL? {
        if let photo = photo, let url = URL(string: photo) {
            return url
        }
        return nil
    }
}

typealias Products = [Product]
