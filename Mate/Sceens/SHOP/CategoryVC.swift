//
//  CategoryVC.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit

class CategoryVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showButton: DesignableButton!

    var choosedCategory: (([Category])->())?
    var startSelectionCategories: [Category] = []
    
    private let cellIdentifier = "CategoryCell"
   
    private lazy var selectedIPs = [IndexPath]()
    
    private var categories: [Category] {
        return AccessService.shared.productCategories ?? []
    }
    
    private var choosedCategories: [Category] {
        let choosedIndexes = selectedIPs.map({$0.row})
        let _categories = categories.filter { element in
            return choosedIndexes.contains(categories.firstIndex(of: element)!)
        }
        return _categories
    }
    
    private var totalChoosedProducts: Int! {
        didSet {
            showButton.setTitle("Показать \(totalChoosedProducts!)", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllNibs()
        uiSettings()
        addStartSelectionIPs()
        updateCounts()
    }
    
    private func initAllNibs() {
        tableView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }

    private func uiSettings() {
        title = "Категории"
        
        // add UIBarButtonItem
        let button = UIBarButtonItem(title: "Сбросить", style: .plain, target: self, action: #selector(self.clear))
        self.navigationItem.rightBarButtonItem  = button
    }
    
    private func addStartSelectionIPs() {
        let indexes = startSelectionCategories.compactMap({ categories.firstIndex(of: $0) })
        selectedIPs = indexes.map({IndexPath(row: Int($0), section: 0)})
    }

    @objc func clear() {
        selectedIPs = []
        tableView.reloadData()
        updateCounts()
    }

    @IBAction func showButtonPressed(_ sender: Any) {
        choosedCategory?(choosedCategories)
        navigationController?.popViewController(animated: true)
    }
}


extension CategoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CategoryCell
        let category = categories[indexPath.row]
        cell.updateCategoryData(category: category, isSel: selectedIPs.contains(indexPath))
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        if let index = selectedIPs.firstIndex(of: indexPath) {
            selectedIPs.remove(at: index)
            if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
                cell.updateCategoryData(category: category, isSel: false)
            }
        } else {
            selectedIPs.append(indexPath)
            if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
                cell.updateCategoryData(category: category, isSel: true)
            }
        }
        updateCounts()
    }
    
    
    private func updateCounts() {
        
        guard !selectedIPs.isEmpty else {
            totalChoosedProducts = categories
                .compactMap({$0.products})
                .reduce(0, +)
            return
        }
        
        totalChoosedProducts = choosedCategories
            .compactMap({$0.products})
            .reduce(0, +)
    }
    
}


extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}
