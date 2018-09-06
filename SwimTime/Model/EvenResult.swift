//
//  EvenResult.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class EventResult : Object {
    @objc dynamic var expectedSeconds : Int = 0
    @objc dynamic var resultSeconds : Int = 0
    @objc dynamic var pointsEarned : Int = 0
    @objc dynamic var raceNo : Int = 0
    @objc dynamic var teamNo : Int = 0
    let myMember = LinkingObjects(fromType: Member.self, property: "eventResults")
    
    let myEvent = LinkingObjects(fromType: Event.self, property: "eventResults")
    
    func diffSeconds() -> Int {
        return expectedSeconds - resultSeconds
    }
}
