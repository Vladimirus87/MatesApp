//
//  Int+Extensions.swift
//  Mate
//
//  Created by Vladimirus on 25.01.2022.
//

import Foundation

extension Int {
    
    func manyOrNo_tail() -> String {
        switch self {
        case 2...4:
            return "а"
        default:
            return ""
        }
    }
    
    
    func yearsOldString() -> String {
        switch self {
        case 11...19:
            return "\(self) лет"
        default:
            switch (self % 10) {
            case 1:
                return "\(self) год"
            case 2...4:
                return "\(self) года"
            default:
                return "\(self) лет"
            }
        }
    }
    
}
