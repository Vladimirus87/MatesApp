//
//  CardDetailSheetCoordinator.swift
//  Mate
//
//  Created by Vladimirus on 21.12.2021.
//

import UIKit
import UBottomSheet

class CardDetailDataSource:
    UBottomSheetCoordinatorDataSource {
    
    static var minPositions: CGFloat {
        return self.getStatusBarHeight()
    }
    
    static var maxPositions: CGFloat {
        return UIScreen.main.bounds.height/2 + 15
    }
    
    func sheetPositions(_ availableHeight: CGFloat) -> [CGFloat] {
        return [CardDetailDataSource.minPositions, CardDetailDataSource.maxPositions]
    }
    
    func initialPosition(_ availableHeight: CGFloat) -> CGFloat {
        return CardDetailDataSource.maxPositions
    }
    
     static func getStatusBarHeight() -> CGFloat {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 100
        return statusBarHeight
    }
}
