//
//  DualMeet.swift
//  SwimTime
//
//  Created by Mick Mossman on 27/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class DualMeet : Object {
    @objc dynamic var dualMeetID : Int = 0
    @objc dynamic var dualMeetWebID : Int = 0
    @objc dynamic var meetLocation : String = ""
    @objc dynamic var meetDate : Date = Date()
    @objc dynamic var dataChanged : Bool = false
    @objc dynamic var isFinished : Bool = false
    let selectedTeams = List<SwimClub>()
    
    let selectedEvents = List<Event>()
    
}
