//
//  AccountVC.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit

class AccountVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userPosition: UILabel!
    
    private let cellIdentifier = "CategoryCell"
    
    private let accData: [AccountModel] = [
        AccountModel(name: "Информация", vc: InformationVC.self),
//        AccountModel(name: "Язык", vc: LangVC.self),
        AccountModel(name: "О компании", vc: AboutCompanyVC.self),
        AccountModel(name: "Мои заказы", vc: MyOrdersVC.self),
        AccountModel(name: "Выйти", vc: UIAlertController.self)
        
    ]
    
    var user: User? {
        return AccessService.shared.user
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllNibs()
        uiSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.fetchData()
        }
    }

    
    private func initAllNibs() {
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    
    private func uiSettings() {
        navigationItem.backButtonTitle = ""
    }
    
    private func fetchData() {
        userPhoto.kf.setImage(with: user?.photoURL, placeholder: UIImage(named: "Card-BG"))
        userFullName.text = user?.fullName
        userPosition.text = user?.position 
    }
    

}


extension AccountVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CategoryCell
        cell.updateAccountData(accData[indexPath.row].name)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == accData.count - 1 {
            exitAlert()
        } else {
            let controller = accData[indexPath.row].vc
            let vc = controller.fromStoryboard(.account)
            navigationController?.show(vc, sender: true)
        }
    }
    
}


extension AccountVC {
    private func exitAlert() {
        let refreshAlert = UIAlertController(title: "Выход", message: "Действительно хотите выйти?", preferredStyle: .alert)
        refreshAlert.addAction(UIAlertAction(title: "Выйти", style: .default, handler: { (action: UIAlertAction!) in
            DispatchQueue.main.async {
                EnterService.logout()
            }
        }))
        refreshAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        self.present(refreshAlert, animated: true, completion: nil)
    }
}

struct AccountModel {
    let name: String
    let vc: UIViewController.Type
}
