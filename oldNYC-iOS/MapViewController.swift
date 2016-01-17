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
    var userLocation:CLLocation = CLLocation(latitude: 40.74421, longitude: -73.97370)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserLocation()
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
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), zoomLevel:15, animated:false)
        
        view.addSubview(mapView)

        // show the user's location on the map (blue dot)
        mapView.showsUserLocation = true
    }
    
    // get user's current location
    func getUserLocation() {
        manager = CLLocationManager()
        self.manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    // location manager 'didUpdateLocations' function
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.manager.stopUpdatingLocation()
        self.userLocation = locations[0] as CLLocation
        createMap()
    }
    
    // errors occured
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error:" + error.localizedDescription)
    }
}