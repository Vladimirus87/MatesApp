//
//  PasswordParams.swift
//  Mate
//
//  Created by Владимир Моисеев on 10.02.2022.
//

import Foundation

// MARK: - PasswordParams
struct PasswordParams: Codable {
    let password, passwordConfirmation: String
}
