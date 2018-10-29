//
//  ClubRelayPoints.swift
//  SwimTime
//
//  Created by Mick Mossman on 29/10/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import Foundation
import RealmSwift

class ClubRelayPoints : Object {
    @objc dynamic var eventID : Int = 0
    @objc dynamic var clubID : Int = 0
    @objc dynamic var points : Int = 0
    
}
