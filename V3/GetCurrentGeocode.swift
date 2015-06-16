//
//  GetCurrentGeocode.swift
//  V3
//
//  Created by Mohak Nahta  on 6/11/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import Foundation
import UIKit

struct CurrentGeocode {
    
    
    var currentLocalityArray: AnyObject
    var name: String
    var stateCode: String!
    var stateName: String!
    
    
    init(geoCodeDictionary: NSDictionary) {
        currentLocalityArray = geoCodeDictionary["geonames"]![0] as! NSDictionary
        name = currentLocalityArray["name"] as! String
        stateName = currentLocalityArray["adminName1"] as? String
        stateCode = getStateCode(stateName!)
    }
    
    func getStateCode(stateFullName: String) -> String {
        var stateCode: String
        
        switch stateFullName {
        case "Alabama":
            stateCode = "AL"
        case "Alaska":
            stateCode = "AK"
        case "Arizona":
            stateCode = "AZ"
        case "Arkansas":
            stateCode = "AR"
        case "California":
            stateCode = "CA"
        case "Colorado":
            stateCode = "CO"
        case "Connecticut":
            stateCode = "CT"
        case "Delaware":
            stateCode = "DE"
        case "District of Columbia":
            stateCode = "DC"
        case "Florida":
            stateCode = "FL"
        case "Georgia":
            stateCode = "GA"
        case "Hawaii":
            stateCode = "HI"
        case "Idaho":
            stateCode = "ID"
        case "Illinois":
            stateCode = "IL"
        case "Indiana":
            stateCode = "IN"
        case "Iowa":
            stateCode = "IA"
        case "Kansas":
            stateCode = "KS"
        case "Kentucky":
            stateCode = "KY"
        case "Louisiana":
            stateCode = "LA"
        case "Maine":
            stateCode = "ME"
        case "Maryland":
            stateCode = "MD"
        case "Massachusetts":
            stateCode = "MA"
        case "Michigan":
            stateCode = "MI"
        case "Minnesota":
            stateCode = "MN"
        case "Mississippi":
            stateCode = "MS"
        case "Missouri":
            stateCode = "MO"
        case "Montana":
            stateCode = "MT"
        case "Nebraska":
            stateCode = "NE"
        case "Nevada":
            stateCode = "NV"
        case "New Hampshire":
            stateCode = "NH"
        case "New Jersey":
            stateCode = "NJ"
        case "New Mexico":
            stateCode = "NM"
        case "New York":
            stateCode = "NY"
        case "North Carolina":
            stateCode = "NC"
        case "North Dakota":
            stateCode = "ND"
        case "Ohio":
            stateCode = "OH"
        case "Oklahoma":
            stateCode = "OK"
        case "Oregon":
            stateCode = "OR"
        case "Pennsylvania":
            stateCode = "PA"
        case "Rhode Island":
            stateCode = "RI"
        case "South Carolina":
            stateCode = "SC"
        case "South Dakota":
            stateCode = "SD"
        case "Tennessee":
            stateCode = "TN"
        case "Texas":
            stateCode = "TX"
        case "Utah":
            stateCode = "UT"
        case "Vermont":
            stateCode = "VT"
        case "Virginia":
            stateCode = "VA"
        case "Washington":
            stateCode = "WA"
        case "West Virginia":
            stateCode = "WV"
        case "Wisconsin":
            stateCode = "WI"
        case "Wyoming":
            stateCode = "WY"
        default:
            stateCode = "US"
        }
        return stateCode
    }
}