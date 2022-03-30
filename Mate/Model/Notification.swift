//
//  Notification.swift
//  Mate
//
//  Created by Vladimirus on 25.01.2022.
//

import Foundation

// MARK: - Notifications
struct Notifications: Codable {
    let data: [NotificationEntity]?
    var unviewed: Int?
}

// MARK: - Datum
struct NotificationEntity: Codable {
    let entityID: Int
    let notificationID: Int?
    let title, datumDescription, type: String?
    var viewed: Bool?
    let creationDate: String?

    enum CodingKeys: String, CodingKey {
        case notificationID, entityID, title
        case datumDescription = "description"
        case type, viewed, creationDate
    }


    var notifyType: OrderType? {
        return OrderType(rawValue: type ?? "")
    }
    
    
    
    var date: Date? {
        creationDate?.getDate(format: "dd-MM-yyyy,  HH:mm")
    }
    
    var simpleKeyDate: String? {
        guard let stringDate = creationDate?.split(separator: ",").first, !stringDate.isEmpty else { return nil }
        return String(stringDate)
    }
    
    var dateString: String? {
        date?.getString(format: "dd.MM")
    }
    
    var timeString: String? {
        date?.getString(format: "HH:mm")
    }
    
    var datePrettyString: String? {
        guard let _date = date else { return nil }
        
        if Calendar.current.isDateInToday(_date) {
            return "Сегодня"
        } else if Calendar.current.isDateInYesterday(_date) {
            return "Вчера"
        } else {
            return dateString
        }
    }

}



