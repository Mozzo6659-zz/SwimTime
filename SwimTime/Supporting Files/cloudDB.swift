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
class cloudDB {
    
    func getURL() -> String {
        return  "https://www.hammerheadsoftware.com.au/swimclubws/swimclubservice.asmx"
    }
    
    func addClubs() {
        //testing adding swim clubs using Alamofire
        let sURL = getURL() + "/AddclubListJSON"
        
        /*SOAP1.1
 POST /swimclubws/swimclubservice.asmx HTTP/1.1
 Host: www.hammerheadsoftware.com.au
 Content-Type: text/xml; charset=utf-8
 Content-Length: length
 SOAPAction: "https://hammerheadsoftware.com.au/AddclubListJSON"
 
 <?xml version="1.0" encoding="utf-8"?>
 <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
 <soap:Body>
 <AddclubListJSON xmlns="https://hammerheadsoftware.com.au/">
 <Clublist>
 <clsSwimClub>
 <remoteclubid>int</remoteclubid>
 <clubname>string</clubname>
 </clsSwimClub>
 <clsSwimClub>
 <remoteclubid>int</remoteclubid>
 <clubname>string</clubname>
 </clsSwimClub>
 </Clublist>
 </AddclubListJSON>
 </soap:Body>
 </soap:Envelope>
 */
        /*SOAP12
 POST /swimclubws/swimclubservice.asmx HTTP/1.1
 Host: www.hammerheadsoftware.com.au
 Content-Type: application/soap+xml; charset=utf-8
 Content-Length: length
 
 <?xml version="1.0" encoding="utf-8"?>
 <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
 <soap12:Body>
 <AddclubListJSON xmlns="https://hammerheadsoftware.com.au/">
 <Clublist>
 <clsSwimClub>
 <remoteclubid>int</remoteclubid>
 <clubname>string</clubname>
 </clsSwimClub>
 <clsSwimClub>
 <remoteclubid>int</remoteclubid>
 <clubname>string</clubname>
 </clsSwimClub>
 </Clublist>
 </AddclubListJSON>
 </soap12:Body>
 </soap12:Envelope>
 */
        var params = "<AddclubListJSON xmlns=\"https://hammerheadsoftware.com.au/\">\n"
        //var params = "<AddclubListJSON xmlns=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
        params = params + "<ClubList>\n"
        params = params + "<clsSwimClub>\n"
        params = params + "<remoteclubid>0</remoteclubid>\n"
        params = params + "<clubname>Coogee</clubname>\n"
        params = params + "</clsSwimClub>\n"
        params = params + "<clsSwimClub>\n"
        params = params + "<remoteclubid>0</remoteclubid>\n"
        params = params + "<clubname>Botany</clubname>\n"
        params = params + "</clsSwimClub>\n"
         params = params + "</ClubList>\n"
        params = params + "</AddclubListJSON>"
        
        // print(params)
        
        //****************
//        Alamofire.request(.POST, "https://something.com" , parameters: Dictionary(), encoding: .Custom ({
//            (convertible, params) in
//            let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
//
//            let data = (self.testString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
//            mutableRequest.HTTPBody = data
//            return (mutableRequest, nil)
//        }))
//
//
//            .responseJSON { response in
//
//
//                print(response.response)
//
//                print(response.result)
//
//
//        }
//
        //**************
        
 //Possible SOAP version mismatch: Envelope namespace https://hammerheadsoftware.com.au/ was unexpected. Expecting http://schemas.xmlsoap.org/soap/envelope/
 
        let thisurl = URL(string: getURL())
        
        
        let thedata = params.data(using: String.Encoding.utf8, allowLossyConversion: true)
        var xmlRequest = URLRequest(url: thisurl!)
        xmlRequest.httpBody = thedata
        xmlRequest.httpMethod = "POST"
        xmlRequest.addValue("www.hammerheadsoftware.com.au", forHTTPHeaderField:"Host")
        //xmlRequest.addValue("application/soap+xml", forHTTPHeaderField: "Content-Type")
        xmlRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        xmlRequest.addValue(String(format:"%lu",params.lengthOfBytes(using: String.Encoding.utf8)),forHTTPHeaderField:"Content-Length")
        print("\(xmlRequest)")
        //xmlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        xmlRequest.addValue("https://hammerheadsoftware.com.au/AddclubListJSON", forHTTPHeaderField:"SOAPAction")
        
//        Alamofire.request(xmlRequest).responseJSON(queue: nil, options: .mutableContainers) { response in
//            print("Imhere")
//            if response.result.isSuccess {
//                    let respJSON : JSON = JSON(response.result.value!)
//                    print("\(respJSON)")
//            }else {
//                    print("Error:\(response.result.error!)")
//
//            }
//        }
        Alamofire.request(xmlRequest).responseString(completionHandler: {response in
            if response.result.isSuccess {
                let respJSON : JSON = JSON(response.result.value!)
                print("\(respJSON)")
                //print(response.result.value)
            }else {
                print("Error:\(response.result.error!)")
                
            }
        })
//        Alamofire.request(xmlRequest).responseJSON {
//            response in
//            if response.result.isSuccess {
//                let respJSON : JSON = JSON(response.result.value!)
//                print("\(respJSON)")
//            }else {
//                print("Error:\(response.result.error!)")
//
//            }
//        }

        

    }
}
