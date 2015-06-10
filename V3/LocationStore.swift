//
//  LocationStore.swift
//  V3
//
//  Created by Mohak Nahta  on 6/9/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import Foundation

class LocationStore {
    class var sharedInstance: LocationStore {
        struct Static {
            static let instance = LocationStore()
        }
        return Static.instance
    }
    
    var locations: [LocationForList] = []
    
    func add(locationNameAndID: LocationForList) {
        println("locations list is \(locations)")
        locations.append(locationNameAndID)
    }
    
    func replace(locationNameAndID: LocationForList, atIndex index: Int) {
        locations[index] = locationNameAndID
    }
    
    func get(index: Int) -> LocationForList {
        return locations[index]
    }
    
    func removeTaskAtIndex(index: Int) {
        locations.removeAtIndex(index)
    }
    
    var count: Int {
        return locations.count
    }
}