//
//  Group.swift
//  SwimTime
//
//  Created by Mick Mossman on 2/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class Group : Object {
    @objc dynamic var groupID : Int = 0
    @objc dynamic var groupName : String = ""
    let members = List<Member>()

    
}
