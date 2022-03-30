//
//  SortMD.swift
//  Mate
//
//  Created by Владимир Моисеев on 12.02.2022.
//

import Foundation

struct SortMD {
    let title: String
    let direction: Direction
    let sortingField: Field
    let id: Int
    
    enum Direction: String {
        case toGreat = "ASC"
        case fromGreat = "DESC"
    }
    
    enum Field: String {
        case price = "price"
        case name = "name"
        case date = "creationDate"
    }
}
