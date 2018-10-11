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
    
    var pitems : [String : Any] = [:]
    
    func getURL() -> String {
        return  "https://hammerheadsoftware.com.au/swimclubws2/api/SwimClub/"
    }
    
    func addClubs() {
        let realm = try! Realm()
        
        
        let path =  "/AddClubList"
        
        let sURL = getURL() + path
        
        let header = [
            "Content-Type" : "application/json"
        ]
        //let sURL = URL(string: getURL(), relativeTo: nil)
        //let sURL = NSURL(string: getURL())!
        
        //let baseUrl = sURL as! URLConvertible
        
        
        var pArray : [[String:Any]] = []
        var params: [String:Any] = [:]
        
        //var pArray : [String:Any] = [:]
        //var params = ["swimclubid" : "", "remoteid" : "", "swimclubname" : ""]
        
        let sc = Array(realm.objects(SwimClub.self).filter("webid=0"))
        
        for scb in sc {
            pitems.removeAll()
            pitems["swimclubid"] = scb.webID
            pitems["remoteid"] = scb.clubID
            pitems["clubname"] = scb.clubName
            pArray.append(pitems)
            
            //("swimclubid" : scb.webID, "remoteid" : scb.clubID, "swimclubname" : scb.clubName)
        }
        params["data"] = pArray
            // "swimclubid":0, //this is the webid
            // "remoteid":1,
            // "swimclubname":"Seas the Limit"
        
        //params like this work
        //let params = ["swimclubid" : "0", "swimtool" : "thtool", "swimclubname"  : "fickoff"]
        //these let alamofire complie
        
        Alamofire.request(sURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON {response in

            }
        
//        Alamofire.request(URLRequest, method: .put, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
//        }
        //let ec = Alamofire.ParameterEncoding.encode(JSONEncoding.default)
        
        //let encoding = Alamofire.ParameterEncoding.encode(JSONEncoding.default)
        
        //let myRequest = encoding.encode(URLRequest, parameters: params).0
        
        
        //let myRequest = Alamofire.ParameterEncoding.encode(URLRequest, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:]))
        
        //(URLRequest, parameters: params)
        
       //let myRequest = encoding.encode(URLRequest, parameters: params).0
        
//        Alamofire.request(myRequest).responseJSON { response in
//                        if response.result.isSuccess {
//                            let weatherJSON : JSON = JSON(response.result.value!)
//                            print(weatherJSON)
//                        }else {
//                            print("Error:\(response.result.error!)")
//            
//                        }
//                    }
    }
//    func addClubs() {
//        //testing adding swim clubs using Alamofire
//
//
//
//
//               /*REST
//
// [{
//
// "swimclubid":0, //this is the webid
// "remoteid":1,
// "swimclubname":"Seas the Limit"
//
// },
// {
//
// "swimclubid":0,
// "remoteid":2,
// "swimclubname":"Botany"
// }]
//*/
//        let realm = try! Realm()
//
//        let sURL = getURL() + "/AddClubList"
////        var params = "[{\n"
////        params = params + "\"swimclub\":0,\n"
////        params = params + "\"remoteid\":1,\n"
////        params = params + "\"swimclubname\":\"Seas the Limit\",\n"
////        params = params + "},\n"
////        params = params + "{\n"
////        params = params + "\"swimclub\":0,\n"
////        params = params + "\"remoteid\":2,\n"
////        params = params + "\"swimclubname\":\"Botany\",\n"
////        params = params + "}]"
////
//        let params = realm.objects(SwimClub.self).filter("webid=0")
//
//         //print(params)
//
//        //Alamofire.request(sURL)
////                Alamofire.request(params).responseJSON {
////                    response in
////                    if response.result.isSuccess {
////                        let respJSON : JSON = JSON(response.result.value!)
////                        print("\(respJSON)")
////                    }else {
////                        print("Error:\(response.result.error!)")
////
////                    }
////                }
//        //Alamofire.request(sURL, method: .post, parameters: params).responseString {
//
//
////        let config = URLSessionConfiguration.default
////        let session = URLSession(configuration: config)
////        let urlRequest = session(configuration: sURL)
//
//        Alamofire.Request(sURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
//            if response.result.isSuccess {
//                let weatherJSON : JSON = JSON(response.result.value!)
//                print(weatherJSON)
//            }else {
//                print("Error:\(response.result.error!)")
//
//            }
//        }
//
////        Alamofire.Request(URLRequest, method: .post, Parameters: params).responseJSON
////         {
////            response in
////            if response.result.isSuccess {
////                let weatherJSON : JSON = JSON(response.result.value!)
////                print(weatherJSON)
////            }else {
////                print("Error:\(response.result.error!)")
////
////            }
////        }
//
////        Alamofire.request(xmlRequest).responseString(completionHandler: {response in
////            if response.result.isSuccess {
////                let respJSON : JSON = JSON(response.result.value!)
////                print("\(respJSON)")
////                //print(response.result.value)
////            }else {
////                print("Error:\(response.result.error!)")
////
////            }
////        })
//        //**************
//
//
//
//
//    }
}
