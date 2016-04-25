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
    var lastContentOffset: CGPoint!
    var imageView: UIImageView!
    var footerView: FooterView!
    
    override func viewDidLoad() {
        let mosaicLayout : FMMosaicLayout = FMMosaicLayout()
        self.collectionView!.collectionViewLayout = mosaicLayout
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = false
        let location = lastTappedLocationDataPassed[0]["folder"] as! String
        self.navigationItem.title = "\(location.componentsSeparatedByString(",")[0])";
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: gallery)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.populatePhotoArray()
        self.navigationController?.navigationBar.translucent = true
        hidingNavBarManager?.viewWillAppear(animated)
        self.collectionView?.decelerationRate = UIScrollViewDecelerationRateNormal
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
        if Reachability.isConnectedToNetwork() == true {
            locationPhotoIndex = indexPath.row
            let request = NSData(contentsOfURL: NSURL(string: self.lastTappedLocationDataPassed[locationPhotoIndex]["image_url"] as! String)!)
            let image = UIImage.sd_imageWithData(request)
            imageView = UIImageView(image: image!)
            self.setPhotosInGallery(imageView)
        } else {
            let detailsActivityViewController = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                
            }
            detailsActivityViewController.addAction(cancelAction)
            self.presentViewController(detailsActivityViewController, animated: true, completion: nil)
            NSLog("Internet connection FAILED")
        }
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: FMMosaicLayout!, mosaicCellSizeForItemAtIndexPath indexPath: NSIndexPath!) -> FMMosaicCellSize {
//        if lastTappedLocationDataPassed.count < 6{
//            return FMMosaicCellSize.Big
//        }else{
            return FMMosaicCellSize.Small
//        }
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
    
    func setPhotosInGallery(displacedView: UIImageView){
        let imageProvider = SomeImageProvider(locationData: self.lastTappedLocationDataPassed, locationArray: self.photos, startImage: self.imageView)
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 75)
        let headerView = CounterView(frame: frame, currentIndex: locationPhotoIndex, count: self.photos.count)
        
        footerView = FooterView(frame: footerFrame, year: "", summary: "", count: self.photos.count)
        galleryViewController = GalleryViewController(imageProvider: imageProvider, displacedView: displacedView, imageCount: self.photos.count, startIndex: locationPhotoIndex)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoGalleryViewController.handleFooterViewTap(_:)))
        footerView.yearLabel?.addGestureRecognizer(gestureRecognizer)
        
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED")}
        galleryViewController.closedCompletion = { print("CLOSED")}
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED")}
        
        galleryViewController.landedPageAtIndexCompletion = { index in
            if self.galleryViewController.footerView?.frame.height != 75.0 && self.galleryViewController.footerView?.frame.height != 100.0{
                print("LANDED AT INDEX: \(index)")
                var footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
                self.footerView.frame = footerFrame
                let description = self.lastTappedLocationDataPassed[index]["description"] as! String
                headerView.currentIndex = index
                self.footerView.year = self.lastTappedLocationDataPassed[index]["date"] as! String
                self.footerView.summary = description
                
                let contentSize: CGFloat = (self.footerView.yearLabel?.contentSize.height)! + 5
                if contentSize < 75{
                    if UIDevice.currentDevice().orientation.isLandscape{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.height, height: 80.0)
                    }else if UIDevice.currentDevice().orientation.isPortrait{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 80.0)
                    }else if UIDevice.currentDevice().orientation.isFlat{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 80.0)
                    }
                }else if contentSize > 600{
                    if UIDevice.currentDevice().orientation.isLandscape{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.height, height: 600.0)
                    }else if UIDevice.currentDevice().orientation.isPortrait{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 600.0)
                    }else if UIDevice.currentDevice().orientation.isFlat{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 600.0)
                    }
                }else {
                    if UIDevice.currentDevice().orientation.isLandscape{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.height, height: contentSize)
                    }else if UIDevice.currentDevice().orientation.isPortrait{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: contentSize)
                    }else if UIDevice.currentDevice().orientation.isFlat{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: contentSize)
                    }
                }
                self.footerView.frame = footerFrame
                self.galleryViewController.footerView = self.footerView
            }else{
                var footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
                if UIDevice.currentDevice().orientation.isLandscape{
                    footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.height, height: 100.0)
                }else if UIDevice.currentDevice().orientation.isPortrait{
                    footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100.0)
                }else if UIDevice.currentDevice().orientation.isFlat{
                    footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100.0)
                }
                self.galleryViewController.footerView?.frame = footerFrame
                print("LANDED AT INDEX: \(index)")
                
                headerView.currentIndex = index
                let description = self.lastTappedLocationDataPassed[index]["description"] as! String
                var substring = ""
                if description.characters.count > 29{
                    substring = description.substringToIndex(description.startIndex.advancedBy(30))
                }else{
                    substring = description
                }
                self.footerView.year = self.lastTappedLocationDataPassed[index]["date"] as! String
                self.footerView.summary = substring
            }
        }
        
        self.presentImageGallery(galleryViewController)
    }
    
    func handleFooterViewTap(gestureRecognizer: UIGestureRecognizer){
        let description = self.lastTappedLocationDataPassed[galleryViewController.currentIndex]["description"] as! String
        if !description.isEmpty && description.characters.count > 29{
            if self.footerView.frame.height == 100.0{
                var footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
                self.footerView.frame = footerFrame
                self.footerView.summary = description
                let contentSize: CGFloat = (self.footerView.yearLabel?.contentSize.height)! + 5
                if contentSize < 75{
                    if UIDevice.currentDevice().orientation.isLandscape{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.height, height: 80.0)
                    }else if UIDevice.currentDevice().orientation.isPortrait{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 80.0)
                    }else if UIDevice.currentDevice().orientation.isFlat{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 80.0)
                    }
                }else if contentSize > 600{
                    if UIDevice.currentDevice().orientation.isLandscape{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.height, height: 600.0)
                    }else if UIDevice.currentDevice().orientation.isPortrait{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 600.0)
                    }else if UIDevice.currentDevice().orientation.isFlat{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 600.0)
                    }
                }else {
                    if UIDevice.currentDevice().orientation.isLandscape{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.height, height: contentSize)
                    }else if UIDevice.currentDevice().orientation.isPortrait{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: contentSize)
                    }else if UIDevice.currentDevice().orientation.isFlat{
                        footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: contentSize)
                    }
                }
                self.footerView.frame = footerFrame
                galleryViewController.footerView = self.footerView
            }else{
                var footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height)
                if UIDevice.currentDevice().orientation.isLandscape{
                    footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.height, height: 100.0)
                }else if UIDevice.currentDevice().orientation.isPortrait{
                    footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100.0)
                }else if UIDevice.currentDevice().orientation.isFlat{
                    footerFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100.0)
                }
                self.footerView.frame = footerFrame
                var substring = ""
                if description.characters.count > 29{
                    substring = description.substringToIndex(description.startIndex.advancedBy(30))
                }else{
                    substring = description
                }
                self.footerView.summary = substring
                galleryViewController.footerView = self.footerView
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
}

class SomeImageProvider: ImageProvider{
    var locationArray: [UIImage!]
    var locationData: [[String:Any]]
    var startImage: UIImageView
    required init(locationData: [[String:Any]], locationArray: [UIImage!], startImage: UIImageView) {
        self.locationArray = locationArray
        self.locationData = locationData
        self.startImage = startImage
    }
    
    func provideImage(completion: UIImage? -> Void) {
        completion(UIImage(named: "image_big"))
    }
    
    func provideImage(atIndex index: Int, completion: UIImage? -> Void) {
        if index == 0 {
            locationArray[index] = self.startImage.image!
        }
        if index+1 < locationArray.count{
            if locationArray[index+1] == nil{
                let request = NSData(contentsOfURL: NSURL(string: locationData[index]["image_url"] as! String)!)
                let image = UIImage.sd_imageWithData(request)
                locationArray[index+1] = image
            }
        }
        completion(locationArray[index])
    }
}
