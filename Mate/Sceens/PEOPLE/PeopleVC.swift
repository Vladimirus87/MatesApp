//
//  PeopleVC.swift
//  Mate
//
//  Created by Vladimirus on 21.12.2021.
//

import UIKit

//1) Сделатьактивным поиск по юзерам
//2) Глобально выполнить загрузку с офсетами
//3) Прикрутить магазин + Сортировка + Поиск
//4) Меню профиля

class PeopleVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "PeopleCell"
    
    private var viewModel: PaginationViewModel<Employee>!
    
    private var searchingText: String?
    
    var completionHandler: ((Employee)->())?
    
    
    
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
        showSearchBar()
        
        viewModel = PaginationViewModel(delegate: self)
        viewModel.fetchData()
    }
    
    
    private func initAllNibs() {
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    
    private func uiSettings() {
        title = "Сотрудники"
        navigationItem.backButtonTitle = ""
        tableView.refreshControl = refreshControl
        tableView.prefetchDataSource = self
        setCloseBarItem()

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
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.endRefreshing()
        cleanAndUpdate()
    }
    
    private func cleanAndUpdate() {
        viewModel.removeAllData()
        tableView.reloadData()
        viewModel.fetchData()
    }
    
    func showSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = true
        navigationItem.hidesSearchBarWhenScrolling = true
        //true for hiding, false for keep showing while scrolling
        searchController.searchBar.sizeToFit()
        searchController.searchBar.returnKeyType = UIReturnKeyType.search
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
    }
    
    private func setCloseBarItem() {
        if isModal {
            let closeItem = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.closePressed(_:)))
            navigationItem.rightBarButtonItems = [closeItem]
        }
    }
    
    
    

    @IBAction func closePressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}


extension PeopleVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PeopleCell
        cell.updateData(employee: viewModel.data(at: indexPath.row))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isModal {
            navigationController?.dismiss(animated: true, completion: {
                self.completionHandler?(self.viewModel.data(at: indexPath.row))
            })
        } else {
            let vc = UserDetailVC.fromStoryboard(.people)
            vc.employee = viewModel.data(at: indexPath.row)
            navigationController?.show(vc, sender: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

extension PeopleVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.removeAllData()
        tableView.reloadData()
        searchingText = searchText
        viewModel.fetchData(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchingText = nil
        cleanAndUpdate()
    }
    
    
}

extension PeopleVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        prefetchData(for: indexPaths)
    }
    
    private func prefetchData(for indexPaths: [IndexPath]) {
        let lastIndexPath = IndexPath(row: viewModel.totalCount - 1, section: 0)
        if indexPaths.contains(lastIndexPath) {
            viewModel.fetchData(with: searchingText ?? "")
        }
    }
}


extension PeopleVC: PaginationViewModelDelegate {
    
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
        }
    }
    
    func onFetchFailed(with reason: String) {
        DispatchQueue.main.async {
            self.stopAnimating()
        
            MessageView.sharedInstance.showOnViewWithError(reason)
        }
    }
    
}

