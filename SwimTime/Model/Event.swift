//
//  Event.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class Event : Object {
    @objc dynamic var eventID : Int = 0
    @objc dynamic var webID : Int = 0
    @objc dynamic var dataChanged : Bool = false
    @objc dynamic var eventDate : Date = Date()
    @objc dynamic var eventName : String = ""
    @objc dynamic var eventLocation : String = ""
    @objc dynamic var isFinished : Bool = false
    @objc dynamic var eventDistance : Int = 0
    @objc dynamic var ageFilterMin : Int = 0
    @objc dynamic var ageFilterMax : Int = 0
    @objc dynamic var genderFilter : String = ""
    let eventResults = List<EventResult>()
    
    func getAgeFilter() -> String {
        var sFilter = ""
        
        if (ageFilterMin != 0 || ageFilterMax != 0) {
            if ageFilterMin == ageFilterMax {
                sFilter = "\(ageFilterMin) years only"
            }else{
                sFilter = "Ages \(ageFilterMin) to \(ageFilterMax)"
            }
            
        }
        return sFilter
    }
}
