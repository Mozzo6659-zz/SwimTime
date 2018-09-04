//
//  AppDelegate.swift
//  SwimTime
//
//  Created by Mick Mossman on 2/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let realm = try! Realm()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        let myDEF = appUserDefaults()
//
//        let nextmem = myDEF.getNextMemberId()
//        print("\(nextmem)")
        addGroups()
        addInitSwimClub()
        //checkExplorer()
        //addMembers()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: - my Data manipulation
    func checkExplorer() {
        let groupArray : Results<Group> = realm.objects(Group.self).filter("groupID = 2")
        
        print(groupArray[0].members.count)
        
        for mem in groupArray[0].members {
            print(mem.memberName)
        }
    }
    
    func addInitSwimClub() {
        let clubArray : Results<SwimClub> = realm.objects(SwimClub.self)
        
        if clubArray.count != 0 {
            let defsc = SwimClub()
            defsc.clubName = "Seas the Limit"
            defsc.clubID = 1
            do {
                
                try realm.write {
                    realm.add(defsc)
                }
            }catch {
                print("Error encoding Item array")
            }

        }
        
        
        
    }
    func addGroups() {
        var groupArray : Results<Group>
        
        groupArray = realm.objects(Group.self)
        
        if groupArray.count == 0 {
            addGroup(id: 0, groupname: "None")
            addGroup(id: 1, groupname: "Beginner")
            addGroup(id: 2, groupname: "Explorer")
            addGroup(id: 3, groupname: "Performer")
        }
   
    }
    
    func addGroup(id : Int,groupname : String) {
        let grp = Group()
        grp.groupID = id
        grp.groupName = groupname
        do {
                
                try realm.write {
                    realm.add(grp)
                }
            }catch {
                print("Error encoding Item array")
            }

    }
    
    func addMembers() {
        //temp process
        let appDef = appUserDefaults()
        let mem = Member()
        let grp = realm.objects(Group.self).first!
        print(grp.groupName)
        mem.memberID = appDef.getNextMemberId()
        mem.memberName = "Joe Blow"
        mem.gender = "Male"
        mem.onekSeconds = 1800
        
        let calendar = Calendar.current
        
        mem.dateOfBirth = calendar.date(byAdding: .year, value: -30, to: Date())!
        
        
        do {
            
            try self.realm.write {
                
                self.realm.add(mem)
                grp.members.append(mem)
            }
        }catch {
            print("Error encoding Item array")
        }
        //mem.dateOfBirth =
    }
}

