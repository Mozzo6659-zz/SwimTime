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
        return  "https:/www.hammerheadsoftware.com.au/swimclubws/swimclubservice.asmx"
    }
}
