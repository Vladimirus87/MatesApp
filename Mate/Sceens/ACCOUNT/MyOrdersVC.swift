//
//  MyOrdersVC.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit

class MyOrdersVC: UIViewController {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "MyOrderCell"
    
    private var viewModel: PaginationViewModel<Order>!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .gray
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllNibs()
        uiSettings()
        
        viewModel = PaginationViewModel(delegate: self)
        viewModel.fetchOrdersData()
    }
    
    private func uiSettings() {
        title = "Мои заказы"
        navigationItem.backButtonTitle = ""
        tableView.refreshControl = refreshControl
        tableView.prefetchDataSource = self
    }
    
    
    private func initAllNibs() {
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
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
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.endRefreshing()
        cleanAndUpdate()
    }
    
    private func cleanAndUpdate() {
        viewModel.removeAllData()
        tableView.reloadData()
        viewModel.fetchOrdersData()
    }
    
    @IBAction func toShopPressed(_ sender: Any) {
    
    }
}



extension MyOrdersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyOrderCell
        let order = viewModel.data(at: indexPath.row)
        cell.updateData(order: order)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = OrderDetailVC.fromStoryboard(.account)
        let order = viewModel.data(at: indexPath.row)
        vc.order = order
        navigationController?.show(vc, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}


extension MyOrdersVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        prefetchData(for: indexPaths)
    }
    
    private func prefetchData(for indexPaths: [IndexPath]) {
        let lastIndexPath = IndexPath(row: viewModel.totalCount - 1, section: 0)
        if indexPaths.contains(lastIndexPath) {
            viewModel.fetchOrdersData()
        }
    }
}


extension MyOrdersVC: PaginationViewModelDelegate {
    
    func startFetching() {
        DispatchQueue.main.async {
            self.startAnimating()
        }
    }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]) {
        DispatchQueue.main.async {
            self.stopAnimating()
            
            if !newIndexPathsToReload.isEmpty {
                //            tableView.insertRows(at: newIndexPathsToReload, with: .none)
                self.tableView.reloadData()
            }
            
            self.tableView.isHidden = self.viewModel.totalCount == 0
        }
    }
    
    func onFetchFailed(with reason: String) {
        DispatchQueue.main.async {
            self.stopAnimating()
        
            self.tableView.isHidden = self.viewModel.totalCount == 0

            MessageView.sharedInstance.showOnViewWithError(reason)
        }
    }
    
}
