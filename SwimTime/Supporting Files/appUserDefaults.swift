//
//  appUserDefaults.swift
//  SwimTime
//
//  Created by Mick Mossman on 2/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift
class appUserDefaults {
    //var nextMemberId = 0
    let realm = try! Realm()
    
    var defaults = UserDefaults.standard
    let nextMemberKey = "NextMemberID"
    let nextEventKey = "NextEventID"
    let nextDualMeetKey = "NextDualMeetID"
    let nextEventResultKey = "NextEventResultID"
    let nextRaceNoKey = "NextRaceNo"
    let nextTeamNoKey = "NextTeamNo"
    let nextClubIDKey = "NextClubID"
    let runningEventIDKey = "runningEventID"
    let runningEventStopDate = "runningEventStopDate"
    let runningEventSecondsStopped = "runningEventSeconds"
    let nextPresetAgeGroupID = "NextPesetAgeGroupId"
    
    
    func setRunningEventID(eventID : Int) {
        
        defaults.set(eventID, forKey: runningEventIDKey)
    }
    
    func getRunningEventID() -> Int {
        var eventID : Int = 0
         if let defId  = defaults.object(forKey: runningEventIDKey) as? Int {
            eventID = defId
        }
        
        return eventID
            
    }
    func setRunningEevntStopDate(stopDate:Date) {
        defaults.set(stopDate, forKey: runningEventStopDate)
    }
    
    func getRunningEventStopDate() -> Date {
        var retDate : Date = Date()
        if let defId  = defaults.object(forKey: runningEventStopDate) as? Date {
            retDate = defId
        }
        return retDate
    }
    
    func setRunningEventSecondsStopped(clockseconds : Int) {
        
        defaults.set(clockseconds, forKey: runningEventSecondsStopped)
    }
    
    func getRunningEventSecondsStopped() -> Int {
        var seconds : Int = 0
        if let defId  = defaults.object(forKey: runningEventSecondsStopped) as? Int {
            seconds = defId
        }
        
        return seconds
        
    }
    
    func getNextId(thisKey : String, defaulStart:Int = 1) -> Int {
        var nextId : Int = defaulStart
        if let defId  = defaults.object(forKey: thisKey) as? Int {
            nextId = defId + 1
        }
        
        
        defaults.set(nextId, forKey: thisKey)
        
        return nextId
        
    }
    func setNextMemberID(memid:Int) {
        defaults.set(memid, forKey: nextMemberKey)
    }
    func getNextMemberId() -> Int {
        
        return getNextId(thisKey: nextMemberKey)
    }
    
    func getNextClubId() -> Int {
        
        return getNextId(thisKey: nextClubIDKey)
    }
    func getNextEventId() -> Int {
         return getNextId(thisKey: nextEventKey)
       
    }
    func getNextDualMeetId() -> Int {
        return getNextId(thisKey: nextDualMeetKey)
        
    }
    func getNextEventResultId() -> Int {
        return getNextId(thisKey: nextEventResultKey)
        
    }
    func getNextRaceNo() -> Int {
        return getNextId(thisKey: nextRaceNoKey, defaulStart: 100)
        
    }
    func getNextTeamNo() -> Int {
        return getNextId(thisKey: nextTeamNoKey)
        
    }
    
    func getNextPresetAgeGroupID() -> Int {
        return getNextId(thisKey: nextPresetAgeGroupID)
        
    }
    func getDefSwimClub() -> SwimClub {
        let scArray : Results<SwimClub> = realm.objects(SwimClub.self).filter("isDefault = true")
        return scArray.first!
    }
}
