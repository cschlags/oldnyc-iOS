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
import NYTPhotoViewer
import SDWebImage

class GalleryViewController: UICollectionViewController, FMMosaicLayoutDelegate, NYTPhotosViewControllerDelegate{
    private let reuseIdentifier = "galleryCell"
    var lastTappedLocationDataPassed:[[String : Any]]!
    var lastTappedLocationName : String?
    var locationPhotoIndex:Int = 0
    var hidingNavBarManager: HidingNavigationBarManager?
    @IBOutlet var gallery: UICollectionView!
    var photos: [NYTPhoto] = []
    
    override func viewDidLoad() {
        let mosaicLayout : FMMosaicLayout = FMMosaicLayout()
        self.collectionView!.collectionViewLayout = mosaicLayout
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let location = lastTappedLocationDataPassed[0]["folder"] as! String
        self.navigationItem.title = "\(location.componentsSeparatedByString(",")[0])";

        // Do any additional setup after loading the view.
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: gallery)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.backgroundColor = UIColor.blackColor()
        let flickrPhoto =  lastTappedLocationDataPassed![indexPath.row]
        let url = flickrPhoto["image_url"] as! String
        cell.cellImage.image = nil;
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
        locationPhotoIndex = indexPath.row
        self.setPhotos()
    }
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: FMMosaicLayout!, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath!) -> FMMosaicCellSize {
//        return indexPath.item % 4 == 0 ? FMMosaicCellSize.Big : FMMosaicCellSize.Small
//    }

    func callPhoto() {
        var mutablePhotos: [Photo] = []
        let NumberOfPhotos = lastTappedLocationDataPassed.count
        
        for photoIndex in 0 ..< NumberOfPhotos {
            let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            let request = NSURL(string: lastTappedLocationDataPassed[photoIndex]["image_url"] as! String)!
            let image = UIImageView.sd_setImageWithURL(request)
//            let image = UIImage(data: NSData(contentsOfURL: request)!)
            
            let photo = Photo(image: image, attributedCaptionTitle: title)
            mutablePhotos.append(photo)
        }
        photos = mutablePhotos
    }
    
    func setPhotos(){
        callPhoto()
        let galleryViewController: NYTPhotosViewController = NYTPhotosViewController(photos: self.photos, initialPhoto: self.photos[locationPhotoIndex])
        self.presentViewController(galleryViewController, animated: true, completion: { _ in })
    }
    
    // MARK: - NYTPhotosViewControllerDelegate
    func galleryViewController(galleryViewController: NYTPhotosViewController, handleActionButtonTappedForPhoto photo: NYTPhoto) -> Bool {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            guard let photoImage = photo.image else { return false }
            
            let shareActivityViewController = UIActivityViewController(activityItems: [photoImage], applicationActivities: nil)
            
            shareActivityViewController.completionWithItemsHandler = {(activityType: String?, completed: Bool, items: [AnyObject]?, error: NSError?) in
                if completed {
                    galleryViewController.delegate?.photosViewController!(galleryViewController, actionCompletedWithActivityType: activityType)
                }
            }
            
            shareActivityViewController.popoverPresentationController?.barButtonItem = galleryViewController.rightBarButtonItem
            galleryViewController.presentViewController(shareActivityViewController, animated: true, completion: nil)
            
            return true
        }
        return false
    }
    
    func galleryViewController(galleryViewController: NYTPhotosViewController, referenceViewForPhoto photo: NYTPhoto) -> UIView? {
        return nil
    }
    
    func galleryViewController(galleryViewController: NYTPhotosViewController, loadingViewForPhoto photo: NYTPhoto) -> UIView? {
        return nil
    }
    
    func galleryViewController(galleryViewController: NYTPhotosViewController, captionViewForPhoto photo: NYTPhoto) -> UIView? {
        return nil
    }
    
    func galleryViewController(galleryViewController: NYTPhotosViewController, didNavigateToPhoto photo: NYTPhoto, atIndex photoIndex: UInt) {
        print("Did Navigate To Photo: \(photo) identifier: \(photoIndex)")
    }
    
    func galleryViewController(galleryViewController: NYTPhotosViewController, actionCompletedWithActivityType activityType: String?) {
        print("Action Completed With Activity Type: \(activityType)")
    }
    
    func photosViewControllerDidDismiss(galleryViewController: NYTPhotosViewController) {
        print("Did dismiss Photo Viewer: \(galleryViewController)")
    }
}
