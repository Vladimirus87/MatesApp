//
//  CardTransitionCoordinator.swift
//  Mate
//
//  Created by Vladimirus on 21.12.2021.
//

import UIKit

final class CardTransitionCoordinator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval
    private var operation = UINavigationController.Operation.push
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        animateTransition(from: fromViewController, to: toViewController, with: transitionContext)
    }
}

// MARK: - UINavigationControllerDelegate

extension CardTransitionCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.operation = operation
        
        if operation == .push {
            return self
        }
        
        return nil
    }
}


// MARK: - Animations

private extension CardTransitionCoordinator {
    func animateTransition(from fromViewController: UIViewController, to toViewController: UIViewController, with context: UIViewControllerContextTransitioning) {
        switch operation {
        case .push:
            guard
                let albumsViewController = fromViewController as? CardVC,
                let detailsViewController = toViewController as? CardDetaiVC
            else { return }
            
            presentViewController(detailsViewController, from: albumsViewController, with: context)
            
        case .pop:
            guard
                let detailsViewController = fromViewController as? CardDetaiVC,
                let albumsViewController = toViewController as? CardVC
            else { return }
            
            dismissViewController(detailsViewController, to: albumsViewController)
            
        default:
            break
        }
    }
    
    func presentViewController(_ toViewController: CardDetaiVC, from fromViewController: CardVC, with context: UIViewControllerContextTransitioning) {
        
        guard
            let cardHeaderView = fromViewController.cardView,
//            let albumCoverImageView = fromViewController.currentCell?.albumCoverImageView,
            let cardDetailHeaderView = toViewController.headerView
        else { return}
        
        toViewController.view.layoutIfNeeded()
        
        let containerView = context.containerView
        
        let snapshotContentView = UIView()
        snapshotContentView.backgroundColor = .red
        snapshotContentView.frame = containerView.convert(cardHeaderView.cardBackView.frame, from: cardHeaderView)
        snapshotContentView.layer.cornerRadius = cardHeaderView.cardBackView.layer.cornerRadius
        
//        let snapshotCardView = cardHeaderView.cardBackView
        
//        let snapshotAlbumCoverImageView = UIImageView()
//        snapshotAlbumCoverImageView.clipsToBounds = true
//        snapshotAlbumCoverImageView.contentMode = albumCoverImageView.contentMode
//        snapshotAlbumCoverImageView.image = albumCoverImageView.image
//        snapshotAlbumCoverImageView.layer.cornerRadius = albumCoverImageView.layer.cornerRadius
//        snapshotAlbumCoverImageView.frame = containerView.convert(albumCoverImageView.frame, from: cardHeaderView)
        
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshotContentView)
//        containerView.addSubview(snapshotAlbumCoverImageView)
        
        toViewController.view.isHidden = true
        
        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
            snapshotContentView.frame = containerView.convert(toViewController.view.frame, from: toViewController.view)
//            snapshotAlbumCoverImageView.frame = containerView.convert(cardDetailHeaderView.albumCoverImageView.frame, from: cardDetailHeaderView)
//            snapshotAlbumCoverImageView.layer.cornerRadius = 0
        }

        animator.addCompletion { position in
            toViewController.view.isHidden = false
//            snapshotAlbumCoverImageView.removeFromSuperview()
            snapshotContentView.removeFromSuperview()
            context.completeTransition(position == .end)
        }

        animator.startAnimation()
    }
    
    func dismissViewController(_ fromViewController: CardDetaiVC, to toViewController: CardVC) {
        
    }
}

extension NSObject {
    func copyObject<T:NSObject>() throws -> T? {
        let data = try NSKeyedArchiver.archivedData(withRootObject:self, requiringSecureCoding:false)
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
    }
}
