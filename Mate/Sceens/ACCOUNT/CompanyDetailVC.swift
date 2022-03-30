//
//  CompanyDetailVC.swift
//  Mate
//
//  Created by Vladimirus on 26.12.2021.
//

import UIKit

class CompanyDetailVC: UIViewController {

    @IBOutlet weak var textView: CustomUITextView!
    
    var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSettings()
        updateData(with: self.note)
        
    }
    
    
    private func uiSettings() {
        textView.leftSpace()
    }

    
    private func updateData(with note: Note?) {
        title = note?.name
        textView.text = note?.noteDescription
    }


}
