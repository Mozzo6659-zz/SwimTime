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
    @objc dynamic var dualMeetID : Int = 0
    @objc dynamic var dataChanged : Bool = false
    @objc dynamic var useRaceNos : Bool = false
    @objc dynamic var usePoints : Bool = false
    @objc dynamic var eventDate : Date = Date()
    @objc dynamic var eventName : String = ""
    @objc dynamic var eventLocation : String = ""
    @objc dynamic var isFinished : Bool = false
    @objc dynamic var eventDistance : Int = 0
    @objc dynamic var hasPresetEvent : Bool = false
    @objc dynamic var isExhibitionRelay : Bool = false //allow for an exhibiton relay event
    @objc dynamic var presetEvent : PresetEvent?
    
    let clubRelayPoints = List<Int>()
    
    let eventResults = List<EventResult>()
    //let selectedTeams = List<SwimClub>() //moved to dual meet
    let myDualMeet = LinkingObjects(fromType: DualMeet.self, property: "selectedEvents")
    
    func getRaceName() -> String {
        if let pse = presetEvent {
            return pse.getPresetName()
        }else{
            return String(format:"%d mtrs",eventDistance)
        }
    }
    
}
