//
//  Date+Extensions.swift
//  Park Share
//
//  Created by Vladimirus on 28.12.2020.
//

import Foundation

extension Date {
    func getString(format: String = "dd.MM.yyyy", isLocal: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if isLocal == false {
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        } else {
            dateFormatter.timeZone = TimeZone(abbreviation: TimeZone.current.abbreviation() ?? "")
        }
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
}
