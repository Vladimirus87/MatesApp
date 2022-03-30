//
//  NotificationsVC.swift
//  Mate
//
//  Created by Vladimirus on 20.12.2021.
//

import UIKit

protocol NotificationsScreen {
    var entityID: Int? { get set }
}


class NotificationsScreenVC: FatherViewController, NotificationsScreen {
    var entityID: Int?
    lazy var networkManager = NetworkManager<UserProvider>()
}


class NotificationsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    private let cellIdentifier = "NotifyCell"
    
    private var viewModel: NotificationsViewModel!
    
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
        setUI()
        
        viewModel = NotificationsViewModel(delegate: self)
        viewModel.fetchData()
        startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromCardVC {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isFromCardVC, isMovingFromParent {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    private func initAllNibs() {
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    private func setUI() {
        tableView.refreshControl = refreshControl
        title = ""
        navigationItem.backButtonTitle = ""
        tableView.prefetchDataSource = self
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.endRefreshing()
        DispatchQueue.main.async {
            self.cleanAndUpdate()
        }
    }
    
    private func cleanAndUpdate() {
        startAnimating()
        viewModel.removeAllData()
        tableView.reloadData()
        viewModel.fetchData()
    }

    
}


extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.countIn(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotifyCell
        let notify = viewModel.entity(at: indexPath)
        cell.updateData(notify: notify)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notify = viewModel.entity(at: indexPath)
        
        if notify?.viewed == false,
            let notificationID = notify?.notificationID {
            DispatchQueue.global(qos: .background).async {
                self.viewModel.notificationDidView(id: notificationID, indexPath: indexPath)
            }
        }
        
        self.showNotificationTypeVC(for: notify)
    }
    
    private func showNotificationTypeVC(for entity: NotificationEntity?) {
        guard let vc = entity?.notifyType?.viewController else {
            MessageView.sharedInstance.showOnView(message: "Unknown type", theme: .warning)
            return
        }
        vc.entityID = entity?.entityID
        navigationController?.show(vc, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: NotifyHeader = UIView.fromNib()
        
        let isHideAction = !(section == 0 && viewModel.unviewedCount > 0)
        let dateString = viewModel.dateString(for: section)
        header.updateData(prettyDate: dateString, isHideAction: isHideAction)
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 39
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    
}

extension NotificationsVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        
        if indexPaths.contains(where: isLoadingCell) {
            viewModel.fetchData()
        }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath == (viewModel.lastIndexPath ?? [0, 0])
    }
}



extension NotificationsVC: NotifyHeaderDelegate {
    func markAsRead() {
        viewModel.allnotificationsDidView()
    }
 
}


extension NotificationsVC: NotificationsViewModelDelegate {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        stopAnimating()
        tableView.reloadData()
    }
    
    func onFetchFailed(with reason: String) {
        stopAnimating()
        MessageView.sharedInstance.showOnViewWithError(reason)
    }
    
    func notificationDidRead(for indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? NotifyCell {
            cell.readUI()
        }
    }
    
    func updateTitle(count unviewed: Int?) {
        if let _unviewed = unviewed, _unviewed > 0 {
            title = "Уведомления (\(_unviewed))"
        } else {
            title = "Уведомления"
        }
    }
    
    
}
