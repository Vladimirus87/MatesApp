//
//  ShopVC.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit
import ISEmojiView

//TODO: - NEED TRANSITION ANIMATION

class ShopVC: UIViewController {

    @IBOutlet weak var categoryBtn: DesignableButton!
    @IBOutlet weak var sortButton: DesignableButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchItem: UIBarButtonItem!
    
    private let cellIdentifier = "ShopCell"
    
    private let queue = DispatchQueue(label: "ProductsFetchQueue", attributes: .concurrent)
    
    private lazy var networkManager = NetworkManager<UserProvider>()
    private var viewModel: PaginationViewModel<Product>!

    
    
    
    private lazy var choosedCategory: [Category] = []
    
    var choosedIds: [Int] {
        return choosedCategory.compactMap({$0.categoryID})
    }
    
    private let sortData: [SortMD] = [
        SortMD(title: "От дешовых к дорогим", direction: .toGreat, sortingField: .price, id: 1),
        SortMD(title: "От дорогих к дешовым", direction: .fromGreat, sortingField: .price, id: 2),
        SortMD(title: "По названию", direction: .toGreat, sortingField: .name, id: 3)
    ]
    
    private var sortValue: SortMD?

    private var searchingText: String?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .gray
        return refreshControl
    }()
    
    lazy var goToMyOrders: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllNibs()
        uiSettings()
        
        viewModel = PaginationViewModel(delegate: self)
        viewModel.fetchProductsData()
        
        queue.async {
            self.fetchCategoriesData()
        }
    }
    
    private func uiSettings() {
        title = "Магазин"
        navigationItem.backButtonTitle = ""
        collectionView.refreshControl = refreshControl
        collectionView.prefetchDataSource = self
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromCardVC {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        
        if goToMyOrders {
            goToMyOrders = false
            let vc = MyOrdersVC.fromStoryboard(.account)
            navigationController?.show(vc, sender: true)
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if isFromCardVC, isMovingFromParent {
//            navigationController?.setNavigationBarHidden(true, animated: animated)
//        }
//    }
    
 
    private func initAllNibs() {
        collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl.endRefreshing()
        cleanAndUpdate()
    }
    
    
    func showSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = true
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.returnKeyType = UIReturnKeyType.search
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    
    private func cleanAndUpdate() {
        viewModel.removeAllData()
        collectionView.reloadData()
        viewModel.fetchProductsData(with: choosedIds, sort: sortValue)
    }
    
    @IBAction func sortPressed(_ sender: UIButton) {
        let popDataArr = sortData.map({PopupMD(title: $0.title, id: $0.id)})
        openTablePop(data: popDataArr, sourceView: sender) { choosedSort in
            DispatchQueue.main.async {
                if let index = self.sortData.firstIndex(where: { $0.id == choosedSort.id }) {
                    self.sortValue = self.sortData[index]
                    self.cleanAndUpdate()
                }
            }
            
        }
    }
    
    @IBAction func categoryPressed(_ sender: Any) {
        let vc = CategoryVC.fromStoryboard(.shop)
        vc.startSelectionCategories = choosedCategory
        vc.choosedCategory = { [weak self] choosed in
            DispatchQueue.main.async {
                self?.choosedCategory = choosed
                self?.cleanAndUpdate()
            }
        }
        navigationController?.show(vc, sender: nil)
    }
    

    
    @IBAction func searchPressed(_ sender: Any) {
        showSearchBar()
    }
}


extension ShopVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ShopCell
        let product = viewModel.data(at: indexPath.row)
        cell.updateData(for: product)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ProductDetailVC.fromStoryboard(.shop)
        vc.hidesBottomBarWhenPushed = true
        let productID = viewModel.data(at: indexPath.row).productID
        vc.productID = productID
        navigationController?.show(vc, sender: nil)
    }
        
}

extension ShopVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetchData(for: indexPaths)
    }
    
    private func prefetchData(for indexPaths: [IndexPath]) {
        let lastIndexPath = IndexPath(row: viewModel.totalCount - 1, section: 0)
        if indexPaths.contains(lastIndexPath) {
            viewModel.fetchProductsData(with: choosedIds, name: searchingText ?? "", sort: sortValue)
        }
    }
    
    
}

extension ShopVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let cellPadding: CGFloat = 5
        let cof: CGFloat = 1.45
        let width = (UIScreen.main.bounds.width - (padding * 2) - cellPadding) / 2
        return CGSize(width: width, height: width * cof)
    }
}

extension ShopVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.removeAllData()
        collectionView.reloadData()
        searchingText = searchText
        viewModel.fetchProductsData(with: choosedIds, name: searchText, sort: sortValue)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchingText = nil
        navigationItem.searchController = nil
        if searchingText?.isEmpty == false {
            cleanAndUpdate()
        }
    }
    
    
}

extension ShopVC: PaginationViewModelDelegate {
    
    func startFetching() {
        DispatchQueue.main.async {
            self.startAnimating()
        }
    }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]) {
        DispatchQueue.main.async {
            self.stopAnimating()
            
            if !newIndexPathsToReload.isEmpty {
                self.collectionView.reloadData()
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


extension ShopVC {
    
    private func fetchCategoriesData() {
        if AccessService.shared.productCategories == nil {
            getProductsCategories()
        }
    }
    
    private func getProductsCategories() {
        guard let companyID = AccessService.shared.companyShort?.companyID else {
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
            }
        }
    }
    
}
