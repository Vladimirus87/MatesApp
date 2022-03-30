//
//  PhotoDetaiVC.swift
//  Prokat 2.0
//
//  Created by Vladimirus on 30.04.2021.
//

import UIKit

class PhotoDetaiVC: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    
    var image: UIImage?
    
    private var imageScrollView: ImageScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView = ImageScrollView(frame: view.bounds)
        view.addSubview(imageScrollView)
        setupImageScrollView()
        self.imageScrollView.set(image: image ?? #imageLiteral(resourceName: "no_image"))
        view.bringSubviewToFront(closeButton)
    }
 
    func setupImageScrollView() {
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
