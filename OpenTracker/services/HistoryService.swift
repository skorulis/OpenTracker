//  Created by Alexander Skorulis on 1/12/16.
//  Copyright © 2016 Alexander Skorulis. All rights reserved.

import CoreLocation
import CoreData
import PromiseKit

@objc fileprivate enum OperationState: Int {
    case ready
    case executing
    case finished
}

private class HistoryAsyncOperation<T>: Operation {
    
    @objc private var _state = OperationState.ready
    
    
    let promiseBlock:() -> Promise<T>
    
    init(promiseBlock:@escaping () -> Promise<T>) {
        self.promiseBlock = promiseBlock
        super.init()
    }
    
    override func start() {
        _state = .executing
        let promise = promiseBlock()
        _ = promise.ensure { [weak self] in
            self?._state = .finished
        }
    }
    
    
    override func main() {
        
    }
    
    public override var isExecuting: Bool {
        return _state == .executing
    }
    
    public override var isFinished: Bool {
        return _state == .finished
    }
    
    open override var isReady: Bool {
        return super.isReady && _state == .ready
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady",  "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(_state)]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }

    
}

class HistoryService {

    private let db:DatabaseService
    private let serialQueue = DispatchQueue(label: "historyQueue")
    private let operationQueue:OperationQueue
    
    var latestLoc:TrackLoc?

    init(db:DatabaseService) {
        self.db = db
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
        fetchLatest()
    }
    
    private func fetchLatest() {
        let fetch:NSFetchRequest<TrackLoc> = TrackLoc.fetchRequest()
        fetch.fetchLimit = 1
        fetch.sortDescriptors = [NSSortDescriptor(key: "lastTime", ascending: false)]
        latestLoc = try! db.mainContext.fetch(fetch).first
    }
    
    func saveLoc(loc:CLLocation, isVisit:Bool) {
        print("add location \(self)")
        
        let promiseBlock = {return self.saveLocLocal(loc: loc, isVisit: isVisit)}
        let operation = HistoryAsyncOperation(promiseBlock: promiseBlock)
        self.operationQueue.addOperation(operation)
    }
    
    private func saveLocLocal(loc:CLLocation, isVisit:Bool) -> Promise<NSManagedObjectID> {
        let ctx = db.mainContext.childContext()
        let (promise,seal) = Promise<NSManagedObjectID>.pending()
        ctx.perform {
            let dbItem = TrackLoc(context: ctx)
            dbItem.firstTime = NSDate()
            dbItem.lastTime = NSDate()
            dbItem.lat = loc.coordinate.latitude
            dbItem.lng = loc.coordinate.longitude
            dbItem.visit = isVisit
            
            ctx.saveRecursively(completion: { (error) in
                if let error = error {
                    seal.reject(error)
                } else {
                    self.latestLoc = self.db.mainContext.object(with: dbItem.objectID) as? TrackLoc
                    seal.fulfill(dbItem.objectID)
                }
            })
        }
        return promise
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
