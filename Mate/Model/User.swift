//
//  User.swift
//  Mate
//
//  Created by Vladimirus on 24.01.2022.
//

import Foundation

// MARK: - User
struct User: Codable {
    var dateOfBirth: String?
    var hobbies: [String]?
    var lastName, middleName, name, photo: String?
    var position: String?
    var userID: Int?
    
    var photoURL: URL? {
        if let photo = photo, let url = URL(string: photo) {
            return url
        }
        return nil
    }
    
    var fullName: String {
        return (name ?? "") + " " + (lastName ?? "")
    }
}


extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.dateOfBirth == rhs.dateOfBirth &&
        lhs.hobbies == rhs.hobbies &&
        lhs.lastName == rhs.lastName &&
        lhs.middleName == rhs.middleName &&
        lhs.name == rhs.name &&
        lhs.position == rhs.position &&
        lhs.userID == rhs.userID
    }
}
