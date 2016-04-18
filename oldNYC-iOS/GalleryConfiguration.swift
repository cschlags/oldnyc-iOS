//
//  GalleryConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public enum GalleryPagingMode {
    
    case Standard
    case Carousel
}

public typealias GalleryConfiguration = [GalleryConfigurationItem]

public enum GalleryConfigurationItem {
    
    case ImageDividerWidth(CGFloat)
    case SpinnerStyle(UIActivityIndicatorViewStyle)
    case SpinnerColor(UIColor)
    case CloseButton(UIButton)
    case DetailButton(UIButton)
    case ShareButton(UIButton)
    case PagingMode(GalleryPagingMode)
    case CloseLayout(CloseButtonLayout)
    case DetailLayout(DetailButtonLayout)
    case ShareLayout(ShareButtonLayout)
    case HeaderViewLayout(HeaderLayout)
    case FooterViewLayout(FooterLayout)
    case StatusBarHidden(Bool)
    case HideDecorationViewsOnLaunch(Bool)
}

func defaultGalleryConfiguration() -> GalleryConfiguration {
    
    let dividerWidth = GalleryConfigurationItem.ImageDividerWidth(10)
    let spinnerColor = GalleryConfigurationItem.SpinnerColor(UIColor.whiteColor())
    let spinnerStyle = GalleryConfigurationItem.SpinnerStyle(UIActivityIndicatorViewStyle.White)
    
    let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    button.setImage(UIImage(named: "close_normal"), forState: UIControlState.Normal)
    button.setImage(UIImage(named: "close_highlighted"), forState: UIControlState.Highlighted)
    let closeButton = GalleryConfigurationItem.CloseButton(button)
    
    let detail = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    detail.setImage(UIImage(named: "MoreDetails"), forState: UIControlState.Normal)
    let detailButton = GalleryConfigurationItem.DetailButton(detail)
    
    let share = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    share.setImage(UIImage(named: "ShareIcon"), forState: UIControlState.Normal)
    let shareButton = GalleryConfigurationItem.ShareButton(share)
    
    let pagingMode = GalleryConfigurationItem.PagingMode(GalleryPagingMode.Standard)
    
//    originally 15, 16
    let closeLayout = GalleryConfigurationItem.CloseLayout(CloseButtonLayout.PinLeft(2, 1))
    let detailLayout = GalleryConfigurationItem.DetailLayout(DetailButtonLayout.PinRight(5, 50))
    let shareLayout = GalleryConfigurationItem.ShareLayout(ShareButtonLayout.PinRight(1, 1))
    let headerLayout = GalleryConfigurationItem.HeaderViewLayout(HeaderLayout.Center(16))
    let footerLayout = GalleryConfigurationItem.FooterViewLayout(FooterLayout.Center(1))
    
    let statusBarHidden = GalleryConfigurationItem.StatusBarHidden(true)
    
    let hideDecorationViews = GalleryConfigurationItem.HideDecorationViewsOnLaunch(false)
    
    return [dividerWidth, spinnerStyle, spinnerColor, closeButton, detailButton, shareButton, pagingMode, headerLayout, footerLayout, closeLayout, detailLayout, shareLayout, statusBarHidden, hideDecorationViews]
}