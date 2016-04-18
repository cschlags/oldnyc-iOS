//
//  GalleryViewController.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux and Christina Leuci.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit
import SwiftyJSON
import FMMosaicLayout
//import NYTPhotoViewer
import SDWebImage

class PhotoGalleryViewController: UICollectionViewController, FMMosaicLayoutDelegate{
    private let reuseIdentifier = "galleryCell"
    var lastTappedLocationDataPassed = [[String : Any]]()
    var lastTappedLocationName : String?
    var locationPhotoIndex:Int = 0
    var hidingNavBarManager: HidingNavigationBarManager?
    @IBOutlet var gallery: UICollectionView!
//    var galleryView: NYTPhotosViewController!
    var photos : [UIImage!] = []
    var count: Int = 0
    var imageProvider: AnyObject?
    
    override func viewDidLoad() {
        let mosaicLayout : FMMosaicLayout = FMMosaicLayout()
        self.collectionView!.collectionViewLayout = mosaicLayout
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let location = lastTappedLocationDataPassed[0]["folder"] as! String
        self.navigationItem.title = "\(location.componentsSeparatedByString(",")[0])";
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: gallery)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.populatePhotoArray()
        self.navigationController?.navigationBar.translucent = true
        hidingNavBarManager?.viewWillAppear(animated)
        dispatch_async(dispatch_get_main_queue(),{
            self.collectionView?.reloadData()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        hidingNavBarManager?.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hidingNavBarManager?.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return lastTappedLocationDataPassed.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GalleryCollectionViewCell
        cell.backgroundColor = UIColor.blackColor()
        let flickrPhoto =  lastTappedLocationDataPassed[indexPath.row]
        let url = flickrPhoto["image_url"] as! String
        let request = NSURL(string: url)!
        cell.cellImage.sd_setImageWithURL(request)
        cell.alpha = 0.0
        let millisecondsDelay = UInt64((arc4random() % 600) / 1000)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(millisecondsDelay * NSEC_PER_SEC)), dispatch_get_main_queue(),
            ({ () -> Void in
                UIView.animateWithDuration(0.3, animations: ({
                    cell.alpha = 1.0
            }))
        }))
        cell.cellImage.bounds.size = cell.bounds.size
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: FMMosaicLayout, numberOfColumnsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: FMMosaicLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(collectionview: UICollectionView, layout collectionViewLayout: FMMosaicLayout, interitemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 2.0
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.collectionView?.cellForItemAtIndexPath(indexPath)
        locationPhotoIndex = indexPath.row
        self.setPhotosInGallery(cell!)
    }
    
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: FMMosaicLayout!, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath!) -> FMMosaicCellSize {
//        return indexPath.item % 4 == 0 ? FMMosaicCellSize.Big : FMMosaicCellSize.Small
//    }
    func populatePhotoArray(){
        let photoInt:Int = self.lastTappedLocationDataPassed.count
        self.photos = [UIImage!](count: photoInt, repeatedValue: nil)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            let NumberOfPhotos = self.lastTappedLocationDataPassed.count
            for photoIndex in 0 ..< NumberOfPhotos {
//                let title = NSAttributedString(string: self.lastTappedLocationDataPassed[photoIndex]["date"] as! String, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
//                let summary = NSAttributedString(string: self.lastTappedLocationDataPassed[photoIndex]["description"] as! String, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
                let request = NSData(contentsOfURL: NSURL(string: self.lastTappedLocationDataPassed[photoIndex]["image_url"] as! String)!)
                let image = UIImage.sd_imageWithData(request)
//                let number = NSAttributedString(string: self.lastTappedLocationDataPassed[photoIndex]["photoID"] as! String)
//                let photo = Photo(image: image, attributedCaptionTitle: title, attributedCaptionSummary: summary, number: number, cellIndex: NSAttributedString(string: String(photoIndex)))
                
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.photos[photoIndex] = image
                })
            }
        })
    }
    
    func setPhotosInGallery(displacedView: UIView){
        let imageProvider = SomeImageProvider(locationPhotos: self.photos, locationData: self.lastTappedLocationDataPassed)
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: locationPhotoIndex, count: self.photos.count)
        let footerView = CounterView(frame: frame, currentIndex: locationPhotoIndex, count: self.photos.count)
        
        let galleryViewController = GalleryViewController(imageProvider: imageProvider, displacedView: displacedView, imageCount: self.photos.count, startIndex: locationPhotoIndex)
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        
        galleryViewController.landedPageAtIndexCompletion = { index in
            
            print("LANDED AT INDEX: \(index)")
            
            headerView.currentIndex = index
            
            footerView.currentIndex = index
        }
        
        self.presentImageGallery(galleryViewController)
