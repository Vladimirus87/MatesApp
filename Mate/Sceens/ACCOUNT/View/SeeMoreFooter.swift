//
//  SeeMoreFooter.swift
//  Mate
//
//  Created by Vladimirus on 26.12.2021.
//

import UIKit

protocol SeeMoreHeaderDelegate: NSObject {
    func seeMore(for category: NotesCategory)
}

class SeeMoreFooter: UIView {
        
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowView: UIImageView!
    
    weak var delegate: SeeMoreHeaderDelegate?
        
    var category: NotesCategory!
    
    func updateData(with category: NotesCategory) {
        titleLabel.text = category.name
        let upDownTransform = arrowView.transform.rotated(by: .pi)
        let normalTransform = arrowView.transform.rotated(by: 0)
        arrowView.transform = category.isCollapsed ? upDownTransform : normalTransform
        self.category = category
    }
    
    
    @IBAction func seeButtonPressed(_ sender: Any) {
        
        if !category.isCollapsed {
            arrowView.rotate()
        } else {
            arrowView.rotate(0)
        }
        
        delegate?.seeMore(for: category)
    }
    

    
}


