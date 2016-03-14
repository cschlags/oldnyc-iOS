//
//  PhotosProvider.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux on 3/13/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit
import NYTPhotoViewer

let CustomEverythingPhotoIndex = 1, DefaultLoadingSpinnerPhotoIndex = 3, NoReferenceViewPhotoIndex = 4
let PrimaryImageName = "ImageName"
let PlaceholderImageName = "PlaceholderImageName"

class PhotosProvider: NSObject {
    
    let photos: [Photo] = {
        
        var mutablePhotos: [Photo] = []
        var image = UIImage(named: PrimaryImageName)
        let NumberOfPhotos = 5
        
        func shouldSetImageOnIndex(photoIndex: Int) -> Bool {
            return photoIndex != CustomEverythingPhotoIndex && photoIndex != DefaultLoadingSpinnerPhotoIndex
        }
        
        for photoIndex in 0 ..< NumberOfPhotos {
            let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            let photo = shouldSetImageOnIndex(photoIndex) ? Photo(image: image, attributedCaptionTitle: title) : Photo(attributedCaptionTitle: title)
            
            if photoIndex == CustomEverythingPhotoIndex {
                photo.placeholderImage = UIImage(named: PlaceholderImageName)
            }
            
            mutablePhotos.append(photo)
        }
        
        return mutablePhotos
    }()
}