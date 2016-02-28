//
//  PhotoViewController.swift
//  oldNYC-iOS
//
//  Created by Christina Leuci on 2/25/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import UIKit
import SwiftyJSON

class PhotoViewController: UICollectionViewController {
    private let reuseIdentifier = "buildingCell"
    let kColumnsiPadLandscape = 5
    let kColumnsiPadPortrait = 4
    let kColumnsiPhoneLandscape = 3
    let kColumnsiPhonePortrait = 2
    var lastTappedLocationDataPassed = [[String : Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false


        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 100
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.whiteColor()
        // Configure the cell
    
        return cell
    }

//    func generateMarkersFromJSON() {
//        if let path = NSBundle.mainBundle().pathForResource("markers", ofType: "json") {
//            do {
//                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
//                let jsonObj = JSON(data: data)
//                if jsonObj != JSON.null {
//                    
//                    // Create markers for each item.
//                    for item in jsonObj["markers"].arrayValue {
////                        let lat = item["latitude"].double
////                        let lon = item["longitude"].double
////                        let title = item["marker_title"].stringValue
////                        placeMarker(lat!, lon: lon!, title: title)
//                    }
//                    
//                } else {
//                    print("could not get json from file")
//                }
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        } else {
//            print("Invalid filename/path.")
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
