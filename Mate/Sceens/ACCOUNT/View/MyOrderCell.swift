//
//  MyOrderCell.swift
//  Mate
//
//  Created by Vladimirus on 25.12.2021.
//

import UIKit

class MyOrderCell: UITableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateData(order: Order?) {
        photo.kf.setImage(with: order?.photoURL, placeholder: UIImage(named: "Logo"))
        name.text = order?.productName
        status.text = order?.status?.prettyName
        status.textColor = order?.status?.color
    }
    
    

    
}
