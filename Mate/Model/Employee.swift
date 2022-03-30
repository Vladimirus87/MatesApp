//
//  Employee.swift
//  Mate
//
//  Created by Vladimirus on 27.01.2022.
//

import Foundation

// MARK: - Employee
struct Employee: Codable {
    let userID: Int?
    let userStatus: String?
    let email: String?
    let name: String?
    let middleName: String?
    let lastName: String?
    let roles: [Role]?
    let position: String?
    let photo: String?
    let balance: Int?
    
    enum Role: String, Codable {
        case administrator = "ROLE_ADMINISTRATOR"
        case employee = "ROLE_EMPLOYEE"
    }
    
    var photoURL: URL? {
        if let photo = photo, let url = URL(string: photo) {
            return url
        }
        return nil
    }
    
    var fullName: String {
        if let _lastName = lastName {
            return _lastName + " " + (name ?? "")
        }
        return name ?? "Unknown"
    }
}

typealias Employees = [Employee]
