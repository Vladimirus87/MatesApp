//
//  NotesCategory.swift
//  Mate
//
//  Created by Владимир Моисеев on 16.02.2022.
//

import Foundation

// MARK: - NotesCategory
struct NotesCategory: Codable, Equatable {
    static func == (lhs: NotesCategory, rhs: NotesCategory) -> Bool {
        return lhs.categoryID == rhs.categoryID &&
        lhs.name == rhs.name
    }
    
    let categoryID: Int?
    let name: String?
    let notes: [Note]?
    
    var isCollapsed = false
    
    enum CodingKeys: String, CodingKey {
        case categoryID, name
        case notes
    }

}


// MARK: - Note
struct Note: Codable {
    let companyNoteID: Int?
    let name, noteDescription: String?
//    let companyCategory: String?

    enum CodingKeys: String, CodingKey {
        case companyNoteID, name
        case noteDescription = "description"
//        case companyCategory
    }
}

typealias NotesCategories = [NotesCategory]
