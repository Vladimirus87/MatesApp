//
//  CardHistoryVC.swift
//  Mate
//
//  Created by Vladimirus on 21.12.2021.
//

import UIKit
import UBottomSheet

class CardHistoryVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "CardHistoryCell"
    
    private lazy var transactionsData = Transactions()
    
//    lazy var refreshControl: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action:
//            #selector(handleRefresh(_:)),
//                                 for: UIControl.Event.valueChanged)
//        refreshControl.tintColor = .gray
//        return refreshControl
//    }()
    
    private var transactionsGrouped:  [String : Transactions] {
        return Dictionary(grouping: transactionsData, by: { $0.creationDate ?? "--" })
    }
    
    private var sectionKeys: [String] {
        func getDate(from string: String) -> Date {
            return string.getDate(format: "dd-MM-yyyy") ?? Date()
        }
        return transactionsGrouped.keys.sorted(by: { getDate(from: $0) > getDate(from: $1) })
    }
    
    var sheetCoordinator: UBottomSheetCoordinator?
    
    private lazy var networkManager = NetworkManager<UserProvider>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllNibs()
        setUI()
        DispatchQueue.main.async {
            self.fetchHistoryData()
        }
        
    }
    
    private func setUI() {
        tableView.contentInsetAdjustmentBehavior = .never
//        tableView.refreshControl = refreshControl
        navigationItem.backButtonTitle = ""
    }
    
    private func initAllNibs() {
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sheetCoordinator?.startTracking(item: self)
    }

//    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
//        self.refreshControl.endRefreshing()
//        self.transactionsData = []
//        DispatchQueue.main.async {
//            self.fetchHistoryData()
//        }
//    }
    

}

extension CardHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsGrouped[sectionKeys[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CardHistoryCell
        let transaction = transactionsGrouped[sectionKeys[indexPath.section]]?[indexPath.row]
        cell.updateData(transaction: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let dateString = transactionsGrouped[sectionKeys[section]]?.first?.datePrettyString
        return dateString
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.medium(ofSize: 14)
        header.textLabel?.textAlignment = .center
        header.textLabel?.textColor = UIColor(hexString: "#A2A2A2")
        header.textLabel?.text = header.textLabel?.text?.capitalized
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
}

extension CardHistoryVC: Draggable {
    func draggableView() -> UIScrollView? {
        return tableView
    }
}



extension CardHistoryVC {
    
    private func fetchHistoryData(page: Int = 0) {
        let parameters = PaginationParams(itemsPerPage: 20, orderField: "", page: page)
        startAnimating()
        networkManager.request(service: .getCardHistory(params: parameters), decodable: Transactions.self) { result in
            DispatchQueue.main.async {
                self.stopAnimating()
                switch result {
                case .success(let transactionsMD):
                    append(transactionsMD)
                case .failure(let error):
                    print("error", error)
                        MessageView.sharedInstance.showError(error)
                }
            }
        }
        
        
        func append(_ transactionsData: Transactions) {
            if !transactionsData.isEmpty {
                self.transactionsData.append(contentsOf: transactionsData)
                self.tableView.reloadData()
            }
        }
        
    }
    
    
}
