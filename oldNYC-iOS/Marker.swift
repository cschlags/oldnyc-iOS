//
//  Marker.swift
//  oldNYC-iOS
//
//  Created by Orian Breaux on 1/25/16.
//  Copyright © 2016 OldNYC. All rights reserved.
//

import Foundation
import CoreData

class Marker : NSManagedObject {
    @NSManaged var lat : Double
    @NSManaged var lon : Double
    @NSManaged var photo_count : Int16
}