//
//  NotifyMessageCell.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit


class NotifyCell: UITableViewCell {
    @IBOutlet weak var backView: DesignableView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
//    var type: NotifyType!
    
    func updateData(notify: NotificationEntity?) {
        titleLabel.text = notify?.title
        subtitleLabel.text = notify?.datumDescription
        timeLabel.text = notify?.timeString
        
        let type = notify?.notifyType
        let isRead = notify?.viewed ?? true
        
        icon.image = type?.image
        
        if isRead {
            readUI()
        } else {
            unreadUI()
        }
    }
    
    func readUI() {
        backView.backgroundColor = UIColor(named: "background")
        backView.borderColor = UIColor(named: "greyBorder")
        backView.shadowColor = UIColor.black.withAlphaComponent(0)
    }
    
    private func unreadUI() {
        backView.backgroundColor = UIColor.white
        backView.borderColor = .clear
        backView.shadowColor = UIColor.black.withAlphaComponent(1)
    }
    
}



enum OrderType: String, Codable {
    case message = "MESSAGE"
    case deposit = "DEPOSIT"
    case transfer = "TRANSFER"
    case order = "ORDER"
    
    var image: UIImage? {
        switch self {
        case .message:
            return UIImage(named: "Message-Icon")
        case .deposit, .transfer:
            return UIImage(named: "Money-Icon")
        case .order:
            return UIImage(named: "Shop-Icon-rounded")
        }
    }
    
    var viewController: NotificationsScreenVC? {
        switch self {
        case .message:
            return NotifyMessageDetailVC.fromStoryboard(.card)
        case .deposit:
            return NotifyDepositVC.fromStoryboard(.card)
        case .transfer:
            return NotifyTransferVC.fromStoryboard(.card)
        case .order:
            return NotifyOrderVC.fromStoryboard(.card)
        }
    }
}
