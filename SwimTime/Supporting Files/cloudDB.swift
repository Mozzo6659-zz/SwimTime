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
    
    let myfunc = appFunctions()
    var pitems : [String : Any] = [:] //this is used everywhere
    
    func getURL(serviceendPoint: String) -> String {
        return  "https://hammerheadsoftware.com.au/swimclubws2/api/" + serviceendPoint
    }
    
    func getJSONHeader() -> [String:String] {
        let header = [
            "Content-Type" : "application/json"
        ]
        return header
    }
    
    func addMembers() {
        let realm = try! Realm()
        
        
        let endPoint = "Member/AddMemberList"
        
        let sURL = getURL(serviceendPoint: endPoint)
        
        let header = getJSONHeader()
        let mymems = Array(realm.objects(Member.self).filter("webID=0 OR dataChanged=true"))
        //print("\(mymems.count)")
        pitems.removeAll()
        
        if mymems.count != 0 {
            startProgress()
            
            var pArray : [[String:Any]] = []
            var params: [String:Any] = [:]
            
            for mem in mymems {
                pitems.removeAll()
                pitems["memberid"] = mem.webID
                pitems["remoteid"] = mem.memberID
                pitems["membername"] = mem.memberName
                //pitems["swimclubid"] = 1 testing
                pitems["gender"] = mem.gender
                if let sc = mem.myClub.first {
                    pitems["swimclubid"] = sc.webID
                }
                pitems["dateofbirth"] = myfunc.formatDate(thedate: mem.dateOfBirth, theformat:"yyyy-MM-dd")
                pitems["onekseconds"] = mem.onekSeconds
                pitems["emailaddress"] = mem.emailAddress
                pitems["groupid"] = 0
                
                pArray.append(pitems)
                
                
            }
            
            
            params["data"] = pArray
            //use this JSON in postman of any issues
//            let myJSON = JSON(params)
//
//            print(myJSON)

            
            
            Alamofire.request(sURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON {response in
                if response.result.isSuccess {
                    let resultJSON : JSON = JSON(response.result.value!)
                    self.updateNewMembers(result: resultJSON)
                    self.dismissProgress()
                }else {
                    print("Error:\(response.result.error!)")
                    
                }
            }
        
        }
    }
    
    func startProgress(pmsg: String = "Uploading...") {
        SVProgressHUD.show(withStatus: pmsg)
        
    }
    
    func dismissProgress() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
        
        
        
    }
    
    func addClubs() {
        let realm = try! Realm()
        
        let endPoint = "SwimClub/AddClubList"
        
        let sURL = getURL(serviceendPoint: endPoint)
        
        let header = getJSONHeader()
        
        //making a dictionary wiht a key of "data" and an array of the objects that match my web service
        
       pitems.removeAll()
        
        let sc = Array(realm.objects(SwimClub.self).filter("webID=0"))
        
        if sc.count != 0 {
            startProgress()
            var pArray : [[String:Any]] = []
            var params: [String:Any] = [:]
            
            for scb in sc {
                pitems.removeAll()
                pitems["swimclubid"] = scb.webID
                pitems["remoteid"] = scb.clubID
                pitems["swimclubname"] = scb.clubName
                pArray.append(pitems)
                
                
            }
            params["data"] = pArray
            
            
            Alamofire.request(sURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON {response in
                    if response.result.isSuccess {
                            let resultJSON : JSON = JSON(response.result.value!)
                            self.updateNewClubs(result: resultJSON)
                            self.dismissProgress()
                            //maybe here add new members ??
                            //print(resultJSON)
                    }else {
                            print("Error:\(response.result.error!)")
                    
                    }
                }
            }
    }
    func updateNewMembers(result: JSON) {
        let realm = try! Realm()
        
        
        var index = 0
        var memids : [Int] = []
        var webids : [Int] = []
        
        for _ in result {
            let webid = result[index]["webid"].intValue
            let memberid = result[index]["remoteid"].intValue
            //print("webid=\(webid )memid=\(memberid)")
            if webid != 0 {
                memids.append(memberid)
                webids.append(webid)
            }else{
                print(result[index]["errormsg"])
            }
            
            index += 1
        }
        
        if memids.count != 0 {
            index = 0
            let members = realm.objects(Member.self).filter("memberID IN %@",memids)
            
            do {
                try realm.write {
                    for mem in members {
                        if let idx = webids.index(where: {$0 == mem.memberID}) {
                            mem.webID = webids[idx]
                            mem.dataChanged = false
                        }
                        
                    }
                }
            }catch{
                print(error)
            }
        }
    }

    
    func updateNewClubs(result: JSON) {
        let realm = try! Realm()
        
        
        var index = 0
        var clubids : [Int] = []
        var webids : [Int] = []
        
        for _ in result {
            let webid = result[index]["webid"].intValue
            if webid != 0 {
                clubids.append(result[index]["remoteid"].intValue)
                webids.append(webid)
            }
            
            index += 1
        }
        
        if clubids.count != 0 {
            index = 0
            let clubs = realm.objects(SwimClub.self).filter("clubID IN %@",clubids)
            
            do {
                try realm.write {
                    for club in clubs {
                        if let idx = webids.index(where: {$0 == club.clubID}) {
                            club.webID = webids[idx]
                        }
                        
                    }
                }
            }catch{
                print(error)
            }
        }
    }

}
