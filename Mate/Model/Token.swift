//
//  Token.swift
//  Park Share
//
//  Created by Vladimirus on 16.12.2020.
//

import Foundation

// MARK: - Token
class Token: NSObject, NSSecureCoding, Codable {
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    var auth_token: String?
    
    init(authToken: String?) {
        self.auth_token = authToken
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let authToken = aDecoder.decodeObject(forKey: "authToken") as? String
        self.init(authToken: authToken)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(auth_token, forKey: "authToken")
    }
}
