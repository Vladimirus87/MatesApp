//
//  HobbieCell.swift
//  Mate
//
//  Created by Vladimirus on 22.12.2021.
//

import UIKit

protocol HobbieCellDelegate: NSObject {
    func hobbieItemPressed(_ item: UICollectionViewCell)
}

class HobbieCell: UICollectionViewCell {

    @IBOutlet weak var backView: DesignableView!
    @IBOutlet weak var name: UILabel!
    
    weak var delegate: HobbieCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateData(hobbie: String) {
        name.text = hobbie
    }
    
    
    func updateInformationData(hobbie: String) {
        name.text = hobbie
        backView.backgroundColor = UIColor(named: "deepBlue")
        name.textColor = .white
    }
    
    
    @IBAction func itemPressed(_ sender: Any) {
        delegate?.hobbieItemPressed(self)
    }
}
