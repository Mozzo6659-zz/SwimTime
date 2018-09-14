//
//  PresetEventExtension.swift
//  SwimTime
//
//  Created by Mick Mossman on 13/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//
//This cass helps the event controller control members entry and give the points
//back to the event controller

import Foundation

class PresetEventExtension {
    var presetEvent = PresetEvent()
    var raceMembers = [PresetEventMember]()
    var raceClubs = [SwimClub]()
    
    func addClub(swimClub:SwimClub) -> Bool {
        var ok = false
        
        if presetEvent.maxClubs > 0 {
            
        
            if raceClubs.count < presetEvent.maxClubs {
                raceClubs.append(swimClub)
                ok = true
            }else{
                if let mxm = raceClubs.index(where: {$0.clubID == swimClub.clubID}) {
                    
                    ok = (mxm != -1) //doin this so i dont get the yellow warning. Its gonna be 0 or 1 if its there
                }
                
            }
        } else {
            raceClubs.append(swimClub)
            ok = true
        }
        
        return ok
    }
    
    func validateCanEnterMember(member:Member, category:PresetEventAgeGroups?) -> String {
        var errmsg = ""
        let swmclb = member.myClub.first! //I know its there
        if addClub(swimClub: swmclb) {
            if presetEvent.maxPerEvent != 0 {
                if raceMembers.count == presetEvent.maxPerEvent {
                    errmsg = "Race has reach capacity of \(presetEvent.maxPerEvent)"
                }
            }
            
            if errmsg == "" {
                if presetEvent.maxPerClub != 0 {
                    if getHowmanyFromClub(clubid: swmclb.clubID) == presetEvent.maxPerClub {
                        errmsg = "Race has reached capacity for your team of \(presetEvent.maxPerClub)"
                    }
                }
            }
            
            if errmsg == "" {
                if presetEvent.maxPerGenderAndAgeGroup != 0 {
                    if getHowmanyFromGenderAgeGroup(categoryid: category!.presetAgeGroupID, thisgender: member.gender,clubid:swmclb.clubID) == presetEvent.maxPerGenderAndAgeGroup {
                        errmsg = "Race has reached capacity for your team, gender and category of \(presetEvent.maxPerGenderAndAgeGroup)"
                    }
                }
            }
            
        }else{
            errmsg = "Cannot add another club to the race"
        }
        return errmsg
    }
    
    func getHowmanyFromClub(clubid:Int) -> Int {
        return raceMembers.filter({$0.clubID == clubid}).count
    }
    
    func getHowmanyFromGenderAgeGroup(categoryid:Int,thisgender:String,
                                      clubid:Int) -> Int {
        return raceMembers.filter({$0.gender == thisgender && $0.PresetAgeGroup.presetAgeGroupID == categoryid && $0.clubID == clubid}).count
    }
    
    func addMember(mem:Member,cat:PresetEventAgeGroups?,ageatEvent:Int,relayLetter:String = "",relayOrder:Int, withValidate:Bool) -> String {
        var errmsg = ""
        
        if withValidate {
            errmsg = validateCanEnterMember(member: mem, category: cat)
        }
        
        if errmsg == "" {
            let newmem = PresetEventMember()
            newmem.memberid = mem.memberID
            newmem.ageAtEvent = ageatEvent
            newmem.gender = mem.gender
            newmem.clubID = mem.myClub.first!.clubID
            if let thiscat = cat {
                newmem.PresetAgeGroup = thiscat
            }
            newmem.relayLetter = relayLetter
            newmem.relayOrder = relayOrder
            raceMembers.append(newmem)
            
        }
        
        return errmsg
    }
    
    //MARK: - Points calculations
    
    func getPointsforMember(memid:Int) -> Int {
        var pts = 0
        
        if presetEvent.useScoring {
            if presetEvent.isRelay {
                pts = getPointsRelay()
            }else{
                pts = getPointsSingle()
            }
        }
        
        
       return pts
    }
    
    func getPointsSingle() -> Int {
        return 0
    }
    
    func getPointsRelay() -> Int {
        return 0
    }
    
}
