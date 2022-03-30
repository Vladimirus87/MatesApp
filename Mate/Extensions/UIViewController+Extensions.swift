//
//  UIViewController+Extensions.swift
//  Mate
//
//  Created by Vladimirus on 21.12.2021.
//

import UIKit

extension UIViewController {
    static func fromStoryboard(_ type: UIStoryboard.StoryboardType = .initial) -> Self {
        guard let vc = type.storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? Self else {
            fatalError()
        }
        return vc
    }
    

    var isFromCardVC: Bool {
        return parent?.restorationIdentifier == "CardNavigationVC"
    }

    
    func statusBarBackColor(color: UIColor = .white) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarFrame = window?.windowScene?.statusBarManager?.statusBarFrame
        
        let statusBarView = UIView(frame: statusBarFrame!)
        self.view.addSubview(statusBarView)
        statusBarView.backgroundColor = color
    }
    
    
    func fieldAlert(completion: @escaping (String)->()) {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Добавить", style: .default) { [unowned ac] _ in
            let field = ac.textFields![0]
            if let text = field.text, text.trimmingCharacters(in: .whitespaces).count > 0 {
                completion(text)
            }
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        ac.addAction(submitAction)
        ac.addAction(cancel)

        present(ac, animated: true)
    }
    
    func startAnimating(centerYAnchor: CGFloat = 0) {
        let backAnimationView = UIView()
        backAnimationView.backgroundColor = .white
        backAnimationView.layer.cornerRadius = 6
        backAnimationView.layer.masksToBounds = true
        backAnimationView.simpleShadow()
        backAnimationView.restorationIdentifier = "loadingView"
        view.addSubview(backAnimationView)
        view.bringSubviewToFront(backAnimationView)
        backAnimationView.translatesAutoresizingMaskIntoConstraints = false
        backAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: centerYAnchor).isActive = true
        backAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backAnimationView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        backAnimationView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let animateLoading = UIActivityIndicatorView(style: .medium)
        animateLoading.color = .gray
        backAnimationView.addSubview(animateLoading)
        
        animateLoading.translatesAutoresizingMaskIntoConstraints = false
        animateLoading.centerYAnchor.constraint(equalTo: backAnimationView.centerYAnchor).isActive = true
        animateLoading.centerXAnchor.constraint(equalTo: backAnimationView.centerXAnchor).isActive = true
//        animateLoading.restorationIdentifier = "loadingView"
        animateLoading.startAnimating()
    }
    
    func stopAnimating() {
        for item in view.subviews
        where item.restorationIdentifier == "loadingView" {
            UIView.animate(withDuration: 0.3, animations: {
                item.alpha = 0
            }) { (_) in
                item.removeFromSuperview()
            }
        }
    }
    
    func addTitleLabel(_ text: String?, color: UIColor = .black) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.font = UIFont.bold(ofSize: 21)
        label.minimumScaleFactor = 0.6
        label.textAlignment = .center
        label.textColor = color
        label.text = text
        self.navigationItem.titleView = label
        print(self.navigationItem.titleView)
    }
    
}


extension UIViewController: UIPopoverPresentationControllerDelegate {

    func openTablePop(data: [PopupMD],
                      sourceView: UIView,
                      completion: ((PopupMD)->())?) {
        
        let popW: CGFloat = UIScreen.main.bounds.width - 40
        let popH: CGFloat = CGFloat(data.count) * NotepadAlertTableVC.cellHeight

        let destVC = NotepadAlertTableVC(nibName: "NotepadAlertTableVC", bundle: nil)

        destVC.alertData = data
        destVC.choosedAction = completion
        destVC.modalPresentationStyle = .popover
        
        let popOverVC = destVC.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView = sourceView.superview
        popOverVC?.sourceRect = sourceView.frame
        popOverVC?.permittedArrowDirections = [.down, .up]
        
        destVC.preferredContentSize = CGSize(width: popW, height: popH)
        self.present(destVC, animated: true)
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}





extension UIViewController {
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}
