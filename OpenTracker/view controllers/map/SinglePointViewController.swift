//
//  SinglePointViewController.swift
//  OpenTracker
//
//  Created by Alexander Skorulis on 13/11/18.
//  Copyright © 2018 Alexander Skorulis. All rights reserved.
//

import UIKit
import MapKit

class SinglePointViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView:MKMapView?
    
    var point:TrackLoc!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let annotation = MKPointAnnotation()
        annotation.coordinate = self.point.coord()
        annotation.title = "Point"
        mapView?.addAnnotation(annotation)
        
    }
    
    //MARK: MKMapViewDelegate

}
