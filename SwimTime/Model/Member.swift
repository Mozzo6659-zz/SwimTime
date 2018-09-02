//
//  Member.swift
//  SwimTime
//
//  Created by Mick Mossman on 2/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class Member : Object {
    @objc dynamic var memberID : Int = 0
    @objc dynamic var webID : Int = 0
    @objc dynamic var memberName : String = ""
    @objc dynamic var dateOfBirth : Date = Date()
    @objc dynamic var gender : String = "Male"
    @objc dynamic var onekSeconds : Int = 0
    @objc dynamic var emailAddress : String = ""
    var myGroup = LinkingObjects(fromType: Group.self, property: "members")
    
}

