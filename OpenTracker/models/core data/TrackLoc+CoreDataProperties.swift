//
//  TrackLoc+CoreDataProperties.swift
//  OpenTracker
//
//  Created by Alexander Skorulis on 11/10/18.
//  Copyright © 2018 Alexander Skorulis. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

extension TrackLoc {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackLoc> {
        return NSFetchRequest<TrackLoc>(entityName: "TrackLoc")
    }

    @NSManaged public var firstTime: NSDate?
    @NSManaged public var lastTime: NSDate?
    @NSManaged public var lat: Double
    @NSManaged public var lng: Double
    @NSManaged public var visit: Bool
    
    func coord() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude:lng)
    }

}
