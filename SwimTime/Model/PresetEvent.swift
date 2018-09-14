//
//  PresetEvent.swift
//  SwimTime
//
//  Created by Mick Mossman on 12/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class PresetEvent : Object {
    @objc dynamic var presetEventID : Int = 0
    @objc dynamic var distance : Int = 0
    @objc dynamic var isRelay : Bool = false
    @objc dynamic var maxClubs : Int = 0
    @objc dynamic var maxPerEvent : Int = 0
    @objc dynamic var maxPerGenderAndAgeGroup : Int = 0
    @objc dynamic var maxPerClub : Int = 0
    @objc dynamic var maxPerRelay : Int = 0
    @objc dynamic var maxRelays : Int = 0
    @objc dynamic var useScoring : Bool = false
    
    let eventAgeGroups = List<PresetEventAgeGroups>()
    
    func getPresetName() -> String {
        var retVal : String = ("\(distance) mtrs")
        if isRelay {
            retVal = retVal + " Relay"
        }
        return retVal
    }
}
