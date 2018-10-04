//
//  seedDatabase.swift
//  SwimTime
//
//  Created by Mick Mossman on 12/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class seedDatabase {
    let realm = try! Realm()
    var lastmemid = 0
    let myDefs = appUserDefaults()
    
    //MARK: - Preset Events
    func addThesePresetEvents() {
        let myevents = realm.objects(PresetEvent.self)
        
        if myevents.count == 0 {
            for i in 1...4 {
                addPresetAgeGroups(eventId: i)
                switch i {
                case 1:
                    add125Event(eventID: i)
                case 2:
                    add500Event(eventID: i)
                case 3:
                    add1000Event(eventID: i)
                case 4:
                    add500RelayEvent(eventID: i)
                default:
                    break
                }
               
                
            }
            
        }else{
            //for testing I  gettng preset age groups being added
        }
        
    }
    
    func addPresetAgeGroups(eventId:Int) {
        switch eventId {
        case 2:
            add500AgeGroups(eventID:eventId)
            break
        case 3:
            add1000AgeGroups(eventID: eventId)
            break
          default:
            break
        }
    }
    
    /*
 @objc dynamic var presetEventID : Int = 0
 @objc dynamic var distance : Int = 0
 @objc dynamic var isRelay : Bool = false
 @objc dynamic var maxClubs : Int = 0
 @objc dynamic var maxPerEvent : Int = 0
 @objc dynamic var maxPerGenderAndAgeGroup : Int = 0
 @objc dynamic var maxPerClub : Int = 0
 @objc dynamic var maxPerRelay : Int = 0
 @objc dynamic var maxRelays : Int = 0
 */
    func add125Event(eventID:Int) {
        
        let event = PresetEvent()
        event.presetEventID = eventID
        event.distance = 125
        event.maxPerEvent = 32
        event.maxPerClub = 16
        event.maxClubs = 2
        addEventToRealm(event: event)
    }
    
    func add500Event(eventID:Int) {
        
        let event = PresetEvent()
        event.presetEventID = eventID
        event.distance = 500
        event.maxPerEvent = 40
        event.maxPerClub = 20
        event.maxPerGenderAndAgeGroup = 2
        event.maxClubs = 2
        event.useScoring = true
        addEventToRealm(event: event)
    }
    
    func add1000Event(eventID:Int) {
        
        let event = PresetEvent()
        event.presetEventID = eventID
        event.distance = 1000
        event.maxPerEvent = 40
        event.maxPerClub = 20
        event.maxPerGenderAndAgeGroup = 2
        event.maxClubs = 2
        event.useScoring = true
        addEventToRealm(event: event)
    }
    
    func add500RelayEvent(eventID:Int) {
        
        let event = PresetEvent()
        event.presetEventID = eventID
        event.distance = 500
        event.maxPerEvent = 32
        event.isRelay = true
        event.maxPerRelay = 4
        event.maxRelays = 4
        event.maxPerClub = 16
        event.maxClubs = 2
        event.useScoring = true
        addEventToRealm(event: event)
        
    }
    func addEventToRealm(event:PresetEvent) {
        let agrgrps = realm.objects(PresetEventAgeGroups.self).filter("presetEventID=\(event.presetEventID)")
        
        do {
            try realm.write {
                if agrgrps.count != 0 {
                    for ea in agrgrps {
                        event.eventAgeGroups.append(ea)
                    }
                    
                }
                realm.add(event)
            }
        }catch{
            print("Cant add events")
        }
    }
    func add500AgeGroups(eventID:Int) {
        //this is for preset 2 whihc is 125mtrs, preset = 1 does not hav ag groups
        //age groups are :  10&under ; 12&un ; 15&un ; 25& un ; 95&un
        //500m - 25's and 95's off GO  --  10&U's 12's and 15's off 2 minutes behind.
        let myageGrps = List<PresetEventAgeGroups>()
        
        let ageGrp1 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(), presetEventId: eventID, minage: 0, maxage: 10, staggerseconds: 120,agegrpName:"10 and under",useoverminforselect: false) //10 an under
        myageGrps.append(ageGrp1)
        
        let ageGrp2 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(),presetEventId: eventID, minage: 11, maxage: 12, staggerseconds: 120,agegrpName:"12 and under",useoverminforselect: false) //12 an under
        myageGrps.append(ageGrp2)
        
        let ageGrp3 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(),presetEventId: eventID, minage: 13, maxage: 15, staggerseconds: 120,agegrpName:"15 and under",useoverminforselect: false) //15 an under
        myageGrps.append(ageGrp3)
        
        let ageGrp4 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(),presetEventId: eventID, minage: 16, maxage: 25, staggerseconds: 0,agegrpName:"25 and under",useoverminforselect: false) //25 an under
        myageGrps.append(ageGrp4)
        
        let ageGrp5 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(),presetEventId: eventID, minage: 26, maxage: 95, staggerseconds: 0,agegrpName:"95 and under",useoverminforselect: false) //95 an under
        myageGrps.append(ageGrp5)
        
        addAgeGroupToRealm(agegrps: myageGrps)
        
    }
    
    func add1000AgeGroups(eventID:Int) {
        //age groups are :  5&over ; 10&over ; 12&over ; 15& over ; 25&over

        let myageGrps = List<PresetEventAgeGroups>()
        let ageGrp1 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(),presetEventId: eventID, minage: 5, maxage: 9, staggerseconds: 120,agegrpName:"5 and over",useoverminforselect: true) //10 an under
        myageGrps.append(ageGrp1)
        
        let ageGrp2 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(),presetEventId: eventID, minage: 10, maxage: 11, staggerseconds: 120,agegrpName:"10 and over",useoverminforselect: true)
        myageGrps.append(ageGrp2)
        
        let ageGrp3 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(),presetEventId: eventID, minage: 12, maxage: 14, staggerseconds: 120,agegrpName:"12 and over",useoverminforselect: true)
        myageGrps.append(ageGrp3)
        
        let ageGrp4 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(),presetEventId: eventID, minage: 15, maxage: 24, staggerseconds: 0,agegrpName:"15 and over",useoverminforselect: true)
        myageGrps.append(ageGrp4)
        
        let ageGrp5 = makeAgeGroup(id: myDefs.getNextPresetAgeGroupID(),presetEventId: eventID, minage: 25, maxage: 100, staggerseconds: 0,agegrpName:"25 and over",useoverminforselect: true)
        myageGrps.append(ageGrp5)
        
        addAgeGroupToRealm(agegrps: myageGrps)
        
    }
    //not having age groups on the relay
