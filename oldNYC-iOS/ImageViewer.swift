//
//  ImageViewer.swift
//  Money
//
//  Created by Kristian Angyal on 06/10/2015.
//  Copyright © 2015 Mail Online. All rights reserved.
//

import UIKit
import AVFoundation

/*
 
 Features:
 
 - double tap to toggle betweeen Aspect Fit & Aspect Fill zoom factor
 - manual pinch to zoom up to approx. 4x the size of full-sized image
 - rotation support
 - swipe to dismiss
 - initiation and completion blocks to support a case where the original image node should be hidden or unhidden alongside show and dismiss animations
 
 Usage:
 
 - Initialize ImageViewer, set optional initiation and completion blocks, and present by calling "presentImageViewer".
 
 How it works:
 
 - Gets presented modally via convenience UIViewControler extension, using custom modal presentation that is enforced internally.
 - Displays itself in full screen (nothing is visible at that point, but it's there, trust me...)
 - Makes a screenshot of the displaced view that can be any UIView (or subclass) really, but UIImageView is the most probable choice.
 - Puts this screenshot into a new UIImageView and matches its position and size to the displaced view.
 - Sets the target size and position for the UIImageView to aspectFit size and centered while kicking in the black overlay.
 - Animates the image view into the scroll view (that serves as zooming canvas) and reaches final position and size.
 - Immediately tries to get a full-sized version of the image from imageProvider.
 - If successful, replaces the screenshot in the image view with probably a higher-res image.
 - Gets dismissed either via Close button, or via "swipe up/down" gesture.
 - While being "closed", image is animated back to it's "original" position which is a rect that matches to the displaced view's position
 which overall gives us the illusion of the UI element returning to its original place.
 
 */

