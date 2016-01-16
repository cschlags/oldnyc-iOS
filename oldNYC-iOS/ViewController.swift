//
//  ViewController.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux and Christina Leuci on 1/9/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.cameraWithLatitude(40.74421,
            longitude: -73.97370, zoom: 15)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        
        // Customize Google Maps features and UI.
        mapView.mapType = kGMSTypeNormal
        mapView.setMinZoom(10, maxZoom: 18)
        mapView.buildingsEnabled = false
        mapView.trafficEnabled = false
        mapView.indoorEnabled = false
        mapView.settings.indoorPicker = false
        mapView.settings.tiltGestures = false
        mapView.settings.compassButton = true
        
        mapView.myLocationEnabled = true
        
        mapView.settings.myLocationButton = true //need to write code to set to false when user inside NYC.
        
        self.view = mapView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}