//
//  EnterService.swift
//  Park Share
//
//  Created by Vladimirus on 16.12.2020.
//

import UIKit
import Firebase

class EnterService {
    static func chooseStartController(animated: Bool) {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let _user = user {
                _user.getIDToken(completion: { token, error in
                    
                    if let error = error {
                        MessageView.sharedInstance.showError(error)
                        return
                    }
                    
                    if let _token = token {
                        let queue = DispatchQueue(label: "EnterService", attributes: .concurrent)
                        queue.async {
                            fetchUserData(with: _token)
                        }
                    } else {
                        showAuthVC()
                    }
                })
            } else {
                showAuthVC()
            }
        }
        
        func fetchUserData(with token: String) {
            AccessService.shared.token = token
            let networkManager = NetworkManager<UserProvider>()
            networkManager.request(service: .getUserInfo, decodable: User.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let userMD):
                        if let _ = userMD.name {
                            AccessService.shared.user = userMD
                            showMainVC()
                        } else {
                            showAddInfoVC()
                        }
                    case .failure(let error):
                        MessageView.sharedInstance.showError(error)
                        showAuthVC()
                    }
                }
                
            }
            
        }
        
        func showAuthVC() {
            let rootVC = UIStoryboard.StoryboardType.auth.storyboard
                .instantiateViewController(withIdentifier: "AuthStartNavVC")
            showVC(animated: animated, vc: rootVC)
        }
        
        func showAddInfoVC() {
            let rootVC = UIStoryboard.StoryboardType.auth.storyboard
                .instantiateViewController(withIdentifier: "AddInfoNavVC")
            showVC(animated: animated, vc: rootVC)
        }
        
        func showMainVC() {
            let rootVC = UIStoryboard.StoryboardType.main.storyboard
                .instantiateInitialViewController()!
            showVC(animated: animated, vc: rootVC)
        }
    
        func showVC(animated: Bool = true, vc: UIViewController) {
            let keyWindow = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
            
            
            
            if animated {
                let options: UIView.AnimationOptions = .transitionFlipFromLeft
                let duration: TimeInterval = 0.4
                
                UIView.transition(with: keyWindow!, duration: duration, options: options, animations: {
                    keyWindow!.rootViewController = vc
                }, completion:
                                    { completed in })
            } else {
                keyWindow!.rootViewController = vc
            }
        }
    }
    
    
    static func logout() {
        do {
            try Auth.auth().signOut()
            EnterService.chooseStartController(animated: true)
        } catch (let error) {
            MessageView.sharedInstance.showError(error)
        }
        
    }
    
}



