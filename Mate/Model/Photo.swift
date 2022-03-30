//
//  Photo.swift
//  Mate
//
//  Created by Vladimirus on 24.01.2022.
//

import Foundation

// MARK: - Photo
struct Photo: Codable {
//    let photoID: Int?
    let url: String?
    
    
    var photoURL: URL? {
        if let photo = url, let url = URL(string: photo) {
            return url
        }
        return nil
    }
}
