//  Created by Alexander Skorulis on 1/12/16.
//  Copyright © 2016 Alexander Skorulis. All rights reserved.

import CoreLocation

class HistoryService: NSObject {

    private let db:DatabaseService
    var latestLoc:TrackLoc?

    override init() {
        self.db = DatabaseService.instance
    }
    
    func saveLoc(loc:CLLocation,_ isVisit:Bool) {
        print("add location")
        let ctx = db.mainContext.childContext()
        ctx.perform {
            let dbItem = TrackLoc(context: ctx)
            dbItem.firstTime = NSDate()
            dbItem.lastTime = NSDate()
            dbItem.lat = loc.coordinate.latitude
            dbItem.lng = loc.coordinate.longitude
            dbItem.visit = isVisit
            
            ctx.saveRecursively(completion: { (error) in
                if error != nil {
                    self.latestLoc = self.db.mainContext.object(with: dbItem.objectID) as? TrackLoc
                }
            })
        }
    }
    
    func updateLoc() {
        print("update loc")

        self.latestLoc?.lastTime = NSDate()
        db.mainContext.saveRecursively(completion: nil)
    }
    
    /*func getHistory(from:Int64,to:Int64) -> [LocDBO] {
        var items:[LocDBO] = []
        db.inTransation { (skdb:SKDatabase) in
           items = LocDBO.findAll(skdb) as! [LocDBO]
        }
        return items
    }
    
    func totalRecords() -> Int32 {
        return db.dbQuery { (skdb) -> Any? in
            return skdb.count(LocDBO.baseStatement())
        } as! Int32
    }*/
    
}