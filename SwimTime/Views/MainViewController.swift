//
//  ViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 2/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift

class MainViewController: UIViewController {

    var showFinishedEvents = false //tells the eet seque
    var showPresetEvents = false
    let gotoEventsListSeg = "gotoEventsList"
    let gotoMembersListSeg = "gotoMembersList"
    let gotoDualMeetListSeg = "gotoDualMeetList"
    
    let myDefs = appUserDefaults()
    let myFunc = appFunctions()
    let runningEventSeg = "MainToEvent"
    //var runningEventID = 0
    
    
    
    @IBOutlet weak var btnMembers: UIButton!
    
    @IBOutlet weak var btnDev: UIButton!
    
    @IBOutlet weak var btnPresetEvent: UIButton!
    @IBOutlet weak var btnEvets: UIButton!
    
    @IBOutlet weak var btnResults: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMembers.layer.borderColor = UIColor.red.cgColor
        btnEvets.layer.borderColor = UIColor.red.cgColor
        
        btnResults.layer.borderColor = UIColor.red.cgColor
       btnPresetEvent.layer.borderColor = UIColor.red.cgColor
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        //btnDev.isHidden = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: true)

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Button functions
    
    
    @IBAction func mnubtnClicked(_ sender: UIButton) {
        var seg : String = ""
        showFinishedEvents = (sender.tag == 3)
        showPresetEvents = (sender.tag == 4)
        switch sender.tag {
        case 1:
            seg = gotoMembersListSeg
        case 2,3:
            
            seg = gotoEventsListSeg
            
        case 4:
            seg = gotoDualMeetListSeg
        default:
            seg = ""
        }
        
        if seg != "" {
            performSegue(withIdentifier: seg, sender: self)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gotoEventsListSeg {
            
            let vc = segue.destination as! EventsListViewController
            vc.showFinished = showFinishedEvents
            
        }else if segue.identifier == runningEventSeg {
            let realm = try! Realm()
            //this segue is called in by the appdelgate if a running event is found
            let vc = segue.destination as! EventViewController
            vc.eventIsRunning = true
            let runningDualMeetId = myDefs.getRunningDualMeetID()
            if runningDualMeetId != 0 {
                let runningEventID = myDefs.getRunningEventID()
                if let runningDualMeet = realm.objects(DualMeet.self).filter("dualMeetID=%d",runningDualMeetId).first {
                    vc.selectedDualMeet = runningDualMeet
                    for ev in runningDualMeet.selectedEvents {
                        if ev.eventID == runningEventID {
                            vc.currentEvent = ev
                            break
                        }
                    }
                }
                
            }else{
            
                vc.currentEvent = getRunningEvent()
            }
        }
    }
    
    func getRunningEvent()->Event {
        let realm = try! Realm()
        let runningEventID = myDefs.getRunningEventID()
        let runningEvent = realm.objects(Event.self).filter("eventID=%d",runningEventID).first
        return runningEvent!
    }
    
    //MARK: - Dev Stuff
    @IBAction func btnDevClicked(_ sender: UIButton) {
        //let realm = try! Realm()
        
        
        let mcldb = cloudDB()
        
        mcldb.uploadData()
    
        

        
    }
}

