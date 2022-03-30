//
//  UserDetailVC.swift
//  Mate
//
//  Created by Vladimirus on 22.12.2021.
//

import UIKit

class UserDetailVC: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var sendMoneyButton: DesignableButton!
    @IBOutlet weak var askButton: DesignableButton!
    @IBOutlet weak var collectionView: UICollectionView!

    private let cellIdentifier = "HobbieCell"
    
    lazy private var networkManager = NetworkManager<UserProvider>()
    
    var employee: Employee?
    
    private lazy var hobbies: [String] = []
    
    private let emptyHobbie = "У пользователя нет хобби"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllNibs()
        uiSettings()
        startCleanUI()
        
        DispatchQueue.main.async {
            self.fetchUserData()
        }
    }
    
    private func initAllNibs() {
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func uiSettings() {
        navigationItem.backButtonTitle = ""
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    
    @IBAction func sendMoneyPressed(_ sender: Any) {
        let vc = SendToPeopleVC.fromStoryboard(.people)
        let receiver = ReceiverShort(receiverID: employee?.userID ?? -1, receiverName: employee?.fullName)
        vc.receiver = receiver
        navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func askPressed(_ sender: Any) {
        let vc = AskingVC.fromStoryboard(.people)
        vc.employee = employee
        navigationController?.show(vc, sender: nil)
    }
    
}

extension UserDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hobbies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! HobbieCell
        cell.updateData(hobbie: hobbies[indexPath.row])
        return cell
    }
    
    
}


extension UserDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (hobbies[indexPath.row].width(withConstrainedHeight: 27, font: UIFont.regular(ofSize: 15))) + 40
            return CGSize(width: width, height: 27)
    }
}

extension UserDetailVC {
    private func startCleanUI() {
        title = employee?.fullName
        position.text = employee?.position
        age.text = ""
        navigationItem.backButtonTitle = ""
        sendMoneyButton.disableButton()
        askButton.disableButton()
    }
    
    private func fetchUserData() {
        guard let _id = employee?.userID else {
            MessageView.sharedInstance.showOnView(message: "Unknown user id", theme: .warning)
            return
        }
        startAnimating()
        networkManager.request(service: .getUser(userID: _id), decodable: User.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let user):
                    self.updateUserUI(user)
                case .failure(let error):
                    print("error", error)
                    MessageView.sharedInstance.showError(error)
                }
            }
        }
    }
    
    private func updateUserUI(_ user: User) {
        if let _hobbies = user.hobbies, !_hobbies.isEmpty {
            self.hobbies = _hobbies
        } else {
            self.hobbies = [emptyHobbie]
        }
        
        self.hobbies = user.hobbies ?? [emptyHobbie]
        
        self.photo.kf.setImage(with: user.photoURL) { result in
            if case .failure = result {
                DispatchQueue.main.async {
                    self.photo.image = UIImage(named: "User-Photo-Big")
                }
            }
        }
        
        if let dateOfBirth = user.dateOfBirth?.getDate(),
           let years = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year {
            self.age.text = dateOfBirth.getString() + " (" + (years.yearsOldString()) + ")"
        }
        
        
        sendMoneyButton.enableButton()
        askButton.enableButton()
        collectionView.reloadData()
    }
     
}
