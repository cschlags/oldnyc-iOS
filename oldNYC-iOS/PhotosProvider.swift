//
//  PhotosProvider.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux on 3/13/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit
import NYTPhotoViewer

var photoDataArray:[NSData]!

class PhotosProvider: NSObject {
    
    init(array: [NSData]){
        print(array)
        photoDataArray = array
    }
    
    let photos: [Photo] = {
        var mutablePhotos: [Photo] = []
        let NumberOfPhotos = photoDataArray.count/2
        
        for photoIndex in 0 ..< NumberOfPhotos {
            let title = NSAttributedString(string: "\(photoIndex + 1)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            let image = UIImage(data: photoDataArray[photoIndex])
            
            let photo = Photo(image: image, attributedCaptionTitle: title)
            mutablePhotos.append(photo)
        }
        
        return mutablePhotos
    }()
}