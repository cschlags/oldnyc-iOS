//
//  GalleryPresentTransition.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 02/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class GalleryPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let duration: TimeInterval
    fileprivate let displacedView: UIView
    var headerView: UIView?
    var footerView: UIView?
    var closeView: UIView?
    var detailView: UIView?
    var shareView: UIView?
    var completion: (() -> Void)?
    fileprivate let decorationViewsHidden: Bool
    
    init(duration: TimeInterval, displacedView: UIView , decorationViewsHidden: Bool) {
        
        self.duration = 0.0000000000000000001
        self.displacedView = displacedView
        self.decorationViewsHidden = decorationViewsHidden
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        /// Get the temporary container view that facilitates all the animations
        let transitionContainerView = transitionContext.containerView //Apple, Apple..
        
        /// Get the target controller's root view and add it to the scene
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        transitionContainerView.addSubview(toViewController.view)
        
        /// Make it align with scene geometry
        toViewController.view.frame = UIScreen.main.bounds
        
        /// Prepare transition of background from transparent to full black
        toViewController.view.backgroundColor = UIColor.black
        toViewController.view.alpha = 0.0
        
        if isPortraitOnly() {
            toViewController.view.transform = rotationTransform()
            toViewController.view.bounds = rotationAdjustedBounds()
        }
        
        /// Make a screenshot of displaced view so we can create our own animated view
        let screenshot = screenshotFromView(displacedView)
        
        /// Make the original displacedView hidden, we can give an illusion it is moving away from its parent view
        displacedView.isHidden = true
        
        /// Hide the gallery views
        headerView?.alpha = 0.0
        footerView?.alpha = 0.0
        closeView?.alpha = 0.0
        detailView?.alpha = 0.0
        shareView?.alpha = 0.0
        
        /// Translate coordinates of displaced view into our coordinate system (which is now the transition container view) so that we match the animation start position on device screen level
        let origin = transitionContainerView.convert(CGPoint.zero, from: displacedView)
        
        /// Create UIImageView with screenshot
        let animatedImageView = UIImageView()
        animatedImageView.bounds = displacedView.bounds
        animatedImageView.frame.origin = origin
        animatedImageView.image = screenshot
        
        /// Put it into the container
        transitionContainerView.addSubview(animatedImageView)
        
        UIView.animate(withDuration: self.duration, animations: { () -> Void in
            
            if isPortraitOnly() == true {
                animatedImageView.transform = rotationTransform()
            }
                /// Animate it into the center (with optionally rotating) - that basically includes changing the size and position
            
            //let boundingSize = rotationAdjustedBounds().size
            //let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: animatedImageView.bounds.size)
            
            //animatedImageView.bounds.size = aspectFitSize
            
            /// Transition the background to full black
            toViewController.view.alpha = 1.0
            
            }, completion: { [weak self] finished in
                
                animatedImageView.removeFromSuperview()
                transitionContext.completeTransition(finished)
//                self?.displacedView.hidden = false
                
                /// Unhide gallery views
                if self?.decorationViewsHidden == false {
                    
                    UIView.animate(withDuration: 0.0, animations: { [weak self] in
                        self?.headerView?.alpha = 1.0
                        self?.footerView?.alpha = 1.0
                        self?.closeView?.alpha = 1.0
                        self?.detailView?.alpha = 1.0
                        self?.shareView?.alpha = 1.0
                    })
                    
                }
            })
    }
    
    func animationEnded(_ transitionCompleted: Bool) {

        /// The expected closure here should handle unhiding whichever ImageController is selected as the first one to be shown in gallery
        if transitionCompleted {
            completion?()
        }
    }
}
