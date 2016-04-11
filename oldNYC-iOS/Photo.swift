//
//  Photo.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux on 3/13/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit
import NYTPhotoViewer
import SDWebImage

class Photo: NSObject, NYTPhoto {

    var image: UIImage?
    var imageData: NSData?
    var placeholderImage: UIImage?
    
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    var number: NSAttributedString?
    var cellIndex: NSAttributedString?
//    let attributedCaptionSummary: NSAttributedString? = NSAttributedString(string: "summary string", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
    var attributedCaptionCredit: NSAttributedString? = NSAttributedString(string: "NYPL Irma and Paul Milstein Collection", attributes: [NSForegroundColorAttributeName: UIColor.darkGrayColor()])
    
    init(image: UIImage? = nil, imageData: NSData? = nil, attributedCaptionTitle: NSAttributedString, attributedCaptionSummary: NSAttributedString, number: NSAttributedString, cellIndex: NSAttributedString) {
        self.image = image
        self.imageData = imageData
        self.attributedCaptionTitle = attributedCaptionTitle
        self.attributedCaptionSummary = attributedCaptionSummary
        self.number = number
        self.cellIndex = cellIndex
        super.init()
    }
}