public final class ImageViewer: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
    /// UI
    fileprivate var scrollView: UIScrollView!
    fileprivate var overlayView: UIView!
    fileprivate var closeButton: UIButton!
    fileprivate var detailButton: UIButton!
    fileprivate var shareButton: UIButton!
    fileprivate var imageView = UIImageView()
    
    fileprivate let displacedView: UIView
    fileprivate var applicationWindow: UIWindow? {
        return UIApplication.shared.delegate?.window?.flatMap { $0 }
    }
    
    /// LOCAL STATE
    fileprivate var parentViewFrameInOurCoordinateSystem = CGRect.zero
    fileprivate var isAnimating = false
    fileprivate var shouldRotate = false
    fileprivate var isSwipingToDismiss = false
    fileprivate var dynamicTransparencyActive = false
    fileprivate let imageProvider: ImageProvider
    
    /// LOCAL CONFIG
    fileprivate let configuration: ImageViewerConfiguration
    fileprivate var initialCloseButtonOrigin = CGPoint.zero
    fileprivate var closeButtonSize = CGSize(width: 50, height: 50)
    fileprivate let closeButtonPadding         = 0.0
    fileprivate var detailButtonSize = CGSize(width: 50, height: 50)
    fileprivate let detailButtonPadding         = 0.0
    fileprivate var shareButtonSize = CGSize(width: 50, height: 50)
    fileprivate let shareButtonPadding         = 0.0
    fileprivate let showDuration               = 2.0
    fileprivate let dismissDuration            = 0.0
    fileprivate let showCloseButtonDuration    = 0.2
    fileprivate let hideCloseButtonDuration    = 0.05
    fileprivate let showDetailButtonDuration    = 0.2
    fileprivate let hideDetailButtonDuration    = 0.05
    fileprivate let showShareButtonDuration    = 0.2
    fileprivate let hideShareButtonDuration    = 0.05
    fileprivate let zoomDuration               = 0.2
    fileprivate let thresholdVelocity: CGFloat = 1000 // Based on UX experiments
    fileprivate let cutOffVelocity: CGFloat = 1000000 // we need some sufficiently large number, nobody can swipe faster then that
    /// TRANSITIONS
    fileprivate let presentTransition: ImageViewerPresentTransition
    fileprivate let dismissTransition: ImageViewerDismissTransition
    fileprivate let swipeToDismissTransition: ImageViewerSwipeToDismissTransition
    
    /// LIFE CYCLE BLOCKS
    
    /// Executed right before the image animation into its final position starts.
    public var showInitiationBlock: ((Void) -> Void)?
    /// Executed as the last step after all the show animations.
    public var showCompletionBlock: ((Void) -> Void)?
    /// Executed as the first step before the button's close action starts.
    public var closeButtonActionInitiationBlock: ((Void) -> Void)?
    /// Executed as the last step for close button's close action.
    public var closeButtonActionCompletionBlock: ((Void) -> Void)?
    /// Executed as the first step before the button's detail action starts.
    public var detailButtonActionInitiationBlock: ((Void) -> Void)?
    /// Executed as the last step for detail button's close action.
    public var detailButtonActionCompletionBlock: ((Void) -> Void)?
    /// Executed as the first step before the button's detail action starts.
    public var shareButtonActionInitiationBlock: ((Void) -> Void)?
    /// Executed as the last step for detail button's close action.
    public var shareButtonActionCompletionBlock: ((Void) -> Void)?
    /// Executed as the first step for swipe to dismiss action.
    public var swipeToDismissInitiationBlock: ((Void) -> Void)?
    /// Executed as the last step for swipe to dismiss action.
    public var swipeToDismissCompletionBlock: ((Void) -> Void)?
    /// Executed as the last step when the ImageViewer is dismissed (either via the close button, or swipe)
    public var dismissCompletionBlock: ((Void) -> Void)?
    
    /// INTERACTIONS
    fileprivate let doubleTapRecognizer = UITapGestureRecognizer()
    fileprivate let panGestureRecognizer = UIPanGestureRecognizer()
    
    // MARK: - Deinit
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // MARK: - Initializers
    
    public init(imageProvider: ImageProvider, configuration: ImageViewerConfiguration, displacedView: UIView) {
        
        self.imageProvider = imageProvider
        self.configuration = configuration
        self.displacedView = displacedView
        
        self.presentTransition = ImageViewerPresentTransition(duration: showDuration)
        self.dismissTransition = ImageViewerDismissTransition(duration: dismissDuration)
        self.swipeToDismissTransition = ImageViewerSwipeToDismissTransition()
        
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .custom
        extendedLayoutIncludesOpaqueBars = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    fileprivate func configureCloseButton() {
        
        let closeButtonAssets = configuration.closeButtonAssets
        
        closeButton.setImage(closeButtonAssets.normal, for: UIControlState())
        closeButton.setImage(closeButtonAssets.highlighted, for: UIControlState.highlighted)
        closeButton.alpha = 0.0
    }
    
    fileprivate func configureDetailButton() {
        
        let detailButtonAssets = configuration.detailButtonAssets
        
        detailButton.setImage(detailButtonAssets.normal, for: UIControlState())
        detailButton.alpha = 0.0
    }
    
    fileprivate func configureShareButton() {
        
        let shareButtonAssets = configuration.shareButtonAssets
        
        shareButton.setImage(shareButtonAssets.normal, for: UIControlState())
        shareButton.alpha = 0.0
    }
    
    fileprivate func configureGestureRecognizers() {
        
        doubleTapRecognizer.addTarget(self, action: #selector(ImageViewer.scrollViewDidDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        panGestureRecognizer.addTarget(self, action: #selector(ImageViewer.scrollViewDidPan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    fileprivate func configureImageView() {
        
        parentViewFrameInOurCoordinateSystem = applicationWindow!.convert(displacedView.bounds, from: displacedView).integral
        
        imageView.frame = parentViewFrameInOurCoordinateSystem
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.image = screenshotFromView(displacedView)
    }
    
    fileprivate func configureScrollView() {
        
        scrollView.decelerationRate = 0.5
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint.zero
        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = 1
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // MARK: - View Lifecycle
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        shouldRotate = true
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let originX = -view.bounds.width
        let originY = -view.bounds.height
        
        let width = view.bounds.width * 4
        let height = view.bounds.height * 4
        
        overlayView.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: width, height: height))
        
        closeButton.frame = CGRect(origin: CGPoint(x: view.bounds.size.width - CGFloat(closeButtonPadding) - closeButtonSize.width, y: CGFloat(closeButtonPadding)), size: closeButtonSize)
        
        detailButton.frame = CGRect(origin: CGPoint(x: view.bounds.size.width - CGFloat(detailButtonPadding) - detailButtonSize.width, y: CGFloat(detailButtonPadding)), size: detailButtonSize)
        
        shareButton.frame = CGRect(origin: CGPoint(x: view.bounds.size.width - CGFloat(shareButtonPadding) - shareButtonSize.width, y: CGFloat(shareButtonPadding)), size: shareButtonSize)
        
        if shouldRotate {
            shouldRotate = false
            rotate()
        }
    }
    
    public override func loadView() {
        super.loadView()
        
        scrollView = UIScrollView(frame: CGRect.zero)
        overlayView = UIView(frame: CGRect.zero)
        closeButton = UIButton(frame: CGRect.zero)
        detailButton = UIButton(frame: CGRect.zero)
        shareButton = UIButton(frame: CGRect.zero)
        
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.autoresizingMask = UIViewAutoresizing()
        
        view.addSubview(overlayView)
        view.addSubview(scrollView)
        view.addSubview(closeButton)
        view.addSubview(detailButton)
        view.addSubview(shareButton)
        
        scrollView.delegate = self
        closeButton.addTarget(self, action: #selector(ImageViewer.close(_:)), for: .touchUpInside)
        detailButton.addTarget(self, action: #selector(ImageViewer.detail(_:)), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(ImageViewer.action(_:)), for: .touchUpInside)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCloseButton()
        configureDetailButton()
        configureShareButton()
        configureImageView()
        configureScrollView()
    }
    
    // MARK: - Transitioning Delegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return isSwipingToDismiss ? swipeToDismissTransition : dismissTransition
    }
    
    // MARK: - Animations
    
    func close(_ sender: AnyObject) {
        presentingViewController?.dismiss(animated: false, completion: nil)
    }
    func detail(_ sender: AnyObject) {
        let detailsActivityViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        detailsActivityViewController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "View Item in NYPL Collection", style: .default) { UIAlertAction in
            let webV:UIWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            webV.loadRequest(URLRequest(url: URL(string: "http://www.jogendra.com")!))
            webV.tag = 69
            self.view.addSubview(webV)
            let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
            navBar.tag = 70
            self.view.addSubview(navBar);
            let navItem = UINavigationItem(title: "");
            let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(GalleryViewController.removeWebView));
            navItem.rightBarButtonItem = doneItem;
            navBar.setItems([navItem], animated: false);
        }
        detailsActivityViewController.addAction(OKAction)
        self.present(detailsActivityViewController, animated: true, completion: nil)
    }
    
    func action(_ sender: AnyObject){
        let image = self.imageView.image
        let shareActivityViewController = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
        self.present(shareActivityViewController, animated: true, completion: nil)
    }
    
    func rotate() {
        guard UIDevice.current.orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        UIView.animate(withDuration: hideCloseButtonDuration, animations: { self.closeButton.alpha = 0.0 })
        UIView.animate(withDuration: hideDetailButtonDuration, animations: { self.detailButton.alpha = 0.0 })
        UIView.animate(withDuration: hideShareButtonDuration, animations: { self.shareButton.alpha = 0.0 })
        
        let aspectFitSize = aspectFitContentSize(forBoundingSize: rotationAdjustedBounds().size, contentSize: displacedView.frame.size)
        UIView.animate(withDuration: showDuration, animations: { () -> Void in
            if isPortraitOnly() {
                self.view.transform = rotationTransform()
            }
            self.view.bounds = rotationAdjustedBounds()
            self.imageView.bounds = CGRect(origin: CGPoint.zero, size: aspectFitSize)
            self.imageView.center = self.scrollView.center
            self.scrollView.contentSize = self.imageView.bounds.size
            self.scrollView.setZoomScale(1.0, animated: false)
            
        }, completion: { (finished) -> Void in
            if (finished) {
                self.isAnimating = false
                self.scrollView.maximumZoomScale = maximumZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: self.imageView.bounds.size)
                UIView.animate(withDuration: self.showCloseButtonDuration, animations: { self.closeButton.alpha = 1.0 })
                UIView.animate(withDuration: self.showDetailButtonDuration, animations: { self.detailButton.alpha = 1.0 })
                UIView.animate(withDuration: self.showShareButtonDuration, animations: { self.shareButton.alpha = 1.0 })
            }
        }) 
    }
    
    func showAnimation(_ duration: TimeInterval, completion: ((Bool) -> Void)?) {
        
        guard isAnimating == false else { return }
        
        isAnimating = true
        showInitiationBlock?()
        displacedView.isHidden = true
        
        overlayView.alpha = 0.0
        overlayView.backgroundColor = UIColor.black
        
        UIView.animate(withDuration: duration, animations: {
            self.view.transform = rotationTransform()
            self.overlayView.alpha = 1.0
            self.view.bounds = rotationAdjustedBounds()
            let aspectFitSize = aspectFitContentSize(forBoundingSize: rotationAdjustedBounds().size, contentSize: self.configuration.imageSize)
            self.imageView.bounds = CGRect(origin: CGPoint.zero, size: aspectFitSize)
            self.imageView.center = rotationAdjustedCenter(self.view)
            self.scrollView.contentSize = self.imageView.bounds.size
            
        }, completion: { (finished) -> Void in
            completion?(finished)
            
            if finished {
                if isPortraitOnly() {
                    NotificationCenter.default.addObserver(self, selector: #selector(ImageViewer.rotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
                }
                self.applicationWindow!.windowLevel = UIWindowLevelStatusBar + 1
                
                self.scrollView.addSubview(self.imageView)
                self.imageProvider.provideImage { [weak self] image in
                    self?.imageView.image = image
                }
                
                self.isAnimating = false
                self.scrollView.maximumZoomScale = maximumZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: self.imageView.bounds.size)
                UIView.animate(withDuration: self.showCloseButtonDuration, animations: { self.closeButton.alpha = 1.0 })
                UIView.animate(withDuration: self.showDetailButtonDuration, animations: { self.detailButton.alpha = 1.0 })
                UIView.animate(withDuration: self.showShareButtonDuration, animations: { self.shareButton.alpha = 1.0 })
                self.configureGestureRecognizers()
                self.showCompletionBlock?()
                self.displacedView.isHidden = false
            }
        }) 
    }
    
    func closeAnimation(_ duration: TimeInterval, completion: ((Bool) -> Void)?) {
        
        guard (self.isAnimating == false) else { return }
        isAnimating = true
        closeButtonActionInitiationBlock?()
        displacedView.isHidden = true
        
        UIView.animate(withDuration: hideCloseButtonDuration, animations: { self.closeButton.alpha = 0.0 })
        
        UIView.animate(withDuration: duration, animations: {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            self.overlayView.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.detailButton.alpha = 0.0
            self.shareButton.alpha = 0.0
            self.view.transform = CGAffineTransform.identity
            self.view.bounds = (self.applicationWindow?.bounds)!
            self.imageView.frame = self.applicationWindow!.convert(self.displacedView.bounds, from: self.displacedView).integral
            
        }, completion: { (finished) -> Void in
            completion?(finished)
            if finished {
                NotificationCenter.default.removeObserver(self)
                self.applicationWindow!.windowLevel = UIWindowLevelNormal
                
                self.displacedView.isHidden = false
                self.isAnimating = false
                
                self.closeButtonActionCompletionBlock?()
                self.detailButtonActionCompletionBlock?()
                self.shareButtonActionCompletionBlock?()
                self.dismissCompletionBlock?()
            }
        }) 
    }
    
    func swipeToDismissAnimation(withVerticalTouchPoint verticalTouchPoint: CGFloat,  targetOffset: CGFloat, verticalVelocity: CGFloat, completion: ((Bool) -> Void)?) {
        
        /// In units of "vertical velocity". for example if we have a vertical velocity of 50 units (which are points really) per second
        /// and the distance to travel is 175 units, then our spring velocity is 3.5. I.e. we will travel 3.5 units in 1 second.
        let springVelocity = fabs(verticalVelocity / (targetOffset - verticalTouchPoint))
        
        /// How much time it will take to travel the remaining distance given the above speed.
        let expectedDuration = TimeInterval( fabs(targetOffset - verticalTouchPoint) / fabs(verticalVelocity))
        
        UIView.animate(withDuration: expectedDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.scrollView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: false)
            
            }, completion: { (finished) -> Void in
                completion?(finished)
                
                if finished {
                    NotificationCenter.default.removeObserver(self)
                    self.view.transform = CGAffineTransform.identity
                    self.view.bounds = (self.applicationWindow?.bounds)!
                    self.imageView.frame = self.parentViewFrameInOurCoordinateSystem
                    
                    self.overlayView.alpha = 0.0
                    self.closeButton.alpha = 0.0
                    self.detailButton.alpha = 0.0
                    self.shareButton.alpha = 0.0
                    self.isAnimating = false
                    self.isSwipingToDismiss = false
                    self.dynamicTransparencyActive = false
                    self.swipeToDismissCompletionBlock?()
                    self.dismissCompletionBlock?()
                }
        })
    }
    
    fileprivate func swipeToDismissCanceledAnimation() {
        
        UIView.animate(withDuration: zoomDuration, animations: { () -> Void in
            
            self.scrollView.setContentOffset(CGPoint.zero, animated: false)
            
            }, completion: { (finished) -> Void in
                
                if finished {
                    self.applicationWindow!.windowLevel = UIWindowLevelStatusBar + 1
                    
                    self.isAnimating = false
                    self.isSwipingToDismiss = false
                    self.dynamicTransparencyActive = false
                }
        })
    }
    
    // MARK: - Interaction Handling
    
    func scrollViewDidDoubleTap(_ recognizer: UITapGestureRecognizer) {
        
        let touchPoint = recognizer.location(ofTouch: 0, in: imageView)
        
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: imageView.bounds.size)
        
        if (scrollView.zoomScale == 1.0 || scrollView.zoomScale > aspectFillScale) {
            
            let zoomingRect = zoomRect(ForScrollView: scrollView, scale: aspectFillScale, center: touchPoint)
            
            UIView.animate(withDuration: zoomDuration, animations: {
                
                self.scrollView.zoom(to: zoomingRect, animated: false)
            })
        }
        else  {
            UIView.animate(withDuration: zoomDuration, animations: {
                
                self.scrollView.setZoomScale(1.0, animated: false)
            })
        }
    }
    
    func scrollViewDidPan(_ recognizer: UIPanGestureRecognizer) {
        
        guard scrollView.zoomScale == scrollView.minimumZoomScale else { return }
        
        if isSwipingToDismiss == false {
            swipeToDismissInitiationBlock?()
            displacedView.isHidden = false
        }
        isSwipingToDismiss = true
        dynamicTransparencyActive = true
        
        let targetOffsetToReachEdge =  (view.bounds.height / 2) + (imageView.bounds.height / 2)
        let lastTouchPoint = recognizer.translation(in: view)
        let verticalVelocity = recognizer.velocity(in: view).y
        
        switch recognizer.state {
            
        case .began:
            applicationWindow!.windowLevel = UIWindowLevelNormal
            fallthrough
            
        case .changed:
            scrollView.setContentOffset(CGPoint(x: 0, y: -lastTouchPoint.y), animated: false)
            
        case .ended:
            handleSwipeToDismissEnded(verticalVelocity, lastTouchPoint: lastTouchPoint, targetOffset: targetOffsetToReachEdge)
            
        default:
            break
        }
    }
    
    func handleSwipeToDismissEnded(_ verticalVelocity: CGFloat, lastTouchPoint: CGPoint, targetOffset: CGFloat) {
        
        let velocity = abs(verticalVelocity)
        
        switch velocity {
            
        case 0 ..< thresholdVelocity:
            
            swipeToDismissCanceledAnimation()
            
        case thresholdVelocity ... cutOffVelocity:
        
            let offset = (verticalVelocity > 0) ? -targetOffset : targetOffset
            let touchPoint = (verticalVelocity > 0) ? -lastTouchPoint.y : lastTouchPoint.y
            
            swipeToDismissTransition.setParameters(touchPoint, targetOffset: offset, verticalVelocity: verticalVelocity)
            presentingViewController?.dismiss(animated: true, completion: nil)
            
        default: break
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }
    
    // MARK: - KVO
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        if (dynamicTransparencyActive == true && keyPath == "contentOffset") {
            
            let transparencyMultiplier: CGFloat = 10
            let velocityMultiplier: CGFloat = 300
            
            let distanceToEdge = (scrollView.bounds.height / 2) + (imageView.bounds.height / 2)
            
            overlayView.alpha = 1 - fabs(scrollView.contentOffset.y / distanceToEdge)
            closeButton.alpha = 1 - fabs(scrollView.contentOffset.y / distanceToEdge) * transparencyMultiplier
            
            let newY = CGFloat(closeButtonPadding) - abs(scrollView.contentOffset.y / distanceToEdge) * velocityMultiplier
            closeButton.frame = CGRect(origin: CGPoint(x: closeButton.frame.origin.x, y: newY), size: closeButton.frame.size)
            
            detailButton.alpha = 1 - fabs(scrollView.contentOffset.y / distanceToEdge) * transparencyMultiplier
            
            let newDetailY = CGFloat(detailButtonPadding) - abs(scrollView.contentOffset.y / distanceToEdge) * velocityMultiplier
            detailButton.frame = CGRect(origin: CGPoint(x: detailButton.frame.origin.x, y: newDetailY), size: detailButton.frame.size)
            
            shareButton.alpha = 1 - fabs(scrollView.contentOffset.y / distanceToEdge) * transparencyMultiplier
            
            let newShareY = CGFloat(shareButtonPadding) - abs(scrollView.contentOffset.y / distanceToEdge) * velocityMultiplier
            shareButton.frame = CGRect(origin: CGPoint(x: shareButton.frame.origin.x, y: newShareY), size: shareButton.frame.size)
        }
    }
}
