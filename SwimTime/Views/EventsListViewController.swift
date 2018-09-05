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
    var selectedMember = Member()
    let eventseg = "eventListToEvent"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.setHidesBackButton(true, animated: false)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if backFromEvent {
            if loadEvents() {
                tableView.reloadData()
            }
            
            
            backFromEvent = false
        }
    }

    // MARK: - my Data stuff
    func loadEvents() -> Bool{
        var found : Bool = false
        
        var finishedSelect : String = "false"
        
        if showFinished  {
            finishedSelect = "true"
        }
    
        
        eventsList = realm.objects(Event.self).filter("isFinished = " + finishedSelect)
        
        if (eventsList?.count == 0) {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            
            noDataLabel.text             = "No Members to List"
            noDataLabel.textColor        = UIColor.black
            noDataLabel.backgroundColor = UIColor.gray
            //noDataLabel.layer.cornerRadius = 30;
            noDataLabel.textAlignment    = .center
            noDataLabel.font = UIFont(name:"Verdana",size:40)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)

        configureCell(cell: cell, atIndexPath: indexPath)

        return cell
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:IndexPath) {
        
        
        let lh = eventsList![indexPath.row + indexPath.section]
        
        //print(lh.memberName + " at \(indexPath.row) gender \(lh.gender) id=\(lh.memberID)")
        
        //cell.backgroundColor = UIColor.white
        //cell.tintColor = UIColor.white
        
        
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
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: - Bar Button actions
    
    @IBAction func newEventClicked(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func homeClicked(_ sender: UIBarButtonItem) {
    }
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
