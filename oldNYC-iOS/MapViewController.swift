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

class MapViewController: UIViewController,
                         MGLMapViewDelegate {

    var mapView : MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*
    TARGET FLOW:
    - load map centered in NYC (around default coordinates / zoom level)
    - check if user is in NYC
    - if yes, enable location tracking. display blue dot, enable center-on-current-location button.
    - if no, do not enable location tracking. do not display blue dot and center-on-current-location button.
    - clicking on center-on-current location button will recent map on user, then put into .Follow tracking mode
    */
    override func viewDidAppear(animated: Bool) {

        mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.lightStyleURL())
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Set the map's center coordinate, over NYC.
        let userLocation:CLLocation = CLLocation(latitude: 40.71356, longitude: -73.99084)
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), zoomLevel:12, animated:true)
        
        view.addSubview(mapView)
        
        mapView.delegate = self
        
        // Configure map settings.
        //mapView.showsUserLocation = true
        mapView.userTrackingMode = .Follow
        
        mapView.logoView.hidden = true
        mapView.attributionButton.hidden = true
        mapView.scrollEnabled = true
        mapView.rotateEnabled = false
        mapView.pitchEnabled = false
        
        // Place marker annotations on map.
        generateMarkers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//********** FUNCTIONS FOR GENERATING MAP UI **********//
    
    func generateMarkers() {
        for (markerLatLon, _) in markerLocations {
            let coordinates = getLatLongValues(markerLatLon)
            
            let marker = MGLPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lon)
            marker.title = markerLatLon
            
            mapView.addAnnotation(marker)
        }
    }

    // takes String of format "lat,long" and returns Double lat and lon values
    func getLatLongValues(coordinates : String) -> (lat : Double, lon : Double) {
        let coordinatesArr = coordinates.componentsSeparatedByString(",")
    
        let lat = Double(coordinatesArr[0])
        let lon = Double(coordinatesArr[1])
        
        return(lat!, lon!)
    }
    
    func isUserInNewYorkCity() {
        //add code here
    }
}