//
//  LangVC.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit

class LangVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        uiSettings()
    }
    
    private func uiSettings() {
        title = "Язык"
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

}
