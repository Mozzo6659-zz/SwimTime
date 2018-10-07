//
//  EventsListViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//
//this can list finished event and finished dual meets when called from the Results button
//otherwise its only called from the Exhibition button
import UIKit
import RealmSwift

class EventsListViewController: UITableViewController {
    let realm = try! Realm()
    var eventsList : [EventList] = []
    var myfunc = appFunctions()
    var backFromEvent : Bool = false
    var showFinished : Bool = false //whether the lits show finished event or active events
    //var showPreset : Bool = false
    
    //var selectedMember = Member()
    var selectedEvent = Event()
    var selectedDualMeet = DualMeet()
    
    let eventseg = "eventListToEvent"
    let eventResultseg = "eventListToResults"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.setHidesBackButton(true, animated: false)
        
        if loadEvents() {
            
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if backFromEvent {
            if loadEvents() {
                
            }
            
            tableView.reloadData()
            selectedEvent = Event()
            backFromEvent = false
        }
    }

    // MARK: - my Data stuff
    func loadEvents() -> Bool{
        var found : Bool = false
        
        eventsList.removeAll()
        let filterstring : String = showFinished ? "isFinished=true" : "isFinished=false"
        
        
//        if showPreset {
//            filterstring += " AND hasPresetEvent=true"
//            //eventsList = eventsList?.filter("hasPresetEvent=true")
//        }else{
//            if !showFinished {
//                filterstring += " AND hasPresetEvent=false"
//            }
//        }
        
        let evList  = realm.objects(Event.self).filter(filterstring)
        
        //for showFinished load Dual meets separate
        if showFinished {
            for ev in evList {
                if let _ = ev.myDualMeet.first {
                    
                }else{
                    //not a dual meet jutst a finished event
                    let el = EventList()
                    el.eventDate = ev.eventDate
                    el.event = ev
                    eventsList.append(el)
                }
            }
            let dmlist = realm.objects(DualMeet.self).filter(filterstring)
            for dm in dmlist {
                let el = EventList()
                el.eventDate = dm.meetDate
                el.dualMeet = dm
                eventsList.append(el)
            }
        }else{
            for ev in evList {
                let el = EventList()
                if let _ = ev.myDualMeet.first {
                    //dont inlcud Dual meets just normal events. Dual meets have their own list
                }else{
                    el.eventDate = ev.eventDate
                    el.event = ev
                    eventsList.append(el)
                }
                
            }
        }
        
        if (eventsList.count == 0) {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            
            noDataLabel.text             = "No Active Event to List"
            noDataLabel.textColor        = UIColor.black
            noDataLabel.backgroundColor = UIColor.gray
            
            noDataLabel.textAlignment    = .center
            noDataLabel.font = UIFont(name:"Helvetica",size:40)
            //UIFont(fontWithName:"Verdana" size:40)
            tableView.backgroundView = noDataLabel;
            
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }else{
            eventsList = eventsList.sorted(by: {$0.eventDate > $1.eventDate})
            tableView.backgroundView=nil;
            found = true
        }
        return found
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
         return eventsList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let el = eventsList[indexPath.row + indexPath.section]
        if showFinished {
            if el.isEvent() {
                selectedEvent = el.event
                selectedDualMeet = DualMeet()
            }else{
                selectedDualMeet = el.dualMeet
                selectedEvent = selectedDualMeet.selectedEvents[0]
            }
            performSegue(withIdentifier: eventResultseg, sender: self)
        }else{
            selectedEvent = el.event
            performSegue(withIdentifier: eventseg, sender: self)
        }
       
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)

        configureCell(cell: cell, atIndexPath: indexPath)

        return cell
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:IndexPath) {
        var theevent = Event()
        var thedm = DualMeet()
        var stext = ""
        
        let el = eventsList[indexPath.row + indexPath.section]
        var sdetailText =  myfunc.formatDate(thedate: el.eventDate)
        
        if el.isEvent() {
            theevent = el.event
            stext = theevent.eventLocation + (" \(theevent.eventDistance) mtrs")
            sdetailText += (" \(theevent.eventResults.count) entrants")
        }else{
            thedm = el.dualMeet
            stext = String(format:"%@ Dual Meet ",thedm.meetLocation)
            sdetailText += (" \(thedm.selectedTeams[0].clubName)")
            
            if thedm.selectedTeams.count != 1 {
                sdetailText += (",\(thedm.selectedTeams[1].clubName)")
            }
        }
        cell.textLabel?.text = stext
        cell.detailTextLabel?.text = sdetailText
        cell.textLabel?.font = UIFont(name:"Helvetica", size:40.0)
        
        cell.detailTextLabel?.textColor = UIColor.red
        
        cell.detailTextLabel?.font = UIFont(name:"Helvetica", size:20.0)
     
        let imgArrow = UIImageView(image: UIImage(named: "rightArrow7575"))
        
        imgArrow.sizeToFit()
        
        cell.accessoryView = imgArrow
        //[imgMemberPhoto sizeToFit];
        
        
        
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return !showFinished
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let el = eventsList[indexPath.row + indexPath.section]
        //delete not active when shw finished is selected
        
        let ev = el.event
        
        if editingStyle == .delete {
            do {
                try realm.write {
                    if ev.eventResults.count != 0 {
                        for er in ev.eventResults {
                            if let mem = er.myMember.first {
                                if let mxm = mem.eventResults.index(where: {$0.eventResultId == er.eventResultId}) {
                                    mem.eventResults.remove(at: mxm)
                                }
                            }
                            realm.delete(er)
                        }
                    }
                    realm.delete(ev)
                }
            }catch{
                showError(errmsg: "Cant delete event")
            }
            if loadEvents() {
                
            }
            tableView.reloadData()
            
        }
    }
    
    @IBAction func newEventClicked(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: eventseg, sender: self)
    }
    
    @IBAction func homeClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == eventseg {
            backFromEvent = true
            let vc = segue.destination as! EventViewController
            if selectedEvent.eventID != 0 {
                
                vc.currentEvent = selectedEvent
                
            }
            
            //vc.usePresetEvents = showPreset
            
            
        }else if segue.identifier == eventResultseg {
            let vc = segue.destination as! ResultsViewController
            vc.currentEvent = selectedEvent
            vc.selectedDualMeet = selectedDualMeet
        }
    }
    
    //MARK: - Errors
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
}
