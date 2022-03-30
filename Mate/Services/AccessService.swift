//
//  AccessService.swift
//  Park Share
//
//  Created by Vladimirus on 16.12.2020.
//

import Foundation

class AccessService {
    static let shared = AccessService()
    
    var token: String?
    var user: User?
    var companyShort: CompanyShort?
    var productCategories: Categories?
    var cardInfo: CardInformation?
    
    private init() {}
    
}
