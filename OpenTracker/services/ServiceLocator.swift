//
//  ServiceLocator.swift
//  OpenTracker
//
//  Created by Alexander Skorulis on 11/10/18.
//  Copyright © 2018 Alexander Skorulis. All rights reserved.
//

import Foundation

class ServiceLocator {

    static let instance = ServiceLocator()
    
    let db:DatabaseService
    let history:HistoryService
    let location:LocationService
    
    init() {
        self.db = DatabaseService()
        self.history = HistoryService(db: db)
        self.location = LocationService(history: history)
        
        self.location.start()
    }
    
}
