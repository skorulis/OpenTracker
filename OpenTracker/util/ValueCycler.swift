//  Created by Alexander Skorulis on 4/12/16.
//  Copyright © 2016 Alexander Skorulis. All rights reserved.

import UIKit

class ValueCycler<Type> {

    private let values:[Type]
    private let names:[String]
    var currentIndex:Int
    var currentValue: Type {
        get {
            return values[currentIndex]
        }
    }
    var currentName:String {
        get {
            return names[currentIndex]
        }
    }
    
    init(values:[Type],names:[String]) {
        assert(values.count == names.count)
        self.values = values
        self.names = names
        currentIndex = 0
    }
    
    func next() -> Type {
        currentIndex = currentIndex + 1
        if(self.currentIndex >= values.count) {
            self.currentIndex = 0
        }
        return currentValue
    }
    
}
