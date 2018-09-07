//
//  appUserDefaults.swift
//  SwimTime
//
//  Created by Mick Mossman on 2/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation

class appUserDefaults {
    //var nextMemberId = 0
    
    var defaults = UserDefaults.standard
    let nextMemberKey = "NextMemberID"
    let nextEventKey = "NextEventID"
    let nextRaceNoKey = "NextRaceNo"
    let nextTeamNoKey = "NextTeamNo"
    
    func getNextId(thisKey : String, defaulStart:Int = 1) -> Int {
        var nextId : Int = defaulStart
        if let defId  = defaults.object(forKey: thisKey) as? Int {
            nextId = defId + 1
        }
        
        
        defaults.set(nextId, forKey: thisKey)
        
        return nextId
        
    }
    func getNextMemberId() -> Int {
        
        return getNextId(thisKey: nextMemberKey)
    }
    
    func getNextEventId() -> Int {
         return getNextId(thisKey: nextEventKey)
       
    }
    
    func getNextRaceNo() -> Int {
        return getNextId(thisKey: nextRaceNoKey, defaulStart: 100)
        
    }
    func getNextTeamNo() -> Int {
        return getNextId(thisKey: nextTeamNoKey)
        
    }
}
