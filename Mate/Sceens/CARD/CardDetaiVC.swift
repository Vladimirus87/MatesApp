//
//  CardDetaiVC.swift
//  Mate
//
//  Created by Vladimirus on 21.12.2021.
//

import UIKit
import UBottomSheet

class CardDetaiVC: UIViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var amountMoney: UILabel!
    
    var sheetCoordinator: UBottomSheetCoordinator!
    let dataSource: UBottomSheetCoordinatorDataSource = CardDetailDataSource()
    private lazy var networkManager = NetworkManager<UserProvider>()
    
    var card: CardInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        setUI()
        DispatchQueue.main.async {
            self.updateUICard(self.card)
            self.getCardInfo()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setBottomSheet()
    }
    
    private func setUI() {
        navigationItem.backButtonTitle = ""
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCardInfo), name: NotifyIdentifiers.updateCardSum, object: nil)
    }
    
    @objc func updateCardInfo() {
        getCardInfo()
    }
    
    
    private func setBottomSheet() {
        guard sheetCoordinator == nil else {return}
        sheetCoordinator = UBottomSheetCoordinator(parent: self,
                                                   delegate: self)
        
        
        sheetCoordinator.dataSource = dataSource
        
        let bottomVC = CardHistoryVC.fromStoryboard(.card)
        bottomVC.sheetCoordinator = sheetCoordinator

        sheetCoordinator.addSheet(bottomVC, to: self, didContainerCreate: { container in
            let f = self.view.frame
            let rect = CGRect(x: f.minX, y: f.minY, width: f.width, height: f.height)
            container.roundCorners(corners: [.topLeft, .topRight], radius: 17, rect: rect)
        })
        sheetCoordinator.setCornerRadius(17)
    }
    
    @IBAction func sendToEmployeePressed(_ sender: Any) {
        guard let navVC = UIStoryboard.StoryboardType.people.storyboard.instantiateInitialViewController() as? UINavigationController,
              let vc = navVC.viewControllers.first as? PeopleVC else { return }
        vc.completionHandler = { employee in
            sendToEmployee(employee)
        }
        self.present(navVC, animated: true, completion: nil)
        
        func sendToEmployee(_ employee: Employee) {
            let vc = SendToPeopleVC.fromStoryboard(.people)
            let receiver = ReceiverShort(receiverID: employee.userID ?? -1, receiverName: employee.fullName)
            vc.receiver = receiver
            navigationController?.show(vc, sender: nil)
        }
    }
    
    @IBAction func toCorpShopPressed(_ sender: Any) {
        let vc = ShopVC.fromStoryboard(.shop)
        navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}

extension CardDetaiVC: UBottomSheetCoordinatorDelegate {
    
    func bottomSheet(_ container: UIView?, didPresent state: SheetTranslationState) {
        self.sheetCoordinator.addDropShadowIfNotExist()
    }

    func bottomSheet(_ container: UIView?, didChange state: SheetTranslationState) { }

    func bottomSheet(_ container: UIView?, finishTranslateWith extraAnimation: @escaping ((CGFloat) -> Void) -> Void) {
        extraAnimation({ _ in })
    }
   
}


extension CardDetaiVC {
    private func getCardInfo() {
        startAnimating()
        networkManager.request(service: .getCardInfo, decodable: CardInformation.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let card):
                    self.updateUICard(card)
                case .failure(let error):
                    print("error", error)
                    MessageView.sharedInstance.showError(error)
                }
            }
        }
    }
    
    private func updateUICard(_ card: CardInformation?) {
        self.card = card
        name.text = card?.userName
        position.text = card?.position
        amountMoney.text = card?.balance?.toInt().toString() ?? "0"
    }
}
