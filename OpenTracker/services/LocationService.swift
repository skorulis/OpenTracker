//  Created by Alexander Skorulis on 1/12/16.
//  Copyright © 2016 Alexander Skorulis. All rights reserved.

import CoreLocation
import SKSwiftLib

extension FloatingPoint {
    var degToRad: Self { return self * .pi / 180 }
    var radToDeg: Self { return self * 180 / .pi }
}

enum LocationMode: String {
    case Constant
    case Fenced
}


class LocationService: NSObject, CLLocationManagerDelegate {

    
    let accuracy = ValueCycler(values:[kCLLocationAccuracyNearestTenMeters,kCLLocationAccuracyHundredMeters,kCLLocationAccuracyKilometer,kCLLocationAccuracyThreeKilometers],names:["Ten meters","Hundred meters","Kilometer","Three kilometers"])
    private let history:HistoryService
    let logObservers = ObserverSet<String>();
    let locationUpdateObservers = ObserverSet<CLLocation>()
    private let locationManager:CLLocationManager
    private var hasFence:Bool = false
    var lastUpdate:CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    var isActive:Bool {
        willSet(newValue) {
            if(newValue) {
                start()
            } else {
                stop()
            }
        }
    }

    init(history:HistoryService) {
        self.isActive = true
        self.history = history
        self.locationManager = CLLocationManager()
    }

    func start() {
        startStandard()
    }
    
    func stop() {
        self.locationManager.stopUpdatingLocation()
    }
    
    private func startStandard() {
        self.locationManager.distanceFilter = 10
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = accuracy.currentValue
        
    }
    
    func nextAccuracy() {
        self.locationManager.desiredAccuracy = accuracy.next()
    }
    
    //CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let text = String(format: "exit region %@",region)
        logObservers.notify(parameters: text)
        if let loc = manager.location {
            logObservers.notify(parameters:(String(format: "region exit loc: %@",loc)))
            didUpdate(loc)
        } else {
            logObservers.notify(parameters:"No loc on exit")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let text = String(format: "enter region %@", region)
        logObservers.notify(parameters: text)
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let text = String(format: "did visit %@", visit)
        if (visit.arrivalDate != Date.distantPast && visit.departureDate != Date.distantFuture) {
            let loc = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
            history.saveLoc(loc: loc,isVisit: true)
        }
        logObservers.notify(parameters: text)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let text = String(format: "update locations %@", locations)
        //observers.log(text)
        
        var best:CLLocation = locations.first!
        for l in locations {
            if(l.horizontalAccuracy < best.horizontalAccuracy) {
                best = l
            }
        }
        if(best.horizontalAccuracy < 1000) {
            didUpdate(best)
        } else {
            logObservers.notify(parameters: "Ignoring bad accuracy \(best.horizontalAccuracy)")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("monitoring started")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        logObservers.notify(parameters: "failed to monitor region")
    }
    
    func didUpdate(_ location: CLLocation!) {
        lastUpdate = location
        print("did update \(location.coordinate.latitude) \(location.coordinate.longitude)")
        var shouldSave = history.latestLoc == nil
        if let latest = history.latestLoc {
            let change = LocationService.distance(lat1: latest.lat, lon1: latest.lng, lat2: location.coordinate.latitude, lon2: location.coordinate.longitude)
            print("Change amount \(change)")
            print("Accuracy \(location.horizontalAccuracy)")
            shouldSave = change >= location.horizontalAccuracy
        }
        if(shouldSave) {
            history.saveLoc(loc: location,isVisit: false)
        } else {
            history.updateLoc()
        }
        if(shouldSave || !hasFence) {
            setupFence(loc: location)
        }
        locationUpdateObservers.notify(parameters: location)
    }
    
    func setupFence(loc:CLLocation) {
        hasFence = true
        let fence = CLCircularRegion(center: loc.coordinate, radius: 50, identifier: "main")
        self.locationManager.startMonitoring(for: fence)
    }
    
    func locationServicesAuthorized() {
        print("Authorised")
        self.locationManager.startUpdatingLocation()
    }
    
    func locationServicesDenied() {
        
    }
    
    func locationServicesRestricted() {
        
    }
    
    class func distance(lat1:Double,lon1:Double,lat2:Double,lon2:Double) -> Double {
        let l1 = CLLocation(latitude: lat1, longitude: lon1)
        let l2 = CLLocation(latitude: lat2, longitude: lon2)
        
        return l1.distance(from: l2)
    }
    
}
