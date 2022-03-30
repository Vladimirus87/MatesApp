//
//  Message.swift
//  Mate
//
//  Created by Vladimirus on 26.01.2022.
//

import Foundation


// MARK: - Message
struct Message: Codable {
    let createdDate, message: String?
    let messageID: Int?
    let messageStatus, messageType: String?
    let nominatedUserID: Int?
    let nominatedUserName, response, responseDate, userName, userPhoto: String?
    let viewed: Bool?
 
    
    var photoURL: URL? {
        if let photo = userPhoto, let url = URL(string: photo) {
            return url
        }
        return nil
    }
    
    var date: Date? {
        createdDate?.getDate(format: "dd-MM-yyyy,  HH:mm")
    }
    
    var dateString: String? {
        date?.getString(format: "dd.MM.yyyy")
    }
    
    var timeString: String? {
        date?.getString(format: "HH:mm")
    }
}
