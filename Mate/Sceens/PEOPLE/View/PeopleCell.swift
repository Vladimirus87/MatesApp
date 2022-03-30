//
//  PeopleCell.swift
//  Mate
//
//  Created by Vladimirus on 21.12.2021.
//

import UIKit

class PeopleCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView.hidesWhenStopped = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateData(employee: Employee?) {
        if let employee = employee {
            name.text = employee.fullName
            position.text = employee.position
            photo.kf.setImage(with: employee.photoURL, placeholder: UIImage(named: "User-Photo-Big"))
            name.alpha = 1
            position.alpha = 1
            photo.alpha = 1
            indicatorView.stopAnimating()
        } else {
            name.alpha = 0
            position.alpha = 0
            photo.alpha = 0
            indicatorView.startAnimating()
        }
    }
    
}
