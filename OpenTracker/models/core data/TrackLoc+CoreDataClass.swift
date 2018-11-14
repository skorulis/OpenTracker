//
//  TrackLoc+CoreDataClass.swift
//  OpenTracker
//
//  Created by Alexander Skorulis on 11/10/18.
//  Copyright © 2018 Alexander Skorulis. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(TrackLoc)
public class TrackLoc: NSManagedObject {

    func coord() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude:lng)
    }
    
}
