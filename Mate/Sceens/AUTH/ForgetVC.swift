//
//  ForgetVC.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit
import Firebase

class ForgetVC: FatherViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        isActiveMainView = true
        super.viewDidLoad()
        uiSettings()
        
    }
    
    override func localizations() {
        titleLabel.text = "Восстановление \nпароля"
    }
    
    
    func uiSettings() {
        emailField.setBorder()
        emailField.setLeftPaddingPoints(15)
    }
    
    
    @IBAction func reparePressed(_ sender: Any) {
        hideKeyboard()
        guard emailField.text?.isEmail == true else {
            emailField.showMessage("Необходимо ввести e-mail", style: .error)
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: emailField.text!) { error in
            DispatchQueue.main.async {
                if let _error = error {
                    MessageView.sharedInstance.showError(_error)
                    return
                }
                
                let vc = InstructionRecoveryVC.fromStoryboard(.auth)
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        
        
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
