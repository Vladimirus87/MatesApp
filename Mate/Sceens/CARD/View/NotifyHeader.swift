//
//  NotifyHeader.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit

protocol NotifyHeaderDelegate: NSObject {
    func markAsRead()
}

class NotifyHeader: UIView {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    weak var delegate: NotifyHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        actionButton.setTitle("Отметить все как прочитанные", for: .normal)
    }
    
    func updateData(prettyDate: String?, isHideAction: Bool) {
        dateLabel.text = prettyDate
        actionButton.isHidden = isHideAction
    }
    
    @IBAction func actionPressed(_ sender: Any) {
        delegate?.markAsRead()
    }
    
}
