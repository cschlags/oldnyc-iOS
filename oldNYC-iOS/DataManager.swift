//
//  DataManager.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux on 1/25/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//
//  Manages data retrieval, local and remote.

import Foundation
import SwiftyJSON
import CoreData

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

//// Reads "markers" JSON file
//func readMarkerJSONData() {
//    
//    if let path = NSBundle.mainBundle().pathForResource("markers", ofType: "json") {
//        do {
//            let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
//            let jsonObj = JSON(data: data)
//            
//            if jsonObj != JSON.null {
//                print("jsonData:\(jsonObj)")
//                saveMarkerJSONData(jsonObj)
//            } else {
//                print("could not get json file; make sure that file contains valid json.")
//            }
//            
//        }
//        catch let error as NSError {
//            print(error.localizedDescription)
//        }
//    } else {
//            print("Invalid filename/path.")
//    }
//}
//
//// Saves "markers" JSON data via Core Data
//func saveMarkerJSONData(data : JSON) {
//
//    let markers = data.dictionary
//    
//    if let managedObjectContext = appDelegate.managedObjectContext {
//        for (key,subJson):(String,JSON) in markers {
//            let marker = NSEntityDescription.insertNewObjectForEntityForName("Marker", inManagedObjectContext: managedObjectContext) as! Marker
//        }
//    }
// }