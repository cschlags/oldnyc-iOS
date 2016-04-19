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
    var galleryViewController: GalleryViewController!
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
        locationPhotoIndex = indexPath.row
        let image = self.photos[locationPhotoIndex]
        let imageView = UIImageView(image: image!)
        self.setPhotosInGallery(imageView)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: FMMosaicLayout!, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath!) -> FMMosaicCellSize {
        if lastTappedLocationDataPassed.count < 6{
            return FMMosaicCellSize.Big
        }else{
            return FMMosaicCellSize.Small
        }
    }
    func populatePhotoArray(){
        let photoInt:Int = self.lastTappedLocationDataPassed.count
        self.photos = [UIImage!](count: photoInt, repeatedValue: nil)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            let NumberOfPhotos = self.lastTappedLocationDataPassed.count
            for photoIndex in 0 ..< NumberOfPhotos {
                let request = NSData(contentsOfURL: NSURL(string: self.lastTappedLocationDataPassed[photoIndex]["image_url"] as! String)!)
                let image = UIImage.sd_imageWithData(request)
                
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.photos[photoIndex] = image
                })
            }
        })
    }
    
    func setPhotosInGallery(displacedView: UIView){
        let imageProvider = SomeImageProvider(locationData: self.lastTappedLocationDataPassed, locationArray: self.photos)
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100)
        let headerView = CounterView(frame: frame, currentIndex: locationPhotoIndex, count: self.photos.count)
        let footerView = FooterView(frame: footerFrame, year: self.lastTappedLocationDataPassed[locationPhotoIndex]["date"] as! String, summary: self.lastTappedLocationDataPassed[locationPhotoIndex]["description"] as! String, count: self.photos.count)
        let galleryViewController = GalleryViewController(imageProvider: imageProvider, displacedView: displacedView, imageCount: self.photos.count, startIndex: locationPhotoIndex)
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        
        galleryViewController.landedPageAtIndexCompletion = { index in
            
            print("LANDED AT INDEX: \(index)")
            
            headerView.currentIndex = index
            
            footerView.year = self.lastTappedLocationDataPassed[index]["date"] as! String
            footerView.summary = self.lastTappedLocationDataPassed[index]["description"] as! String
        }
        
        self.presentImageGallery(galleryViewController)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}

class SomeImageProvider: ImageProvider{
    var locationArray: [UIImage!]
    var locationData: [[String:Any]]
    required init(locationData: [[String:Any]], locationArray: [UIImage!]) {
        self.locationArray = locationArray
        self.locationData = locationData
    }
    
    func provideImage(completion: UIImage? -> Void) {
        completion(UIImage(named: "image_big"))
    }
    
    func provideImage(atIndex index: Int, completion: UIImage? -> Void) {
        if locationArray[index] == nil{
            let request = NSData(contentsOfURL: NSURL(string: locationData[index]["image_url"] as! String)!)
            let image = UIImage.sd_imageWithData(request)
            locationArray[index] = image
        }
        completion(locationArray[index])
    }
}
