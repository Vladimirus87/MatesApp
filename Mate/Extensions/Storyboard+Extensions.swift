//
//  Storyboard+Extensions.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit

extension UIStoryboard {

    enum StoryboardType {
        case initial
        case main
        case auth
        case card
        case shop
        case people
        case account
    }

    static var initial: UIStoryboard {
        return UIStoryboard(name: Bundle.main.infoDictionary?["UIMainStoryboardFile"] as! String, bundle: Bundle.main)
    }
}

extension UIStoryboard.StoryboardType {

    var storyboard: UIStoryboard {
        switch self {
        case .main:
            return UIStoryboard(name: "Main", bundle: Bundle.main)
        case .auth:
            return UIStoryboard(name: "Auth", bundle: Bundle.main)
        case .card:
            return UIStoryboard(name: "Card", bundle: Bundle.main)
        case .shop:
            return UIStoryboard(name: "Shop", bundle: Bundle.main)
        case .people:
            return UIStoryboard(name: "People", bundle: Bundle.main)
        case .account:
            return UIStoryboard(name: "Account", bundle: Bundle.main)
        case .initial:
            return UIStoryboard.initial
        }
    }
}