//    func add500RelayAgeGroups(eventID:Int) {
//        //age groups are :  10&under ; 12&un ; 15& over ; 25&over
//        let myageGrps = List<PresetEventAgeGroups>()
//        let ageGrp1 = makeAgeGroup(presetEventId: eventID, minage: 0, maxage: 10, staggerseconds: 0,agegrpName:"10 and under") //10 an under
//        myageGrps.append(ageGrp1)
//
//        let ageGrp2 = makeAgeGroup(presetEventId: eventID, minage: 11, maxage: 12, staggerseconds: 0,agegrpName:"12 and under")
//        myageGrps.append(ageGrp2)
//
//        let ageGrp3 = makeAgeGroup(presetEventId: eventID, minage: 13, maxage: 15, staggerseconds: 0,agegrpName:"15 and under") //15 an under
//        myageGrps.append(ageGrp3)
//
//        let ageGrp4 = makeAgeGroup(presetEventId: eventID, minage: 16, maxage: 25, staggerseconds: 0,agegrpName:"25 and under")
//        myageGrps.append(ageGrp4)
//
////        var ageGrp5 = PresetEventAgeGroups(presetEventId: eventID, minage: 25, maxage: 100, staggerseconds: 0,agegrpName:"25 and over")
////        myageGrps.append(ageGrp5)
//
//        addAgeGroupToRealm(agegrps: myageGrps)
//
//    }
    
    func makeAgeGroup(id:Int,presetEventId: Int, minage: Int, maxage: Int, staggerseconds: Int ,agegrpName:String,useoverminforselect:Bool) -> PresetEventAgeGroups {
        let agegrp = PresetEventAgeGroups()
        agegrp.presetAgeGroupID = id
        agegrp.presetEventID = presetEventId
        agegrp.minAge = minage
        agegrp.maxAge = maxage
        agegrp.staggerSeconds = staggerseconds
        agegrp.presetAgeGroupName = agegrpName
        agegrp.useOverMinForSelect = useoverminforselect
        return agegrp
    }
    func addAgeGroupToRealm(agegrps:List<PresetEventAgeGroups>) {
        do {
            try realm.write {
                realm.add(agegrps)
        }
        }catch{
            print("Cant add age groups")
        }
    }
    
    //MARK: - Members
    func addtheseMembers(thisclubid:Int) {
        
        let currentmembers = realm.objects(Member.self).filter("ANY myClub.clubID = %d",thisclubid)
        
        if currentmembers.count == 0 {
        
            addmember(memid: 187,memName: "Illya Vashinsky",memDOB: "2001-11-08",memGroupID: 0,email: "",oneKSeconds: 780,gender: "Male",clubid: thisclubid)
            addmember(memid: 188,memName: "Daisy Message",memDOB: "2001-06-26",memGroupID: 0,email: "",oneKSeconds: 795,gender: "Female",clubid: thisclubid)
            addmember(memid: 189,memName: "Chad Schneider",memDOB: "1973-10-31",memGroupID: 0,email: "",oneKSeconds: 870,gender: "Male",clubid: thisclubid)
            addmember(memid: 190,memName: "Ashley Goldshmidt",memDOB: "2007-04-14",memGroupID: 0,email: "deanne@intrac.com.au",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 191,memName: "Milla McKellar",memDOB: "2007-04-17",memGroupID: 0,email: "milla07@optusnet.com.au",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 192,memName: "Stephanie Sinapi",memDOB: "2005-06-23",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 193,memName: "Anthony Sinapi",memDOB: "2003-01-28",memGroupID: 0,email: "anthony@rothesayconstructions.com.au",oneKSeconds: 1200,gender: "Male",clubid: thisclubid)
            addmember(memid: 194,memName: "Susan Elliott",memDOB: "1974-01-08",memGroupID: 0,email: "susannicoleelliott@Gmail.au",oneKSeconds: 900,gender: "Female",clubid: thisclubid)
            addmember(memid: 195,memName: "Pippa Elliott",memDOB: "2012-11-16",memGroupID: 0,email: "",oneKSeconds: 3300,gender: "Female",clubid: thisclubid)
            addmember(memid: 196,memName: "Zara Elliott",memDOB: "2009-05-26",memGroupID: 0,email: "",oneKSeconds: 2400,gender: "Female",clubid: 1)
            addmember(memid: 197,memName: "Michael Elliott",memDOB: "1980-02-22",memGroupID: 0,email: "",oneKSeconds: 1500,gender: "Male",clubid: thisclubid)
            addmember(memid: 198,memName: "Grace Widowson",memDOB: "2005-10-17",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 200,memName: "Saliva Summeraver",memDOB: "2007-06-11",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 201,memName: "Ant Summeraver",memDOB: "1973-05-18",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Male",clubid: thisclubid)
            addmember(memid: 202,memName: "Rebecca Simmis",memDOB: "1975-11-17",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 203,memName: "Alexandra Coghlan",memDOB: "2005-04-06",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 204,memName: "Isabella Coghlan",memDOB: "2002-03-29",memGroupID: 0,email: "Isabella.coghlan@ariasolutions.com.au",oneKSeconds: 780,gender: "Female",clubid: thisclubid)
            addmember(memid: 206,memName: "Thomas Park",memDOB: "2007-03-24",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Male",clubid: thisclubid)
            addmember(memid: 207,memName: "Matthew Park",memDOB: "2009-09-03",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Male",clubid: thisclubid)
            addmember(memid: 208,memName: "Madison Calan",memDOB: "2007-07-31",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 209,memName: "William Calan",memDOB: "2010-05-12",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Male",clubid: thisclubid)
            addmember(memid: 210,memName: "Victoria Park",memDOB: "1972-12-06",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 211,memName: "Ben Pelican",memDOB: "2007-11-01",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Male",clubid: thisclubid)
            addmember(memid: 212,memName: "Rachel Pelikan",memDOB: "1976-02-18",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 213,memName: "Isaac Pelikan",memDOB: "2011-04-07",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Male",clubid: thisclubid)
            addmember(memid: 214,memName: "Antonia Sarcasmo",memDOB: "2009-08-09",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 215,memName: "Lucia Sarcasmo",memDOB: "2007-02-15",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 216,memName: "Emersen Stopher",memDOB: "2007-06-25",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 217,memName: "Ella Summeraver",memDOB: "2005-09-21",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 218,memName: "Zali Summeraver",memDOB: "2007-06-11",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 219,memName: "Aria Stopher",memDOB: "2004-10-13",memGroupID: 0,email: "",oneKSeconds: 1200,gender: "Female",clubid: thisclubid)
            addmember(memid: 220,memName: "Dan Stopher",memDOB: "1973-05-09",memGroupID: 0,email: "",oneKSeconds: 960,gender: "Male",clubid: thisclubid)
            //print("\(lastmemid)")
            myDefs.setNextMemberID(memid: lastmemid+1)
        }
    }
    
    func addmember(memid:Int, memName:String,memDOB:String,memGroupID:Int,email: String,oneKSeconds:Int,
                   gender:String,clubid:Int) {
        
        let defSwimCub = realm.objects(SwimClub.self).filter("clubID=\(clubid)").first
        //let groups = realm.objects(Group.self)
        var membername = memName
        var memberid = memid
        
        let dtf = DateFormatter()
        
        if clubid == 2 {
            membername = "MA" + memName
            memberid += 200
        }
        dtf.dateFormat = "yyyy-MM-dd"
        do {
            try realm.write {
                let mem = Member()
                mem.memberID = memberid
                mem.webID = memid
                mem.memberName = membername
                mem.dateOfBirth = dtf.date(from: memDOB)!
                mem.onekSeconds = oneKSeconds
                mem.emailAddress = email
                mem.gender = gender
                
                realm.add(mem)
                
//                if let idx = groups.index(where: {$0.groupID == memGroupID}) {
//                    let thisgrp = groups[idx]
//                    thisgrp.members.append(mem)
//                }
                
                defSwimCub?.members.append(mem)
                
                if memberid > lastmemid {
                    lastmemid = memberid
                }
                
            }
        }catch{
            print("Error")
        }
    
        
    }
    
    
    //MARK: - Init Swim Club
    func addInitSwimClub() {
        let clubArray : Results<SwimClub> = realm.objects(SwimClub.self)
        
        if clubArray.count == 0 {
            let defsc = SwimClub()
            let otherSwimClub = SwimClub()
            defsc.clubName = "Seas the Limit"
            defsc.clubID = myDefs.getNextClubId()
            defsc.isDefault = true
            
            otherSwimClub.clubName = "Maroubra"
            otherSwimClub.clubID = myDefs.getNextClubId()
            do {
                
                try realm.write {
                    realm.add(defsc)
                    realm.add(otherSwimClub)
                }
            }catch {
                print("Error encoding Item array")
            }
            
        }
        
        
        
    }
    
    //MARK: - Groups
    func addGroups() {
        var groupArray : Results<Group>
        
        groupArray = realm.objects(Group.self)
        
        if groupArray.count == 0 {
            addGroup(id: 0, groupname: "None")
            addGroup(id: 1, groupname: "Beginner")
            addGroup(id: 2, groupname: "Explorer")
            addGroup(id: 3, groupname: "Performer")
        }
        
    }
    
    func addGroup(id : Int,groupname : String) {
        let grp = Group()
        grp.groupID = id
        grp.groupName = groupname
        do {
            
            try realm.write {
                realm.add(grp)
            }
        }catch {
            print("Error encoding Item array")
        }
        
    }
}
