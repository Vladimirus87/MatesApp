//
//  NotepadAlertTableVC.swift
//  JobnetAPP
//
//  Created by Vladimirus on 11.08.2021.
//  Copyright © 2021 Jobnetzwerk. All rights reserved.
//

import UIKit

struct PopupMD {
    let title: String
    let id: Int
}

class NotepadAlertTableVC: UITableViewController {
    
    static let cellHeight: CGFloat = 38
    
    private let cellIdentifier = "CategoryCell"
    
    var alertData: [PopupMD]!
    var choosedAction: ((PopupMD)->())?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllNibs()
        tableView.tableFooterView = UIView()
    }
    

    private func initAllNibs() {
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }

    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return alertData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CategoryCell
        cell.updateNotepadData(title: alertData[indexPath.row].title, isSel: false)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosedAction?(alertData[indexPath.row])
        self.dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NotepadAlertTableVC.cellHeight
    }

}
