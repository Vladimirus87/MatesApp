//
//  CardCategoryCell.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit

class CardCategoryCell: UICollectionViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var iconBack: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleDescription: UILabel!
    @IBOutlet weak var counter: UILabel!
    

    
    func updateData(for category: MainCategories) {
        icon.image = UIImage(named: category.imageName)
        iconBack.backgroundColor = UIColor(hexString: category.colorHex)
        titleLabel.text = category.name
        titleDescription.text = category.description
        titleDescription.isHidden = category.description == nil
        counter.text = String(category.counter ?? 0)
        counter.isHidden = category.counter == nil
    }

}
