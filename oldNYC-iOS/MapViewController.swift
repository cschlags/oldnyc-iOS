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
import SwiftyJSON

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
        mapView.showsUserLocation = false // Make true
        //mapView.userTrackingMode = .Follow
        
        mapView.logoView.hidden = true
        mapView.attributionButton.hidden = true
        mapView.scrollEnabled = true
        mapView.rotateEnabled = false
        mapView.pitchEnabled = false
        
        // Place marker annotations on map.
        generateMarkersFromJSON()
        
        
        mapView(<#T##mapView: MGLMapView##MGLMapView#>, didSelectAnnotation: <#T##MGLAnnotation#>)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//********** FUNCTIONS FOR GENERATING MAP UI **********//
    
    // Reads markers.json and generates markers for each coordinate.
    func generateMarkersFromJSON() {
        if let path = NSBundle.mainBundle().pathForResource("markers", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {

                    // Create markers for each item.
                    for item in jsonObj["markers"].arrayValue {
                        let lat = item["lat"].double
                        let lon = item["lon"].double
                        placeMarker(lat!, lon: lon!)
                    }
                    
                } else {
                    print("could not get json from file")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    // Creates a marker annotation for the given lat and lon.
    func placeMarker(lat: Double, lon: Double) {
        let marker = MGLPointAnnotation()
        marker.coordinate = CLLocationCoordinate2DMake(lat, lon)
        //marker.title = "marker title here"
        
        mapView.addAnnotation(marker)
    }
    
    // Define and use custom marker style
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("LocationMarker")
        
        if annotationImage == nil {
            let image = UIImage(named: "LocationMarker")
            annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: "LocationMarker")
        }
        
        return annotationImage
    }
    
    
    //func isUserInNewYorkCity() {
        //add code here
    //}
}