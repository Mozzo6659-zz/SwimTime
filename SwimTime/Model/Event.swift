//
//  Event.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class Event : Object {
    @objc dynamic var eventID : Int = 0
    @objc dynamic var webID : Int = 0
    @objc dynamic var dataChanged : Bool = false
    @objc dynamic var eventDate : Date = Date()
    @objc dynamic var eventName : String = ""
    @objc dynamic var eventLocation : String = ""
    @objc dynamic var isFinished : Bool = false
    
    let eventResults = List<EventResult>()
}
