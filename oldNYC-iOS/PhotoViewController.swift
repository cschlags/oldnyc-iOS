//
//  PhotoViewController.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux and Christina Leuci.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class PhotoViewController: UIViewController, NYTPhotosViewControllerDelegate{
    var locationPhotosArrayPassed:[String]!
    var locationPhotoIndexPassed:Int!
    @IBOutlet weak var imageButton: UIButton?
    var photos: [Photo!] = []
    
    func updateImagesOnPhotosViewController(photosViewController: NYTPhotosViewController, afterDelayWithPhotos: [Photo]) {
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, 5 * Int64(NSEC_PER_SEC))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            for photo in self.photos {
                if photo!.image == nil {
                    photosViewController.updateImageForPhoto(photo)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.setPhotos()
    }
    
    func callPhoto() -> Array<Photo>{
        var mutablePhotos: [Photo] = []
        let NumberOfPhotos = locationPhotosArrayPassed.count
        if locationPhotoIndexPassed != 0{
            swap(&locationPhotosArrayPassed[0], &locationPhotosArrayPassed[locationPhotoIndexPassed])
        }
        for photoIndex in 0 ..< NumberOfPhotos {
            let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            let request = NSURL(string: locationPhotosArrayPassed[photoIndex])!
                
            let image = UIImage(data: NSData(contentsOfURL: request)!)
            
            let photo = Photo(image: image, attributedCaptionTitle: title)
            mutablePhotos.append(photo)
        }
        return mutablePhotos
    }
    
    func setPhotos(){
        let photosViewController: NYTPhotosViewController = NYTPhotosViewController(photos: self.callPhoto())
        self.presentViewController(photosViewController, animated: true, completion: { _ in })
        
        updateImagesOnPhotosViewController(photosViewController, afterDelayWithPhotos: self.callPhoto())
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NYTPhotosViewControllerDelegate

    func photosViewController(photosViewController: NYTPhotosViewController, handleActionButtonTappedForPhoto photo: NYTPhoto) -> Bool {
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            guard let photoImage = photo.image else { return false }
            
            let shareActivityViewController = UIActivityViewController(activityItems: [photoImage], applicationActivities: nil)
            
            shareActivityViewController.completionWithItemsHandler = {(activityType: String?, completed: Bool, items: [AnyObject]?, error: NSError?) in
                if completed {
                    photosViewController.delegate?.photosViewController!(photosViewController, actionCompletedWithActivityType: activityType!)
                }
            }
            
            shareActivityViewController.popoverPresentationController?.barButtonItem = photosViewController.rightBarButtonItem
            photosViewController.presentViewController(shareActivityViewController, animated: true, completion: nil)
            
            return true
        }
        
        return false
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController, referenceViewForPhoto photo: NYTPhoto) -> UIView? {
        return imageButton
    }

    func photosViewController(photosViewController: NYTPhotosViewController, loadingViewForPhoto photo: NYTPhoto) -> UIView? {
        return nil
    }

    func photosViewController(photosViewController: NYTPhotosViewController, captionViewForPhoto photo: NYTPhoto) -> UIView? {
        return nil
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController, didNavigateToPhoto photo: NYTPhoto, atIndex photoIndex: UInt) {
        print("Did Navigate To Photo: \(photo) identifier: \(photoIndex)")
    }
    
    func photosViewController(photosViewController: NYTPhotosViewController, actionCompletedWithActivityType activityType: String?) {
        print("Action Completed With Activity Type: \(activityType)")
    }
    
    func photosViewControllerDidDismiss(photosViewController: NYTPhotosViewController) {
        print("Did dismiss Photo Viewer: \(photosViewController)")
        photos.removeAll()
    }
}
