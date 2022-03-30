//
//  CardVC.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit

class CardVC: UIViewController {

    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let cellIdentifier = "CardCategoryCell"
    private let headerIdentifier = "CardHeader"
    
    var cardView: CardHeader?
    var cardInfo: CardInformation? {
        return AccessService.shared.cardInfo
    }
    
    private let transitionManager = CardTransitionCoordinator(duration: 0.5)
    private lazy var networkManager = NetworkManager<UserProvider>()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .gray
        return refreshControl
    }()
    
    var data: [MainCategories] {
        CardData.shared.categories
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllNibs()
        addObservers()
        setUI()
        let queue = DispatchQueue(label: "cardFetchQueue", attributes: .concurrent)
        queue.async {
            self.fetchData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    private func initAllNibs() {
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(UINib(nibName: headerIdentifier, bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCardInfo), name: NotifyIdentifiers.updateCardSum, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCardInfo), name: NotifyIdentifiers.updateUserInfo, object: nil)
    }
    
    @objc func updateCardInfo() {
        startAnimating()
        getCardInfo {
            DispatchQueue.main.async {
                self.stopAnimating()
            }
        }
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.endRefreshing()
        DispatchQueue.main.async {
            self.fetchData()
        }
    }

    @IBAction func notificationsPressed(_ sender: Any) {
        let notifyVC = NotificationsVC.fromStoryboard(.card)
        navigationController?.show(notifyVC, sender: nil)
    }
    

}


extension CardVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CardCategoryCell
        cell.updateData(for: data[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = ShopVC.fromStoryboard(.shop)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.show(vc, sender: nil)
        case 1:
            let vc = PeopleVC.fromStoryboard(.people)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.show(vc, sender: nil)
        case 3:
            let vc = MyOrdersVC.fromStoryboard(.account)
            vc.hidesBottomBarWhenPushed = true
            navigationController?.show(vc, sender: nil)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! CardHeader
            headerView.delegate = self
            headerView.updateData(card: cardInfo)
            self.cardView = headerView
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
    
}


extension CardVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let width = (UIScreen.main.bounds.width - (padding * 3)) / 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = UIScreen.main.bounds.size.width - 40
        let cof: CGFloat = 1.57
        return CGSize(width: UIScreen.main.bounds.size.width, height: width / cof)
    }
}



extension CardVC: CardHeaderDelegate {
    func cardTapped() {
        let vc = CardDetaiVC.fromStoryboard(.card)
        vc.card = cardInfo
//        navigationController?.delegate = transitionManager
        navigationController?.show(vc, sender: nil)
        
    }
    
}



extension CardVC {
    
    private func setUI() {
        collectionView.reloadData()
        collectionView.contentInset.top = 20
        collectionView.refreshControl = refreshControl
        navigationItem.backButtonTitle = ""
    }
    
    private func fetchData() {
        DispatchQueue.main.async {
            self.startAnimating()
        }
        
        let dispatchGorup = DispatchGroup()
        
        dispatchGorup.enter()
        getCardInfo {
            dispatchGorup.leave()
        }
        
        dispatchGorup.enter()
        getCompanyShortInfo {
            dispatchGorup.leave()
        }
        
        dispatchGorup.enter()
        getProductsCategories {
            dispatchGorup.leave()
        }
        
        dispatchGorup.notify(queue: .main) { [weak self] in
            self?.stopAnimating()
        }
    }
    
    private func getCardInfo(completion: @escaping ()->()) {
        networkManager.request(service: .getCardInfo, decodable: CardInformation.self) { result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let card):
                    self.updateUICard(card)
                case .failure(let error):
                    print("error", error)
                    MessageView.sharedInstance.showError(error)
                }
                completion()
            }
        }
    }
    
    
    private func getCompanyShortInfo(completion: @escaping  ()->()) {
        networkManager.request(service: .getCompanyShort, decodable: CompanyShort.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let company):
                    self.updateCompanyName(company)
                case .failure(let error):
                    MessageView.sharedInstance.showError(error)
                }
                completion()
            }
            
        }
    }
    
    private func getProductsCategories(completion: @escaping  ()->()) {
        guard let companyID = AccessService.shared.companyShort?.companyID else {
            completion()
            return
        }
        
        let parameters = CategoryParams(companyID: companyID)
        
        networkManager.request(service: .getProductsCategory(params: parameters), decodable: Categories.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    AccessService.shared.productCategories = categories
                case .failure(let error):
                    MessageView.sharedInstance.showError(error)
                }
                completion()
            }
            
        }
    }
    
    private func updateCompanyName(_ company: CompanyShort?) {
        companyName.text = company?.name
        AccessService.shared.companyShort = company
    }
    
    private func updateUICard(_ card: CardInformation) {
        AccessService.shared.cardInfo = card
        if let index = data.firstIndex(where: {$0.tag == 2}),
            let employeeCount = card.employeeCount {
            CardData.shared.categories[index].description = "\(employeeCount) " + "человек" + employeeCount.manyOrNo_tail()
        }
        collectionView.reloadData()
    }
}



//TEMP
struct MainCategories {
    let imageName: String
    let colorHex: String
    let name: String
    var description: String?
    var counter: Int?
    var vcIdentifier: String
    var tag = 0
}

class CardData {
    static let shared = CardData()
    var categories: [MainCategories] = [
        MainCategories(imageName: "Shop-Icon_black", colorHex: "#FFEDDA", name: "Магазин", description: "15 товаров", counter: nil, vcIdentifier: ""),
        MainCategories(imageName: "Team-Icon_black", colorHex: "#EAE9F3", name: "Сотрудники", description: "11 человек", counter: nil, vcIdentifier: "", tag: 2),
        MainCategories(imageName: "Onboarding_icon", colorHex: "#DBECF5", name: "Онбординг", description: nil, counter: nil, vcIdentifier: ""),
        MainCategories(imageName: "Shopping_icon", colorHex: "#F5E0D9", name: "Мои заказы", description: nil, counter: nil, vcIdentifier: "")
    ]
}
