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
    var nextEventId = 1
    var defaults = UserDefaults.standard
    let nextMemberKey = "NextMemberID"
    let nextEventKey = "NextEventID"
    
    func getNextMemberId() -> Int {
        
        var nextMemberId : Int = 1
        
        if let defMemberId  = defaults.object(forKey: nextMemberKey) as? Int {
            nextMemberId = defMemberId + 1
        }

        
        defaults.set(nextMemberId, forKey: nextMemberKey)
        
        return nextMemberId
    }
    
    func getNextEventId() -> Int {
        
        var nextEventId : Int = 1
        
        if let defEventId  = defaults.object(forKey: nextEventKey) as? Int {
            nextEventId = defEventId + 1
        }
        
        
        defaults.set(nextEventId, forKey: nextEventKey)
        
        return nextEventId
    }
}
