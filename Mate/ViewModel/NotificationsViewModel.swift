//
//  NotificationsViewModel.swift
//  Mate
//
//  Created by Vladimirus on 30.01.2022.
//

import Foundation

protocol NotificationsViewModelDelegate: NSObject {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
    func updateTitle(count unviewed: Int?)
    func notificationDidRead(for indexPath: IndexPath)
}

final class NotificationsViewModel  {
    private weak var delegate: NotificationsViewModelDelegate?
    private var data: [NotificationEntity] = []
    
    private var notificationsGrouped:  [String : [NotificationEntity]] {
        return Dictionary(grouping: data, by: { $0.simpleKeyDate! })
    }
    
    private var sectionKeys: [String] {
        func getDate(from string: String) -> Date {
            return string.getDate(format: "dd-MM-yyyy") ?? Date()
        }
        return notificationsGrouped.keys.sorted(by: { getDate(from: $0) > getDate(from: $1) })
    }
    
    var unviewedCount: Int = 0 {
        didSet {
            delegate?.updateTitle(count: unviewedCount)
        }
    }
    
    private var currentPage = 0
    private var isFetchInProgress = false
    private let client = NetworkManager<UserProvider>()
    
    init(delegate: NotificationsViewModelDelegate) {
        self.delegate = delegate
    }
    
    private var itemsPerLoad: Int {
        return 5
    }
    
    var totalCount: Int {
        return data.count
    }
    
    var lastIndexPath: IndexPath? {
        let lastSection = sectionKeys.count - 1
        
        guard lastSection >= 0 else {
            return nil
        }
        
        let countInSection = countIn(lastSection)
        
        return IndexPath(row: countInSection - 1, section: lastSection)
    }
    
    
    var sectionsCount: Int {
        return sectionKeys.count
    }
    
    func countIn(_ section: Int) -> Int {
        return notificationsGrouped[sectionKeys[section]]?.count ?? 0
    }
    
    
    func entity(at indexPath: IndexPath) -> NotificationEntity? {
        return notificationsGrouped[sectionKeys[indexPath.section]]?[indexPath.row]
    }
    
    func dateString(for section: Int) -> String? {
        return notificationsGrouped[sectionKeys[section]]?.first?.datePrettyString
    }
    
    func removeAllData() {
        data = []
        currentPage = 0
    }

    
    func fetchData() {
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true
        
        let parameters = PaginationParams(itemsPerPage: itemsPerLoad, orderField: "", page: currentPage, query: nil)
        
        client.request(service: .getNotifications(params: parameters), decodable: Notifications.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        self.currentPage += 1
                        self.isFetchInProgress = false
                        
                        self.data.append(contentsOf: response.data ?? [])
                        
                        let responseCount = response.data?.count ?? 0
                        
                        if responseCount == self.itemsPerLoad {
//                            let indexPathsToReload = self.calculateIndexPathsToReload(from: response.data ?? [])
                            self.unviewedCount = response.unviewed ?? 0
                            self.delegate?.onFetchCompleted(with: [IndexPath()])
                        } else {
                            self.delegate?.onFetchCompleted(with: .none)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isFetchInProgress = false
                        self.delegate?.onFetchFailed(with: error.localizedDescription)
                    }
                }
            }
        }

    }
    
    
    func notificationDidView(id: Int, indexPath: IndexPath) {
        let parameters = NotificationViewBody(notificationID: id, viewedAll: false)
        client.empty(service: .viewNotification(params: parameters)) { isSuccess in
            DispatchQueue.main.async {
                if isSuccess {
                    if let index = self.data.firstIndex(where: {$0.notificationID == id}) {
                        self.data[index].viewed = true
                        self.unviewedCount -= 1
                        self.delegate?.notificationDidRead(for: indexPath)
                    }
                } else {
                    MessageView.sharedInstance.showOnViewWithError("Упс, ошибка сервера(")
                }
            }
        }
    }
    
    
    func allnotificationsDidView() {
        let parameters = NotificationViewBody(notificationID: nil, viewedAll: true)
        client.empty(service: .viewNotification(params: parameters)) { isSuccess in
            if isSuccess {
                DispatchQueue.main.async {
                    self.removeAllData()
                    self.fetchData()
                }
            } else {
                MessageView.sharedInstance.showOnViewWithError("Упс, ошибка сервера(")
            }
        }
    }
    
//    private func calculateIndexPathsToReload(from newModerators: [NotificationEntity]) -> [IndexPath] {
//        let startIndex = data.count - newModerators.count
//        let endIndex = startIndex + newModerators.count
//        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
//    }
    
}
