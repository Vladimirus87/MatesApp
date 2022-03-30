//
//  AboutCompanyVC.swift
//  Mate
//
//  Created by Vladimirus on 23.12.2021.
//

import UIKit

class AboutCompanyVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let cellIdentifier = "CategoryCell"
    
    private lazy var queue = DispatchQueue(label: "AboutCompanyFetchQueue", attributes: .concurrent)
    
    private lazy var networkManager = NetworkManager<UserProvider>()

    private var notesData = NotesCategories()
    
    private let minimumRowsShow: Int = 0
    
    func category(for section: Int) -> NotesCategory {
        return notesData[section]
    }
    
    func note(for indexPath: IndexPath) -> Note? {
        return notesData[indexPath.section].notes?[indexPath.row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAllNibs()
        uiSettings()
        fetchNotesData()
    }

    private func uiSettings() {
        title = "О компании"
        navigationItem.backButtonTitle = ""
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
    

    private func fetchNotesData() {
        startAnimating()
        queue.async {
            self.networkManager.request(service: .getNotes, decodable: NotesCategories.self, completion: { result in
                DispatchQueue.main.async {
                    self.stopAnimating()
                    switch result {
                    case .success(let notesCategories):
                        updateMainData(with: notesCategories)
                    case .failure(let error):
                        print("error", error)
                        MessageView.sharedInstance.showError(error)
                    }
                }
            })
        }
        
        func updateMainData(with notesCategories: NotesCategories) {
            notesData = notesCategories
            tableView.reloadData()
        }
    }
    
}


extension AboutCompanyVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return notesData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = category(for: section)
        let notesCount = category.notes?.count ?? 0
        let isCollapsed = category.isCollapsed
        
        return notesCount <= minimumRowsShow ? notesCount : (isCollapsed ? notesCount : minimumRowsShow)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = note(for: indexPath)

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CategoryCell
        cell.updateNote(note)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let category = category(for: section)

        let header: SeeMoreFooter = UIView.fromNib()
        header.updateData(with: category)
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = note(for: indexPath)

        let vc = CompanyDetailVC.fromStoryboard(.account)
        vc.note = note
        navigationController?.show(vc, sender: nil)
    }
    
}

extension AboutCompanyVC: SeeMoreHeaderDelegate {
    func seeMore(for category: NotesCategory) {
        
        guard let section = notesData.firstIndex(of: category) else { return }
        
        let isCollapsed = category.isCollapsed
        let collapseUpDown = !isCollapsed
        
        notesData[section].isCollapsed = collapseUpDown
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        
    }
    
    
    
}
