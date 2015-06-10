//
//  LocationForList.swift
//  V3
//
//  Created by Mohak Nahta  on 6/9/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

struct LocationForList {
    let description: String
    let coordinate: String
    
    init(description: String, coordinate: String) {
        self.description = description
        self.coordinate = coordinate
    }
}