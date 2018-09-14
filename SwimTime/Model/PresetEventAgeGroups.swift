//
//  PresetEventAgeGroups.swift
//  SwimTime
//
//  Created by Mick Mossman on 12/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class PresetEventAgeGroups : Object {
    @objc dynamic var presetAgeGroupID : Int = 0
    @objc dynamic var presetEventID : Int = 0
    @objc dynamic var presetAgeGroupName : String = ""
    @objc dynamic var minAge : Int = 0
    @objc dynamic var maxAge : Int = 0
    @objc dynamic var useOverMinForSelect : Bool = false
    @objc dynamic var staggerSeconds : Int = 0
    
    
    
}
