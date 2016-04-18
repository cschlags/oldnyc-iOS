//
//  ImageViewerConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 18/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public struct CloseButtonAssets {
    
    public let normal: UIImage
    public let highlighted: UIImage?
    
    public init(normal: UIImage, highlighted: UIImage?) {
        
        self.normal = normal
        self.highlighted = highlighted
    }
}

public struct DetailButtonAssets {
    
    public let normal: UIImage
    
    public init(normal: UIImage) {
        
        self.normal = normal
    }
}

public struct ShareButtonAssets {
    
    public let normal: UIImage
    
    public init(normal: UIImage) {
        
        self.normal = normal
    }
}

public struct ImageViewerConfiguration {
    
    public let imageSize: CGSize
    public let closeButtonAssets: CloseButtonAssets
    public let detailButtonAssets: DetailButtonAssets
    public let shareButtonAssets: ShareButtonAssets
    
    public init(imageSize: CGSize, closeButtonAssets: CloseButtonAssets, detailButtonAssets: DetailButtonAssets, shareButtonAssets: ShareButtonAssets) {
        
        self.imageSize = imageSize
        self.closeButtonAssets = closeButtonAssets
        self.detailButtonAssets = detailButtonAssets
        self.shareButtonAssets = shareButtonAssets
    }
}