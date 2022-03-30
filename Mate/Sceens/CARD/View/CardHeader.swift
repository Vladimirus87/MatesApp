//
//  CardHeader.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit

protocol CardHeaderDelegate: NSObject {
    func cardTapped()
}

class CardHeader: UICollectionReusableView {

    @IBOutlet weak var cardBackView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var amountMoney: UILabel!
    
    weak var delegate: CardHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.cardDidTapped))
        cardBackView.addGestureRecognizer(tap)
    }
    
    
    func updateData(card: CardInformation?) {
        name.text = card?.userName
        position.text = card?.position
        amountMoney.text = card?.balance?.toInt().toString() ?? "0"
    }

    
    @objc func cardDidTapped() {
        delegate?.cardTapped()
    }
    
}
