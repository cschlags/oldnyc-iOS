//
//  GalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final public class GalleryViewController : UIPageViewController, UIViewControllerTransitioningDelegate, ImageViewControllerDelegate  {
    
    /// UI
    private var closeButton: UIButton?
    private var detailButton: UIButton?
    private var shareButton: UIButton?
    /// You can set any UIView subclass here. If set, it will be integrated into view hierachy and laid out 
    /// following either the default pinning settings or settings from a custom configuration.
    public var headerView: UIView?
    /// Behaves the same way as header view above, the only difference is this one is pinned to the bottom.
    public var footerView: UIView?
    private var applicationWindow: UIWindow? {
        return UIApplication.sharedApplication().delegate?.window?.flatMap { $0 }
    }
    
    /// DATA
    private let imageProvider: ImageProvider
    private let displacedView: UIView
    private let imageCount: Int
    private let startIndex: Int
    
    private var galleryDatasource: GalleryViewControllerDatasource!
    private let fadeInHandler = ImageFadeInHandler()
    private var galleryPagingMode = GalleryPagingMode.Standard
    var currentIndex: Int
    private var isDecorationViewsHidden = false
    private var isAnimating = false
    
    /// LOCAL CONFIG
    private let configuration: GalleryConfiguration
    private var spinnerColor = UIColor.whiteColor()
    private var spinnerStyle = UIActivityIndicatorViewStyle.White
    private let presentTransitionDuration = 0.25
    private let dismissTransitionDuration = 1.00
    private let closeButtonPadding: CGFloat = 0.0
    private let detailButtonPadding: CGFloat = 0.0
    private let shareButtonPadding: CGFloat = 0.0
    private let headerViewMarginTop: CGFloat = 20
    private let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6
    private let toggleHeaderFooterAnimationDuration = 0.15
    private let closeAnimationDuration = 0.2
    private let rotationAnimationDuration = 0.2
    private var closeLayout = CloseButtonLayout.PinLeft(1,1)
    private var detailLayout = DetailButtonLayout.PinRight(1, 50)
    private var shareLayout = ShareButtonLayout.PinRight(1, 1)
    private var headerLayout = HeaderLayout.Center(15)
    private var footerLayout = FooterLayout.PinLeft(1, 1)
    private var statusBarHidden = true
    
    /// TRANSITIONS
    private let presentTransition: GalleryPresentTransition
    private let closeTransition: GalleryCloseTransition
    
    /// COMPLETION
    /// If set ,the block is executed right after the initial launc hanimations finish.
    public var launchedCompletion: (() -> Void)?
    /// If set, called everytime ANY animation stops in the page controller stops and the viewer passes a page index of the page that is currently on screen
    public var landedPageAtIndexCompletion: ((Int) -> Void)?
    /// If set, launched after all animations finish when the close button is pressed.
    public var closedCompletion: (() -> Void)?
    /// If set, launched after all animations finish when the swipe-to-dismiss (applies to all directions and cases) gesture is used.
    public var swipedToDismissCompletion: (() -> Void)?
    
    /// IMAGE VC FACTORY
    private var imageControllerFactory: ImageViewControllerFactory!
    
    // MARK: - VC Setup
    
    public init(imageProvider: ImageProvider, displacedView: UIView, imageCount: Int ,startIndex: Int, configuration: GalleryConfiguration = defaultGalleryConfiguration()) {
        
        self.imageProvider = imageProvider
        self.displacedView = displacedView
        self.imageCount = imageCount
        self.startIndex = startIndex
        self.currentIndex = startIndex
        self.configuration = configuration
        
        var dividerWidth: Float = 10
        
        for item in configuration {
            
            switch item {
                
            case .ImageDividerWidth(let width):             dividerWidth = Float(width)
            case .SpinnerStyle(let style):                  spinnerStyle = style
            case .SpinnerColor(let color):                  spinnerColor = color
            case .CloseButton(let button):                  closeButton = button
            case .DetailButton(let button):                 detailButton = button
            case .ShareButton(let button):                  shareButton = button
            case .PagingMode(let mode):                     galleryPagingMode = mode
            case .HeaderViewLayout(let layout):             headerLayout = layout
            case .FooterViewLayout(let layout):             footerLayout = layout
            case .CloseLayout(let layout):                  closeLayout = layout
            case .DetailLayout(let layout):                 detailLayout = layout
            case .ShareLayout(let layout):                  shareLayout = layout
            case .StatusBarHidden(let hidden):              statusBarHidden = hidden
            case .HideDecorationViewsOnLaunch(let hidden):  isDecorationViewsHidden = hidden
            default: break
            }
        }
        
        self.presentTransition = GalleryPresentTransition(duration: presentTransitionDuration, displacedView: self.displacedView , decorationViewsHidden: isDecorationViewsHidden)
        self.closeTransition = GalleryCloseTransition(duration: dismissTransitionDuration)
        
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(float: dividerWidth)])
        
        self.imageControllerFactory = ImageViewControllerFactory(imageProvider: imageProvider, displacedView: displacedView, imageCount: imageCount, startIndex: startIndex, configuration: configuration, fadeInHandler: fadeInHandler, delegate: self)
        
        /// Needs to be kept alive with strong reference
        self.galleryDatasource = GalleryViewControllerDatasource(imageControllerFactory: imageControllerFactory, imageCount: imageCount, galleryPagingMode: galleryPagingMode)
        self.dataSource = galleryDatasource
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .Custom
        self.extendedLayoutIncludesOpaqueBars = true
        self.applicationWindow?.windowLevel = (statusBarHidden) ? UIWindowLevelStatusBar + 1 : UIWindowLevelNormal
        
        configureInitialImageController()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GalleryViewController.rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        self.landedPageAtIndexCompletion?(self.currentIndex)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func applyOverlayView() -> UIView {
        
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.bounds.size = UIScreen.mainScreen().bounds.insetBy(dx: -UIScreen.mainScreen().bounds.width * 2, dy: -UIScreen.mainScreen().bounds.height * 2).size
        overlayView.center = self.view.boundsCenter
        self.presentingViewController?.view.addSubview(overlayView)
        
        return overlayView
    }
    
    // MARK: - Animations
    
    func rotate() {
        
        /// If the app supports rotation on global level, we don't need to rotate here manually because the rotation
        /// of key Window will rotate all app's content with it via affine transform and from the perspective of the
        /// gallery it is just a simple relayout. Allowing access to remaining code only makes sense if the app is 
        /// portrait only but we still want to support rotation inside the gallery.
        guard isPortraitOnly() else { return }
        
        guard UIDevice.currentDevice().orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        let overlayView = applyOverlayView()
        footerView?.hidden = true
        
        if UIDevice.currentDevice().orientation.isLandscape{
            let footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.height, height: 100)
            footerView?.frame = footerFrame
        }else if UIDevice.currentDevice().orientation.isPortrait{
            let footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100)
            footerView?.frame = footerFrame
