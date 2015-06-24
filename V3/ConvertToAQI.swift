//
//  ConvertToAQI.swift
//  V3
//
//  Created by Mohak Nahta  on 6/22/15.
//  Copyright (c) 2015 Speck Sensor. All rights reserved.
//

import Foundation

//this takes in a PM value and converts to AQI
class ConvertToAQI {
    
    var pmValue: Double
    var AQI: Int = 0
    var category: String = ""
    
    init(pmValue: Int){
        if (pmValue < 0){
            self.pmValue = 0.0
        }
        else{
            self.pmValue = Double(pmValue)
        }
        self.AQI = convert()
        self.category = findAQICategory()
    }
    
    //MARK: - convert() converts the pm 2.5 value to AQI 
    //documentation of the formuala: http://www.epa.gov/ttn/oarpg/t1/memoranda/rg701.pdf
    func convert() -> Int {
        var Ihi: Double = Double(getIhi())
        var Ilo: Double = Double(getIlo())
        var BPlo: Double = getBPlo()
        var BPhi: Double = getBPhi()
        
        var Ip1 = (Ihi - Ilo)/(BPhi - BPlo)
        var Ip2 = (Ip1) * (pmValue - BPlo)
        var Ip = Ip2 + Ilo
        return Int(round(Ip))
    }
    
    func getIhi() -> Int{
        var Ihi: Int
        switch pmValue {
        case 0.0...15.4:
            Ihi = 50
        case 15.5...40.4:
            Ihi = 100
        case 40.5...65.4:
            Ihi = 150
        case 65.5...150.4:
            Ihi = 200
        case 150.5...250.4:
            Ihi = 300
        case 250.5...350.4:
            Ihi = 400
        case 350.5...500.4:
            Ihi = 500
        default:
            Ihi = 0
        }
        return Ihi
    }
    
    func getIlo() -> Int{
        var Ilo: Int
        switch pmValue {
        case 0.0...15.4:
            Ilo = 0
        case 15.5...40.4:
            Ilo = 51
        case 40.5...65.4:
            Ilo = 101
        case 65.5...150.4:
            Ilo = 151
        case 150.5...250.4:
            Ilo = 201
        case 250.5...350.4:
            Ilo = 301
        case 350.5...500.4:
            Ilo = 401
        default:
            Ilo = 0
        }
        return Ilo
    }
    
    func getBPlo() -> Double{
        var BPlo: Double
        switch pmValue {
        case 0.0...15.4:
            BPlo = 0.0
        case 15.5...40.4:
            BPlo = 15.5
        case 40.5...65.4:
            BPlo = 40.5
        case 65.5...150.4:
            BPlo = 65.5
        case 150.5...250.4:
            BPlo = 150.5
        case 250.5...350.4:
            BPlo = 250.5
        case 350.5...500.4:
            BPlo = 350.5
        default:
            BPlo = 0.0
        }
        return BPlo
    }

    func getBPhi() -> Double{
        var BPhi: Double
        switch pmValue {
        case 0.0...15.4:
            BPhi = 15.4
        case 15.5...40.4:
            BPhi = 40.4
        case 40.5...65.4:
            BPhi = 65.4
        case 65.5...150.4:
            BPhi = 150.4
        case 150.5...250.4:
            BPhi = 250.4
        case 250.5...350.4:
            BPhi = 350.4
        case 350.5...500.4:
            BPhi = 500.4
        default:
            BPhi = 0.0
        }
        return BPhi
    }
    
    //MARK: - finds the AQI category - good, moderate, abd, etc. based on the index of pollution
    func findAQICategory() -> String{
        var category: String
        switch self.AQI{
        case 0...50:
            category = "Good"
        case 51...100:
            category = "Moderate"
        case 101...150:
            category = "Unhealthy for Sensitive Groups"
        case 151...200:
            category = "Unhealthy"
        case 201...300:
            category = "Very Unhealthy"
        case 301...10000:
            category = "Hazardous"
        default:
            category = "NA"
        }
        return category
    }

}