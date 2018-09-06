//
//  EventViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift
class EventViewController: UIViewController,
UITableViewDelegate, UITableViewDataSource {

    var timer : Timer!
    var timerOn = false
    var useRaceNos = false
    var returnFromMembers = false
    var noSeconds : Int = 0
    let realm = try! Realm()
    
    let currentEvent = Event()
    
    var eventResults : Results<EventResult>?
    
    
    let eventToMemberseg = "eventToMembers"
    
    let myDefs = appUserDefaults()
    let myFunc = appFunctions()
    
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtDistance: UITextField!
    
    
    @IBOutlet weak var btnReset: UIButton!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    
    
    @IBOutlet weak var lblFilter: UILabel!
    @IBOutlet weak var lblTimeDisplay: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
       
    }

    override func viewWillAppear(_ animated: Bool) {
        if returnFromMembers {
            returnFromMembers = false
            myTableView.reloadData()
        }
    }
    
    //MARK: - Actions

    @IBAction func useRaceNosChanged(_ sender: UISwitch) {
        useRaceNos = sender.isOn
    }
    
    @IBAction func btnResetClicked(_ sender: UIButton) {
        timer.invalidate()
        timerOn = false
        do {
            if let dist = Int(txtDistance.text!) {
                currentEvent.eventDistance = dist
            }
            
            
            try realm.write {
                for er in currentEvent.eventResults {
                    let mem = er.myMember.first!
                    er.resultSeconds = 0
                    er.expectedSeconds = myFunc.adjustOnekSecondsForDistance(distance: currentEvent.eventDistance , timeinSeconds: mem.onekSeconds)
                }
                
            }
            
            myTableView.reloadData()
        }catch{
            showError(errmsg: "Cant Reset")
        }
       
        lblTimeDisplay.text = "00:00:00"
        noSeconds=1;
        btnStart.setTitle("Start", for: .normal)
        myTableView.reloadData()
    }
    
    
    
    @IBAction func btnDone(_ sender: UIBarButtonItem) {
        //delete event if no members in event
        self.navigationController?.popViewController(animated: true)
        if currentEvent.eventID != 0 {
            //0 means even has never been saved
            if currentEvent.eventResults.count == 0 {
                //remove any with no event results
                do {
                    try realm.write {
                        realm.delete(currentEvent)
                        
                    }
                }catch{
                    showError(errmsg: "Cant delete empty event")
                }
                
            }
        }
    }
    
    @IBAction func startStopTimer(_ sender: UIButton) {
        var bContinue = true
        if !timerOn {
            /*we are startng so check we have people in the race*/
            if currentEvent.eventResults.count == 0 {
                
                bContinue = false
            }
        }
        if (bContinue) {
            if timerOn {
                timer.invalidate()
                //timer = nil;
                
                //[self displayResults] goes to the results view controller
                
            }else {
                
                
               doEventStart()
            }
            
            timerOn = !timerOn
            //[tblResults reloadData];
        }
    }
    
    @IBAction func btnAddMembers(_ sender: UIBarButtonItem) {
        //lets save the event here
        if saveEvent() {
            performSegue(withIdentifier: eventToMemberseg, sender: self)
        }
    }
    
    //MARK: - TableView stuff
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return currentEvent.eventResults.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3.0
    }
    
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        configureCell(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:IndexPath) {
        
        
        let er = currentEvent.eventResults[indexPath.row + indexPath.section]
        let mem = er.myMember.first!
        let grp = mem.myGroup.first!
        
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 35.0)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 20.0)
        
        //NSLog(@"memberid=%d name=%@",lh.member.memberid,lh.member.membername);
        let textlabel = mem.memberName
        
        var dtText = String(format:" Age: %d",mem.age)
        dtText = dtText + String(format:"  Group: %@",grp.groupName)
            
        
       let dtlLabel = "Est Time: " + myFunc.convertSecondsToTime(timeinseconds: er.expectedSeconds) + dtText
        
       
        cell.textLabel?.text = textlabel
        cell.detailTextLabel?.textColor = UIColor.red
        cell.detailTextLabel?.text = dtlLabel
        
        let imgFilePath = myFunc.getFullPhotoPath(memberid: mem.memberID)
        
        let imgMemberPhoto = UIImageView(image: UIImage(contentsOfFile: imgFilePath))
        cell.backgroundColor = UIColor(hexString: "89D8FC") //light blue.-- hard setting ths doesnt seem to work as well
        if imgMemberPhoto.image != nil {
            
            let frame = CGRect(x: 0.0, y: 0.0, width: 100.00, height: 100.00)
            
            imgMemberPhoto.frame = frame
            imgMemberPhoto.layer.masksToBounds = true
            imgMemberPhoto.layer.cornerRadius = 20.0
            cell.accessoryView = imgMemberPhoto
            cell.accessoryView?.tintColor = UIColor.clear
            cell.accessoryView?.isHidden = false
            
        }else{
            cell.accessoryView?.isHidden = true
        }
        
        
        
        //cell.accessoryView=nil;
        
        //NSLog(@"%@",dtlLabel);
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if timerOn {
            //finish him off
            
        }else{
            //go to window to adjust estimate and take a photo
        }
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return !timerOn
    }
    
    
    
    // Override to support editing the table view.
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == eventToMemberseg {
            returnFromMembers = true
            let vc = segue.destination as! MembersForEventViewController
            vc.selectedEvent = currentEvent
        }
    }
    
    //MARK: - Data stuff
    
    func saveEvent() -> Bool {
        var ok = false
            if validateEvent() {
                do {
                    try realm.write {
                        currentEvent.eventLocation = txtLocation.text!
                        currentEvent.eventDistance = Int(txtDistance.text!)!
                        currentEvent.useRaceNos = useRaceNos
                        
                        if currentEvent.eventID == 0 {
                            currentEvent.eventDate = Date()
                            currentEvent.eventID = myDefs.getNextEventId()
                            realm.add(currentEvent)
                        }
                        ok = true
                    }
                }catch{
                    showError(errmsg: "Cant save the Event")
                }
            }
        
        return ok
    }
    
    func validateEvent() -> Bool {
        var sErrmsg = ""
        
        if let sLocation = txtLocation.text {
            if sLocation.isEmpty {
                sErrmsg = "Please enter a location"
            }
        }else{
            sErrmsg = "Please enter a location"
        }
        if let sDistance = txtDistance.text {
            if sDistance.isEmpty {
                sErrmsg = "Please enter a distance"
            }
        }else{
            sErrmsg = "Please enter a distance"
        }
        
        return sErrmsg == ""
    }
    
    //MARK: Timer
func doEventStart() {
    btnStart.setTitle("Finish",for: .normal)
    
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//
//    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
//
//    [self maketablecontents:YES];
    }
    
    @objc func updateTimer() {
        noSeconds += 1;
    
        lblTimeDisplay.text = myFunc.convertSecondsToTime(timeinseconds: noSeconds)
    
    
    }
    
    //MARK: - Errors
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
}
