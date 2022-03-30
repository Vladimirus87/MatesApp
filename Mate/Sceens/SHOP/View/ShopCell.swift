//
//  ShopCell.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit
import Kingfisher

class ShopCell: UICollectionViewCell {

    @IBOutlet weak var productPhoto: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var currency: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateData(for product: Product?) {
        productPhoto.kf.setImage(with: product?.photoURL, placeholder: UIImage(named: "Logo"))
        name.text = product?.name
        price.text = product?.price?.toString()
        
    }

}
