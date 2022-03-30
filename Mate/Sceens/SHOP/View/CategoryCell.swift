//
//  CategoryCell.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateNotepadData(title: String, isSel: Bool) {
        checkBox.isHidden = !isSel
        titleLabel.text = title
    }
    
    func updateCategoryData(category: Category, isSel: Bool) {
        checkBox.isHidden = !isSel
        titleLabel.text = category.name
    }
    
    func updateAccountData(_ data: String) {
        checkBox.image = UIImage(named: "Arrow")
        titleLabel.text = data
    }
    
    func updateNote(_ note: Note?) {
        checkBox.isHidden = true
        titleLabel.text = note?.name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
