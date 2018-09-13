//
//  EventsListViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift

class EventsListViewController: UITableViewController {
    let realm = try! Realm()
    var eventsList : Results<Event>?
    var myfunc = appFunctions()
    var backFromEvent : Bool = false
    var showFinished : Bool = false //whether the lits show finished event or active events
    var showPreset : Bool = false
    
    //var selectedMember = Member()
    var selectedEvent = Event()
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
        
        var filterstring : String = showFinished ? "isFinished=true" : "isFinished=false"
        
        
        if showPreset {
            filterstring += " AND hasPresetEvent=true"
            //eventsList = eventsList?.filter("hasPresetEvent=true")
        }
        
        eventsList = realm.objects(Event.self).filter(filterstring).sorted(byKeyPath: "eventDate", ascending: false)
        
        
        
        if (eventsList?.count == 0) {
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
            tableView.backgroundView=nil;
            found = true
        }
        return found
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
         return eventsList?.count ?? 0
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
        selectedEvent = eventsList![indexPath.row + indexPath.section]
        if selectedEvent.isFinished {
              performSegue(withIdentifier: eventResultseg, sender: self)
        }else{
          performSegue(withIdentifier: eventseg, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)

        configureCell(cell: cell, atIndexPath: indexPath)

        return cell
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:IndexPath) {
        
        
        let lh = eventsList![indexPath.row + indexPath.section]
        
        cell.textLabel?.font = UIFont(name:"Helvetica", size:40.0)
        
        cell.textLabel?.text = lh.eventLocation + (" \(lh.eventDistance) mtrs"
        )
        cell.detailTextLabel?.textColor = UIColor.red
        
        cell.detailTextLabel?.font = UIFont(name:"Helvetica", size:20.0)
        

        let dtfmt = DateFormatter()
        
        dtfmt.dateFormat = "dd-MM-yyyy"
        
        
      cell.detailTextLabel?.text = dtfmt.string(from: lh.eventDate) + "  \(lh.eventResults.count) entrants"
        
        let imgArrow = UIImageView(image: UIImage(named: "rightArrow7575"))
       
        
        imgArrow.sizeToFit()
        
        cell.accessoryView = imgArrow
        //[imgMemberPhoto sizeToFit];
        
        
        
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let ev = eventsList![indexPath.row + indexPath.section]
        
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
            if selectedEvent.eventID != 0 {
                let vc = segue.destination as! EventViewController
                vc.currentEvent = selectedEvent
            }
        }else if segue.identifier == eventResultseg {
            let vc = segue.destination as! ResultsViewController
            vc.currentEvent = selectedEvent
        }
    }
    
    //MARK: - Errors
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
}
