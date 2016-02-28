//
//  MenuVC.swift
//  oldNYC-iOS
//
//  Created by Christina Leuci on 1/19/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UITableViewController{
    var items = ["Send Your Feedback", "Privacy Policy", "Subscribe to Updates", "Share with Friends", "Like OldNYC", "Review on App Store", "Data Attributions"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        navigationItem.title = nil
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MenuTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MenuTableViewCell
        let item = items[indexPath.row]
        // Configure the cell...
        cell.menuItemLabel.text = item
        return cell
    }
}