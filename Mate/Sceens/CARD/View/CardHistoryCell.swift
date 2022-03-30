//
//  CardHistoryCell.swift
//  Mate
//
//  Created by Vladimirus on 21.12.2021.
//

import UIKit

class CardHistoryCell: UITableViewCell {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var carrencyLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateData(transaction: Transaction?) {
        logo.image = transaction?.logo
        titleLabel.text = transaction?.titleText
        descriptionLabel.text = transaction?.transactionDescription
        sum.text = transaction?.transactionAmount?.toString()
        transaction?.isTransactionToMe == true ? toMeUI() : fromMeUI()
    }
    
    private func toMeUI() {
        sum.textColor = UIColor(named: "green")
        carrencyLogo.image = UIImage(named: "CARENCY-SYMBOl_green")
    }
    
    private func fromMeUI() {
        sum.textColor = .black
        carrencyLogo.image = UIImage(named: "CARENCY-SYMBOL")
    }
    
}
