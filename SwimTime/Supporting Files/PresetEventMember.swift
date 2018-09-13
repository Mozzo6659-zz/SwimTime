//
//  PresetEventMember.swift
//  SwimTime
//
//  Created by Mick Mossman on 13/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation

class PresetEventMember {

    var memberid : Int = 0
    var ageAtEvent : Int = 0
    var gender : String = "Male"
    var clubID : Int = 0
    var relayLetter : String = ""//(A,B,C,D)
    var relayOrder : Int = 1
    var PresetAgeGroup = PresetEventAgeGroups() //chad is gonna pick this
}
