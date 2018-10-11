//  Created by Alexander Skorulis on 1/12/16.
//  Copyright © 2016 Alexander Skorulis. All rights reserved.

import CoreLocation
import CoreData

class HistoryService {

    private let db:DatabaseService
    var latestLoc:TrackLoc?

    init(db:DatabaseService) {
        self.db = db
    }
    
    func saveLoc(loc:CLLocation, isVisit:Bool) {
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
    
    func getHistory() -> NSFetchRequest<TrackLoc> {
        let fetch:NSFetchRequest<TrackLoc> = TrackLoc.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "firstTime", ascending: false)]
        return fetch
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
