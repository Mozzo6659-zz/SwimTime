//
//  EventList.swift
//  SwimTime
//
//  Created by Mick Mossman on 4/10/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation

class EventList {
//    var eventID = 0
//    var dualMeetID = 0
//    var location = ""
   var eventDate = Date() //isolate this so i can sort
//    var distance = 0
    var event = Event()
    var dualMeet = DualMeet()
    
    func isDualMeet() -> Bool {
        return dualMeet.dualMeetID != 0
    }
    
    func isEvent() -> Bool {
        return event.eventID != 0
    }
}
