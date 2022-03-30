//
//  PaginationViewModel.swift
//  Mate
//
//  Created by Vladimirus on 30.01.2022.
//

import Foundation

protocol PaginationViewModelDelegate: NSObject {
    func startFetching()
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath])
    func onFetchFailed(with reason: String)
}

final class PaginationViewModel <T: Codable> {
    private weak var delegate: PaginationViewModelDelegate?
    var data: [T] = []
    private var currentPage = 0
    private var isFetchInProgress = false
    private var isFetchEnded = false
    private let client = NetworkManager<UserProvider>()
    
    
    init(delegate: PaginationViewModelDelegate) {
        self.delegate = delegate
    }
    
    private var itemsPerLoad: Int {
        return 20
    }
    
    var totalCount: Int {
        return data.count
    }
    
    
    
    
    private func fetching(_ service: UserProvider) {
        delegate?.startFetching()
        
        let queue = DispatchQueue(label: "paginationFetchQueue", attributes: .concurrent)
        queue.async {
            self.client.request(service: service, decodable: [T].self) { result in
                self.isFetchInProgress = false
                
                switch result {
                case .success(let response):
                    self.hendleResponse(response)
                
                case .failure(let error):
                    self.delegate?.onFetchFailed(with: error.localizedDescription)
                }
            }
        }
    }
    
    private func hendleResponse(_ response: [T]) {
        if response.isEmpty {
            completeLoading()
        } else {
            handleAndContinue()
        }
        
        func handleAndContinue() {
            currentPage += 1
            
            data.append(contentsOf: response)
            
            let indexPathsToReload = self.calculateIndexPathsToReload(from: response)
            delegate?.onFetchCompleted(with: indexPathsToReload)
        }
        
        func completeLoading() {
            isFetchEnded = true
            delegate?.onFetchCompleted(with: [])
        }
    }
    
    
    private func calculateIndexPathsToReload(from newModerators: [T]) -> [IndexPath] {
        let startIndex = data.count - newModerators.count
        let endIndex = startIndex + newModerators.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
}


// MARK:- PUBLIC
extension PaginationViewModel {
    
    func data(at index: Int) -> T {
        return data[index]
    }
    
    func removeAllData() {
        data = []
        currentPage = 0
        isFetchEnded = false
    }

    
    func fetchData(with query: String = "") {
        
        guard !isFetchInProgress && !isFetchEnded else {
            return
        }
        
        isFetchInProgress = true
        
        var service: UserProvider {
            switch T.self {
            default:
                let parameters = PaginationParams(itemsPerPage: itemsPerLoad, orderField: "", page: currentPage, query: query)
                return .getUsers(params: parameters)
            }
        }
        fetching(service)
    }
    
    
    func fetchProductsData(with categoryIDs: [Int] = [], name: String = "", sort: SortMD? = nil) {
        guard !isFetchInProgress && !isFetchEnded else {
            return
        }
        
        isFetchInProgress = true
        
        var service: UserProvider {
            switch T.self {
            default:
                let companyID = AccessService.shared.companyShort?.companyID
                let parameters = ProductParams(companyID: companyID!, direction: sort?.direction.rawValue ?? SortMD.Direction.toGreat.rawValue, itemsPerPage: itemsPerLoad, name: name, orderField: sort?.sortingField.rawValue ?? "", page: currentPage, productCategoryIDs: categoryIDs)
                return .getProducts(params: parameters)
            }
        }
        fetching(service)
    }
    
    
    func fetchOrdersData(status: Order.OrderStatus = .new) {
        guard !isFetchInProgress && !isFetchEnded else {
            return
        }
        
        isFetchInProgress = true
        
        var service: UserProvider {
            switch T.self {
            default:
                let companyID = AccessService.shared.companyShort?.companyID
                let userID = AccessService.shared.user?.userID
                let parameters = OrdersParams(companyID: companyID!, itemsPerPage: itemsPerLoad, orderField: SortMD.Field.date.rawValue, orderStatus: status.rawValue, page: currentPage, userID: userID!)
                return .getOrders(params: parameters)
            }
        }
        fetching(service)
    }
}
