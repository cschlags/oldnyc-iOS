//
//  GalleryConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public enum GalleryPagingMode {
    
    case standard
    case carousel
}

public typealias GalleryConfiguration = [GalleryConfigurationItem]

public enum GalleryConfigurationItem {
    
    case imageDividerWidth(CGFloat)
    case spinnerStyle(UIActivityIndicatorViewStyle)
    case spinnerColor(UIColor)
    case closeButton(UIButton)
    case detailButton(UIButton)
    case shareButton(UIButton)
    case pagingMode(GalleryPagingMode)
    case closeLayout(CloseButtonLayout)
    case detailLayout(DetailButtonLayout)
    case shareLayout(ShareButtonLayout)
    case headerViewLayout(HeaderLayout)
    case footerViewLayout(FooterLayout)
    case statusBarHidden(Bool)
    case hideDecorationViewsOnLaunch(Bool)
}

func defaultGalleryConfiguration() -> GalleryConfiguration {
    
    let dividerWidth = GalleryConfigurationItem.imageDividerWidth(10)
    let spinnerColor = GalleryConfigurationItem.spinnerColor(UIColor.white)
    let spinnerStyle = GalleryConfigurationItem.spinnerStyle(UIActivityIndicatorViewStyle.white)
    
    let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    button.setImage(UIImage(named: "close_normal"), for: UIControlState())
    button.setImage(UIImage(named: "close_highlighted"), for: UIControlState.highlighted)
    let closeButton = GalleryConfigurationItem.closeButton(button)
    
    let detail = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    detail.setImage(UIImage(named: "MoreDetails"), for: UIControlState())
    let detailButton = GalleryConfigurationItem.detailButton(detail)
    
    let share = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    share.setImage(UIImage(named: "ShareIcon"), for: UIControlState())
    let shareButton = GalleryConfigurationItem.shareButton(share)
    
    let pagingMode = GalleryConfigurationItem.pagingMode(GalleryPagingMode.standard)
    
//    originally 15, 16
    let closeLayout = GalleryConfigurationItem.closeLayout(CloseButtonLayout.pinLeft(2, 1))
    let detailLayout = GalleryConfigurationItem.detailLayout(DetailButtonLayout.pinRight(5, 50))
    let shareLayout = GalleryConfigurationItem.shareLayout(ShareButtonLayout.pinRight(1, 1))
    let headerLayout = GalleryConfigurationItem.headerViewLayout(HeaderLayout.center(16))
    let footerLayout = GalleryConfigurationItem.footerViewLayout(FooterLayout.center(1))
    
    let statusBarHidden = GalleryConfigurationItem.statusBarHidden(true)
    
    let hideDecorationViews = GalleryConfigurationItem.hideDecorationViewsOnLaunch(false)
    
    return [dividerWidth, spinnerStyle, spinnerColor, closeButton, detailButton, shareButton, pagingMode, headerLayout, footerLayout, closeLayout, detailLayout, shareLayout, statusBarHidden, hideDecorationViews]
}
