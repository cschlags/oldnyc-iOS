//
//  ViewController.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux and Christina Leuci on 1/9/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit
import CoreLocation
import Mapbox


class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var manager:CLLocationManager!
    var userLocation:CLLocation = CLLocation(latitude: 40.71356, longitude: -73.99084)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        createMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//********** MAPBOX FUNCTIONS **********//

    func createMap() {
        let mapView = MGLMapView(frame: view.bounds,
                                 styleURL: MGLStyle.lightStyleURL())

        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), zoomLevel:12, animated:true)
        
        view.addSubview(mapView)

        // show the user's location on the map (blue dot)
        //mapView.showsUserLocation = true
        //mapView.userTrackingMode = .Follow
        
        mapView.logoView.hidden = true
        mapView.attributionButton.hidden = true
        mapView.scrollEnabled = true
        mapView.rotateEnabled = false
    }
    
    func isUserInNewYorkCity() {

    }
}

/*
TARGET FLOW:
- load map centered in NYC (around default coordinates / zoom level)
- check if user is in NYC
    - if yes, enable location tracking. display blue dot, enable center-on-current-location button.
    - if no, do not enable location tracking. do not display blue dot and center-on-current-location button.
- clicking on center-on-current location button will recent map on user, then put into .Follow tracking mode
*/