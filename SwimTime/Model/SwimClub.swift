//
//  SwimClub.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class SwimClub : Object {
    @objc dynamic var clubID : Int = 0
    @objc dynamic var clubName : String = ""
    let members = List<Member>()
}
