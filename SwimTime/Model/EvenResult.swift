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
    @objc dynamic var eventResultId : Int = 0
    @objc dynamic var expectedSeconds : Int = 0
    @objc dynamic var resultSeconds : Int = 0
    @objc dynamic var rawresultSeconds : Int = 0 //without a stagger
    @objc dynamic var pointsEarned : Int = 0
    @objc dynamic var staggerStartBy : Int = 0
    @objc dynamic var raceNo : Int = 0
    @objc dynamic var relayNo : Int = 0
    @objc dynamic var activeForRelay : Bool = false //used ina realy to know whos racing currently
     @objc dynamic var relayOrder : Int = 0
     @objc dynamic var ageAtEvent : Int = 0
    @objc dynamic var diffSeconds : Int = 0
    
    //for reporting Im gonna need this. Chad can put you in any category regardless of how old you are. Im using a lits raher than a blank object. A lst can be empty whihc is fine for this purpose
    var selectedAgeCategory = List<PresetEventAgeGroups>()
    
   
    
    let myMember = LinkingObjects(fromType: Member.self, property: "eventResults")
    
    let myEvent = LinkingObjects(fromType: Event.self, property: "eventResults")
    
    func getRelayLetter() -> String {
        var strLetter = ""
        switch relayNo {
        case 1 :
            strLetter = "A"
            break
        case 2 :
            strLetter = "B"
            break
        case 3 :
            strLetter = "C"
            break
        case 4 :
            strLetter = "B"
            break
            
        default :
            break
            
        }
        return strLetter
    }
    func getRelayOrder() -> String {
        
        return String(format:"%@%d",getRelayLetter(),relayNo)
    }
//    func ageCategoryName() -> String {
//        if let ag = selectedAgeCategory.first {
//            return ag.presetAgeGroupName
//        }else{
//            return ""
//        }
//    }
//    func ageCategoryID() -> Int {
//        if let ag = selectedAgeCategory.first {
//            return ag.presetAgeGroupID
//        }else{
//            return 0
//        }
//    }
//    func memGender() -> String {
//        if let mem = myMember.first {
//            return mem.gender
//        }else{
//            return ""
//        }
//    }
}
