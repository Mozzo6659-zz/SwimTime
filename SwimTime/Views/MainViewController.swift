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
    let gotoEventsListSeg = "gotoEventsList"
    let gotoMembersListSeg = "gotoMembersList"
    
    let myDefs = appUserDefaults()
    let myFunc = appFunctions()
    let runningEventSeg = "MainToEvent"
    //var runningEventID = 0
    
    let realm = try! Realm()
    
    @IBOutlet weak var btnMembers: UIButton!
    
    
    @IBOutlet weak var btnEvets: UIButton!
    
    @IBOutlet weak var btnResults: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMembers.layer.borderColor = UIColor.red.cgColor
        btnEvets.layer.borderColor = UIColor.red.cgColor
        
        btnResults.layer.borderColor = UIColor.red.cgColor
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        
//        runningEventID = myDefs.getRunningEventID()
//
//        if runningEventID != 0 {
//
//            //check the date isnt more than 20 hours ago
//
//
//            let runDate = myDefs.getRunningEventStopDate()
//            let hrsDiff = myFunc.getDateDiffHours(fromDate: runDate)
//
//            if hrsDiff < 20 {
//                performSegue(withIdentifier: runningEventSeg, sender: self)
//            }else{
//                myDefs.setRunningEventID(eventID: 0)
//                myDefs.setRunningEventSecondsStopped(clockseconds: 0)
//            }
//
//        }
        
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
        
        switch sender.tag {
        case 1:
            seg = gotoMembersListSeg
        case 2,3:
            
            seg = gotoEventsListSeg
            
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
            
            //this segue is called in by the appdelgate if a running event is found
            let vc = segue.destination as! EventViewController
            vc.eventIsRunning = true
            vc.currentEvent = getRunningEvent()
        }
    }
    
    func getRunningEvent()->Event {
        let runningEventID = myDefs.getRunningEventID()
        let runningEvent = realm.objects(Event.self).filter("eventID=%d",runningEventID).first
        return runningEvent!
    }
}