//            footerView?.hidden = false
        }
        
        UIView.animateWithDuration(rotationAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self] () -> Void in
            
            self?.view.transform = rotationTransform()
            self?.view.bounds = rotationAdjustedBounds()
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
            
            })
        { [weak self] finished  in
            
            overlayView.removeFromSuperview()
            self?.isAnimating = false
        }
    }
    
    // MARK: - Configuration
    
    func configureInitialImageController() {
        
        let initialImageController = ImageViewController(imageProvider: imageProvider, configuration: configuration, imageCount: imageCount, displacedView: displacedView, startIndex: startIndex,  imageIndex: startIndex, showDisplacedImage: true, fadeInHandler: fadeInHandler, delegate: self)
        self.setViewControllers([initialImageController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        initialImageController.view.hidden = true
        
        self.presentTransition.completion = { [weak self] in
            initialImageController.view.hidden = false
            
            self?.launchedCompletion?()
        }
    }
    
    private func configureCloseButton() {
        
        closeButton?.addTarget(self, action: #selector(GalleryViewController.close), forControlEvents: .TouchUpInside)
    }
    
    func createViewHierarchy() {
        
        if let close = closeButton {
            
            self.view.addSubview(close)
        }
    }
    
    func configureHeaderView() {
        
        if let header = headerView {
            self.view.addSubview(header)
        }
    }
    
    func configureFooterView() {
        
        if let footer = footerView {
            self.view.addSubview(footer)
        }
    }
    
    private func configureDetailButton() {
        
        detailButton?.addTarget(self, action: #selector(GalleryViewController.detail), forControlEvents: .TouchUpInside)
    }
    
    func createDetailViewHierarchy() {
        
        if let detail = detailButton {
            
            self.view.addSubview(detail)
        }
    }
    
    private func configureShareButton() {
        
        shareButton?.addTarget(self, action: #selector(GalleryViewController.action), forControlEvents: .TouchUpInside)
    }
    
    func createShareViewHierarchy() {
        
        if let share = shareButton {
            
            self.view.addSubview(share)
        }
    }
    
    func configurePresentTransition() {
        
        self.presentTransition.headerView = self.headerView
        self.presentTransition.footerView = self.footerView
        self.presentTransition.closeView = self.closeButton
        self.presentTransition.detailView = self.detailButton
        self.presentTransition.shareView = self.shareButton
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeaderView()
        configureFooterView()
        configureCloseButton()
        configureDetailButton()
        configureShareButton()
        configurePresentTransition()
        createViewHierarchy()
        createDetailViewHierarchy()
        createShareViewHierarchy()
    }
    
    // MARK: - Layout
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutCloseButton()
        layoutDetailButton()
        layoutShareButton()
        layoutHeaderView()
        layoutFooterView()
    }
    
    func layoutCloseButton() {
        
        guard let close = closeButton else { return }
        
        switch closeLayout {
            
        case .PinRight(let marginTop, let marginRight):
            
            close.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
            close.frame.origin.x = self.view.bounds.size.width - marginRight - close.bounds.size.width
            close.frame.origin.y = marginTop
            
        case .PinLeft(let marginTop, let marginLeft):
            
            close.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
            close.frame.origin.x = marginLeft
            close.frame.origin.y = marginTop
        }
    }
    
    func layoutDetailButton() {
        
        guard let detail = detailButton else { return }
        
        switch detailLayout {
            
        case .PinRight(let marginTop, let marginRight):
            
            detail.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
            detail.frame.origin.x = self.view.bounds.size.width - marginRight - detail.bounds.size.width
            detail.frame.origin.y = marginTop
            
        case .PinLeft(let marginTop, let marginLeft):
            
            detail.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
            detail.frame.origin.x = marginLeft
            detail.frame.origin.y = marginTop
        }
    }
    
    func layoutShareButton() {
        
        guard let share = shareButton else { return }
        
        switch shareLayout {
            
        case .PinRight(let marginTop, let marginRight):
            
            share.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
            share.frame.origin.x = self.view.bounds.size.width - marginRight - share.bounds.size.width
            share.frame.origin.y = marginTop
            
        case .PinLeft(let marginTop, let marginLeft):
            
            share.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
            share.frame.origin.x = marginLeft
            share.frame.origin.y = marginTop
        }
    }
    
    func layoutHeaderView() {
        
        guard let header = headerView else { return }
        
        switch headerLayout {
            
        case .Center(let marginTop):
            
            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
            header.center = self.view.boundsCenter
            header.frame.origin.y = marginTop
            
        case .PinBoth(let marginTop, let marginLeft,let marginRight):
            
            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleWidth]
            header.bounds.size.width = self.view.bounds.width - marginLeft - marginRight
            header.sizeToFit()
            header.frame.origin = CGPoint(x: marginLeft, y: marginTop)
            
        case .PinLeft(let marginTop, let marginLeft):
            
            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
            header.frame.origin = CGPoint(x: marginLeft, y: marginTop)
            
        case .PinRight(let marginTop, let marginRight):
            
            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
            header.frame.origin = CGPoint(x: self.view.bounds.width - marginRight - header.bounds.width, y: marginTop)
        }
    }
    
    func layoutFooterView() {
        
        guard let footer = footerView else { return }
        
        switch footerLayout {
            
        case .Center(let marginBottom):
            
            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
            footer.center = self.view.boundsCenter
            footer.frame.origin.y = self.view.bounds.height - footer.bounds.height - marginBottom
            
        case .PinBoth(let marginBottom, let marginLeft,let marginRight):
            
            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleWidth]
            footer.frame.size.width = self.view.bounds.width - marginLeft - marginRight
            footer.sizeToFit()
            footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.bounds.height - marginBottom)
            
        case .PinLeft(let marginBottom, let marginLeft):
            
            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleRightMargin]
            footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.bounds.height - marginBottom)
            
        case .PinRight(let marginBottom, let marginRight):
            
            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin]
            footer.frame.origin = CGPoint(x: self.view.bounds.width - marginRight - footer.bounds.width, y: self.view.bounds.height - footer.bounds.height - marginBottom)
            
        }
    }
    
    // MARK: - Transitioning Delegate
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    // MARK: - Actions
    func detail(){
        let detailsActivityViewController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        detailsActivityViewController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "View Item in NYPL Collection", style: .Default) { UIAlertAction in
            let photoID = (self.imageProvider.locationData[self.currentIndex]["photoID"] as! String).componentsSeparatedByString("-").first
            
            let webURL = "http://digitalcollections.nypl.org/items/image_id/" + photoID!
            let webV:UIWebView = UIWebView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
            webV.loadRequest(NSURLRequest(URL: NSURL(string: webURL)!))
            webV.tag = 69
            self.view.addSubview(webV)
            let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 50))
            navBar.tag = 70
            self.view.addSubview(navBar);
            let navItem = UINavigationItem(title: "")
            let btn2 = UIButton()
            btn2.setImage(UIImage(named: "close_normal"), forState: .Normal)
            btn2.frame = CGRectMake(0, 0, 50, 50)
            btn2.imageEdgeInsets = UIEdgeInsetsMake(-1.0, -30.0, 0.0, 0.0)
            btn2.addTarget(self, action: #selector(GalleryViewController.removeWebView), forControlEvents: .TouchUpInside)
            let item2 = UIBarButtonItem()
            item2.customView = btn2
            navItem.leftBarButtonItem = item2;
            navBar.setItems([navItem], animated: false);
            navBar.barTintColor = UIColor.blackColor()
        }
        detailsActivityViewController.addAction(OKAction)
        self.presentViewController(detailsActivityViewController, animated: true, completion: nil)
    }
    
    func removeWebView(){
        if let viewWithTag = self.view.viewWithTag(69) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(70) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func action(){
        let image = self.imageProvider.locationArray[self.currentIndex]
        let shareActivityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.presentViewController(shareActivityViewController, animated: true, completion: nil)
    }
    
    func close() {
        
        UIView.animateWithDuration(0.1, animations: { [weak self] in
            
            self?.headerView?.alpha = 0.0
            self?.footerView?.alpha = 0.0
            self?.closeButton?.alpha = 0.0
            self?.detailButton?.alpha = 0.0
            self?.shareButton?.alpha = 0.0
            
        }) { [weak self] done in
            
//            if self?.currentIndex == self?.startIndex {
//                
//                self?.view.backgroundColor = UIColor.clearColor()
//                
//                if let imageController = self?.viewControllers?.first as? ImageViewController {
//                    
//                    imageController.closeAnimation(self?.closeAnimationDuration ?? 0.2, completion: { [weak self] finished in
//                        
//                        self?.innerClose()
//                        })
//                }
//            }
//            else {
                self?.innerClose()
//            }
            
        }
    }
    
    func innerClose() {
        
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(true) {
            
            self.applicationWindow!.windowLevel = UIWindowLevelNormal
        }
        
        closedCompletion?()
    }
    
    // MARK: - Image Controller Delegate
    
    func imageViewController(controller: ImageViewController, didSwipeToDismissWithDistanceToEdge distance: CGFloat) {
        
        self.view.backgroundColor = (distance == 0) ? UIColor.blackColor() : UIColor.clearColor()
        
        if isDecorationViewsHidden == false {
            
            let alpha = 1 - distance * swipeToDismissFadeOutAccelerationFactor
            
            closeButton?.alpha = alpha
            detailButton?.alpha = alpha
            shareButton?.alpha = alpha
            headerView?.alpha = alpha
            footerView?.alpha = alpha
        }
    }
    
    func imageViewControllerDidSingleTap(controller: ImageViewController) {
        
        let alpha: CGFloat = (isDecorationViewsHidden) ? 1 : 0
        
        isDecorationViewsHidden = !isDecorationViewsHidden
        
        UIView.animateWithDuration(toggleHeaderFooterAnimationDuration, animations: { [weak self] in
            
            self?.headerView?.alpha = alpha
            self?.footerView?.alpha = alpha
            self?.closeButton?.alpha = alpha
            self?.detailButton?.alpha = alpha
            self?.shareButton?.alpha = alpha
            
            })
    }
    
    func imageViewControllerDidAppear(controller: ImageViewController) {
        
        self.currentIndex = controller.index
        self.landedPageAtIndexCompletion?(self.currentIndex)
    }
}