//        let photoArray: [NYTPhoto] = self.photos
//        let galleryView = NYTPhotosViewController(photos: photoArray, initialPhoto: photoArray[locationPhotoIndex])
//        appendBarButtonItem(galleryView)
//        presentViewController(galleryView, animated: false, completion: nil)
//        self.updateImagesOnPhotosViewController(galleryView, afterDelayWithPhotos: photoArray)
    }
    
//    func updateImagesOnPhotosViewController(galleryView: NYTPhotosViewController, afterDelayWithPhotos photos: [NYTPhoto]) {
//            var index_counter: Int = 0
//            print(photos.count)
//            for photo: NYTPhoto in photos {
//                if (photo.image == nil) {
//                    let request = NSData(contentsOfURL: NSURL(string: self.lastTappedLocationDataPassed[index_counter]["image_url"] as! String)!)
//                    photo.image = UIImage.sd_imageWithData(request)
//                    galleryView.updateImageForPhoto(photo)
//                }
//                index_counter+=1
//            }
//    }
    
//    func appendBarButtonItem(view: NYTPhotosViewController){
//        let btn2 = UIButton()
//        btn2.setImage(UIImage(named: "MoreDetails"), forState: .Normal)
//        btn2.frame = CGRectMake(0, 0, 30, 30)
//        btn2.addTarget(self, action: #selector(GalleryViewController.details), forControlEvents: .TouchUpInside)
//        let item2 = UIBarButtonItem()
//        item2.customView = btn2
//        view.rightBarButtonItems?.append(item2)
//    }
    
    // MARK: - NYTPhotosViewControllerDelegate
//    func galleryViewController(galleryViewController: NYTPhotosViewController, handleActionButtonTappedForPhoto photo: NYTPhoto) -> Bool {
//        
//        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//            
//            guard let photoImage = photo.image else { return false }
//            
//            let shareActivityViewController = UIActivityViewController(activityItems: [photoImage], applicationActivities: nil)
//            
//            shareActivityViewController.completionWithItemsHandler = {(activityType: String?, completed: Bool, items: [AnyObject]?, error: NSError?) in
//                if completed {
//                    galleryViewController.delegate?.photosViewController!(galleryViewController, actionCompletedWithActivityType: activityType)
//                }
//            }
//            
//            shareActivityViewController.popoverPresentationController?.barButtonItem = galleryViewController.rightBarButtonItem
//            galleryViewController.presentViewController(shareActivityViewController, animated: true, completion: nil)
//            
//            return true
//        }
//        return false
//    }
//    
//    func details(){
//        let detailsActivityViewController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
//            
//        }
//        detailsActivityViewController.addAction(cancelAction)
//        
//        let OKAction = UIAlertAction(title: "View Item in NYPL Collection", style: .Default) { UIAlertAction in
//            self.performSegueWithIdentifier("detail.alert", sender: self)
//            UIApplication.sharedApplication().sendAction((self.galleryView.leftBarButtonItem?.action)!, to: self.galleryView.leftBarButtonItem?.target, from: self, forEvent: nil)
//        }
//        detailsActivityViewController.addAction(OKAction)
//        
//        detailsActivityViewController.popoverPresentationController?.barButtonItem = galleryView.rightBarButtonItem
//        galleryView.presentViewController(detailsActivityViewController, animated: true, completion: nil)
//    }
//    func photosViewController(photosViewController: NYTPhotosViewController, loadingViewForPhoto photo: NYTPhoto) -> UIView? {
////        if photo.cellIndex == nil{
////            photo.attributedCaptionSummary = self.photos[count].attributedCaptionSummary!
////            photo.attributedCaptionTitle = self.photos[count].attributedCaptionTitle!
////            photo.cellIndex = self.photos[count].cellIndex!
////            photo.number = self.photos[count].number!
////        }
//        return nil
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender:AnyObject!){
        if (segue.identifier == "detail.alert"){
            let svc = segue.destinationViewController as! DetailWebViewController;
//            let string:String = (galleryView.currentlyDisplayedPhoto?.cellIndex?.string)!
//            locationPhotoIndex = Int(string)!
            svc.photoIDPassed = "this"
        }
    }
}

class SomeImageProvider: ImageProvider{
    var locationPhotos: [UIImage!]
    var locationData: [[String:Any]]
    init(locationPhotos: [UIImage!], locationData: [[String:Any]]){
        self.locationPhotos = locationPhotos
        self.locationData = locationData
    }
    
    func provideImage(completion: UIImage? -> Void) {
        completion(UIImage(named: "image_big"))
    }
    
    func provideImage(atIndex index: Int, completion: UIImage? -> Void) {
        if locationPhotos[index] == nil{
            let request = NSData(contentsOfURL: NSURL(string: locationData[index]["image_url"] as! String)!)
            let image = UIImage.sd_imageWithData(request)
            locationPhotos[index] = image
        }
        completion(locationPhotos[index])
    }
}
