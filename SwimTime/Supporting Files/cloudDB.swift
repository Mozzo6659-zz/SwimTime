//
//  cloudDB.swift
//  SwimTime
//
//  Created by Mick Mossman on 9/10/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//class to handle my web database transfers

import Foundation
import SwiftyJSON
import Alamofire
import RealmSwift
import SVProgressHUD

class cloudDB {
    
    let resultIndMember = "Members"
    let resultIndClub = "Clubs"
    
    
    let myfunc = appFunctions()
    var pitems : [String : Any] = [:] //this is used everywhere
    var params: [String:Any] = [:] //this is passed to the web service
    
    var returnVals = [(remoteid: 0, webid: 0)]
    
    //MARK:- Service stuff
    func getURL(serviceendPoint: String) -> String {
        return  "https://hammerheadsoftware.com.au/swimclubws2/api/" + serviceendPoint
    }
    
    func getJSONHeader() -> [String:String] {
        let header = [
            "Content-Type" : "application/json"
        ]
        return header
    }
    
    
    
    
    //MARK:- Progress
    
    func startProgress(pmsg: String = "Uploading...") {
        SVProgressHUD.show(withStatus: pmsg)
        
    }
    
    func dismissProgress() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
        
        
        
    }
    
    //MARK: - Uploads
    
    func uploadData() {
        uploadClubs()
        uploadMembers()
        
        
        processUpload()
    }
    
    func processUpload() {
        let endPoint = "AddAll"
        
        let sURL = getURL(serviceendPoint: endPoint)
        
        let header = getJSONHeader()
        Alamofire.request(sURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON {response in
            if response.result.isSuccess {
                let resultJSON : JSON = JSON(response.result.value!)
                self.updateWebIds(result: resultJSON)
                self.dismissProgress()
            }else {
                print("Error:\(response.result.error!)")
                
            }
        }
        
    }
    
    func uploadMembers() {
        let realm = try! Realm()
        
        
        let mymems = Array(realm.objects(Member.self).filter("webID=0 OR dataChanged=true"))
        //print("\(mymems.count)")
        pitems.removeAll()
        
        if mymems.count != 0 {
            startProgress()
            
            var pArray : [[String:Any]] = []
            
            
            for mem in mymems {
                pitems.removeAll()
                pitems["memberid"] = mem.webID
                pitems["remoteid"] = mem.memberID
                pitems["membername"] = mem.memberName
                //pitems["swimclubid"] = 1 testing
                pitems["gender"] = mem.gender
                if let sc = mem.myClub.first {
                    pitems["swimclubid"] = sc.webID
                    pitems["swimclubremoteid"] = sc.clubID
                }
                pitems["dateofbirth"] = myfunc.formatDate(thedate: mem.dateOfBirth, theformat:"yyyy-MM-dd")
                pitems["onekseconds"] = mem.onekSeconds
                pitems["emailaddress"] = mem.emailAddress
                pitems["groupid"] = 0
                
                pArray.append(pitems)
                
                
            }
            
            
            params["Members"] = pArray
            
            
        }
    }
    func uploadClubs() {
        let realm = try! Realm()
        
       
        
        let sc = Array(realm.objects(SwimClub.self).filter("webID=0"))
        
        if sc.count != 0 {
            startProgress()
            var pArray : [[String:Any]] = []
            
            
            for scb in sc {
                pitems.removeAll()
                pitems["swimclubid"] = scb.webID
                pitems["remoteid"] = scb.clubID
                pitems["swimclubname"] = scb.clubName
                pArray.append(pitems)
                
                
            }
            params["Clubs"] = pArray
        }
            
            
    }
    
    //MARK:- Data Update
    func updateWebIds(result: JSON) {
        //this stamps the webids ont to local data
        if getUpdateIdsfromJSON(rawJSON: result, thekey: resultIndClub) {
            updateNewClubs()
        }
        
        if getUpdateIdsfromJSON(rawJSON: result, thekey: resultIndMember) {
            updateNewMembers()
        }
    }
    
    func getUpdateIdsfromJSON(rawJSON: JSON,thekey:String) -> Bool {
        
        var bFound = false
        var index = 0
        
//        switch self.json.type {
//        case .array:
//            for (index,subJson):(String, JSON) in self.json {
//                // Do something you want
//            }
//        case .dictionary:
//            for (key,subJson):(String, JSON) in self.json {
//                // Do something you want
//            }
//        default:
//            // Do some error handling
//        }
        returnVals.removeAll()
        
        for _ in rawJSON {
            if rawJSON[index]["rettype"].stringValue == thekey {
                if !rawJSON[index]["errormsg"].stringValue.isEmpty {
                    returnVals.append((remoteid: rawJSON[index]["remoteid"].intValue, webid: rawJSON[index]["webid"].intValue))
                    bFound = true
                }else{
                    //should workout something for errors. Maybe a new Realm table ??
                }
            }
            
            index += 1
        }
        return bFound
        
    }
    func updateNewMembers() {
        let realm = try! Realm()
        
        
        if returnVals.count != 0 {
            
            //let members = realm.objects(Member.self).filter("memberID IN %@",memids)
            let members = Array(realm.objects(Member.self))
            do {
                try realm.write {
                    for val in returnVals {
                        let mem = members.filter({$0.memberID == val.remoteid}).first
                        
                        mem?.webID = val.webid
                        mem?.dataChanged = false
                    }
                }
            }catch{
                print(error)
            }
        }
    }

    
    func updateNewClubs() {
        let realm = try! Realm()
        
        if returnVals.count != 0 {
            
            let clubs = realm.objects(SwimClub.self)
            
            do {
                try realm.write {
                   
                    for val in returnVals {
                        let club = clubs.filter({$0.clubID == val.remoteid}).first
                            
                        club?.webID = val.webid
                           
                    }
                    
                }
            }catch{
                print(error)
            }
        }
    }

}
