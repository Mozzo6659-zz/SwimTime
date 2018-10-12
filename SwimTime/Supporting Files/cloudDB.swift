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

class cloudDB {
    
    var pitems : [String : Any] = [:] //this is used everywhere
    
    func getURL(serviceendPoint: String) -> String {
        return  "https://hammerheadsoftware.com.au/swimclubws2/api/SwimClub/" + serviceendPoint
    }
    
    func getJSONHeader() -> [String:String] {
        let header = [
            "Content-Type" : "application/json"
        ]
        return header
    }
    
    func addClubs(endPoint: String) {
        let realm = try! Realm()
        
        // endPoin = /AddClubList"
        
        let sURL = getURL(serviceendPoint: endPoint)
        
        let header = getJSONHeader()
        
        //making a dictionary wiht a key of "data" and an array of the objects that match my web service
        
       
        let sc = Array(realm.objects(SwimClub.self).filter("webID=0"))
        
        if sc.count != 0 {
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
                            self.updatenewMembers(result: resultJSON)
                            //print(resultJSON)
                    }else {
                            print("Error:\(response.result.error!)")
                    
                    }
                }
            }
    }
    
    func updatenewMembers(result: JSON) {
        let realm = try! Realm()
        
        //weatherData.city = result["name"].stringValue
        //weatherData.condition = result["weather"][0]["id"].intValue
        
//        "remoteid": 1,
//        "webidid": 3,
//        "errormsg": ""
        var index = 0
        var clubids : [Int] = []
        var webids : [Int] = []
        
        for _ in result {
            let webid = result[index]["remoteid"].intValue
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
