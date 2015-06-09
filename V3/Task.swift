//
//  Task.swift
//  V3
//
//  Created by Mohak Nahta  on 6/9/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import Foundation

struct LocationForList {
    let description: String
    let placeID: String
    
    init(description: String, placeID: String) {
        self.description = description
        self.placeID = placeID
    }
}