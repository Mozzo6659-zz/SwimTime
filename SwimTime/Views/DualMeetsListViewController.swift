//
//  DualMeetsListViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 27/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift

class DualMeetsListViewController: UITableViewController {

    let realm = try! Realm()
    var meetList : Results<DualMeet>?
    var backFromDualMeetEntry = false
    var myfunc = appFunctions()
    var myDefs = appUserDefaults()
    var showFinished = false
    var selectedMeet = DualMeet()
    let meetseg = "meetListToMeet"
    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        loadDualMeets()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        if backFromDualMeetEntry {
            loadDualMeets()
            
            tableView.reloadData()
            selectedMeet = DualMeet()
            backFromDualMeetEntry = false
        }
    }
    //MARK: - IBactions
    
    @IBAction func goToMeet(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: meetseg, sender: self)
    }
    @IBAction func goHome(_ sender: Any) {
        
         self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return meetList?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meetCell", for: indexPath)
        
        let dm = meetList![indexPath.row + indexPath.section]
        
        
        let hdrText = String(format:"%@ %@",myfunc.formatDate(thedate: dm.meetDate),dm.meetLocation)
        
        cell.textLabel?.font = UIFont(name:"Helvetica", size:40.0)
        
        cell.textLabel?.text = hdrText
        
        cell.detailTextLabel?.textColor = UIColor.red
        
        cell.detailTextLabel?.font = UIFont(name:"Helvetica", size:20.0)
        var dtText = "0 Teams selected"
        if dm.selectedTeams.count != 0 {
            //I wont save unless there is 2 teams
            for tm in dm.selectedTeams {
                dtText += tm.clubName + ","
            }
            dtText.removeLast()
        }
        cell.detailTextLabel?.text = dtText
        
        return cell
    }
    
    //MARK: - Date stuff
    
    func loadDualMeets() {
        
        let filterstring : String = showFinished ? "ANY selectedEvents.isFinished=true" : "ANY selectedEvents.isFinished=false"
        
        
        meetList = realm.objects(DualMeet.self).filter(filterstring).sorted(byKeyPath: "meetDate", ascending: false)
        
        if (meetList?.count == 0) {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            
            noDataLabel.text             = "No Meets to List"
            noDataLabel.textColor        = UIColor.black
            noDataLabel.backgroundColor = UIColor.gray
            
            noDataLabel.textAlignment    = .center
            noDataLabel.font = UIFont(name:"Helvetica",size:40)
            //UIFont(fontWithName:"Verdana" size:40)
            tableView.backgroundView = noDataLabel;
            
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }else{
            tableView.backgroundView=nil;
        }
    }
    
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     
        return !showFinished //cant delete already run events
     }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // COME BACK
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
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
        if segue.identifier == meetseg {
            
            let vc = segue.destination as! DualMeetViewController
            vc.currentMeet = selectedMeet
            
        }
    }
 

}
