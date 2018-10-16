//
//  DualMeetViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 27/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift
class DualMeetViewController: UIViewController, DualMeetDelegate {
   
    
    
    
    let realm = try! Realm()
    
    let myFunc = appFunctions()
    let myDefs = appUserDefaults()
    
    var currentMeet = DualMeet()
    
    var selectedEvent = Event() //used to pass to event view controller
    let eventSeg = "DualMeetToEvent"
    let resultSeg = "DualMeetToResults"
    
    var defSwimClub = SwimClub()
    private var datepicker : UIDatePicker?
    var eventList : List<Event>?
    
    var pickerTeams : UIPickerView!
    
    var pickerTeamItems : Results<SwimClub>?
    
    
    var pickingTeam1 : Bool = false //when the team picker view cmes up i need to know which label to retrun the result
    var pickerViewFrame = CGRect(x: 120.0, y: 100.0, width: 600.00, height: 143.0)
    
    @IBOutlet weak var lblMeetDate: UILabel!
    
    @IBOutlet weak var txtLocation: UITextField!
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var lblTeam1: UILabel!
    
    @IBOutlet weak var lblTeam2: UILabel!
    
    @IBOutlet weak var btnEventDate: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        
        defSwimClub = myDefs.getDefSwimClub()
        
        if currentMeet.dualMeetID  == 0 && currentMeet.selectedTeams.count == 0 {
            currentMeet.selectedTeams.append(defSwimClub)
        }
       
        configureDatePicker()
        
        loadPickerViews()
        loadMeetDetails()
        loadEvents()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    //MARK: - Data gathering and manipulation
    
    func loadEvents() {
        
        eventList = currentMeet.selectedEvents
        myTableView.isHidden = eventList?.count == 0
        
    }
    
    func saveDetails() {
        do {
            try realm.write {
                currentMeet.meetDate = self.myFunc.dateFromString(stringdate: self.lblMeetDate.text!)
                currentMeet.meetLocation = self.txtLocation.text!
                if currentMeet.dualMeetID == 0 {
                    currentMeet.dualMeetID = self.myDefs.getNextDualMeetId()
                    realm.add(currentMeet)
                }
            }
        }catch{
            showError(errmsg: "Unable to save Dual Meet")
        }
        
        
    }
    func loadMeetDetails() {
        var sDateText = ""
        
        if currentMeet.dualMeetID != 0 {
            sDateText = myFunc.formatDate(thedate: currentMeet.meetDate)
        }
        
        lblMeetDate.text = sDateText
        txtLocation.text = currentMeet.meetLocation
        
        if currentMeet.selectedTeams.count != 0 {
            lblTeam1.text = currentMeet.selectedTeams[0].clubName
            if currentMeet.selectedTeams.count > 1 {
                lblTeam2.text = currentMeet.selectedTeams[1].clubName
            }
        }
    }
    
    func validateDetails() -> Bool {
        var errMsg = ""
        
        if let stext = txtLocation.text {
            if stext.isEmpty {
               errMsg = "Please enter a location"
            }
        }else{
            errMsg = "Please enter a location"
        }
        
        if let stext = lblMeetDate.text {
            if stext.isEmpty {
                errMsg = "Please enter a date"
            }
        }else{
            errMsg = "Please enter a date"
        }
        
        if let stext = lblTeam1.text {
            if stext.isEmpty {
                errMsg = "Please enter both teams"
            }
        }else{
            errMsg = "Please enter both teams"
        }
        
        if let stext = lblTeam2.text {
            if stext.isEmpty {
                errMsg = "Please enter both teams"
            }
        }else{
            errMsg = "Please enter both teams"
        }
        
        if !errMsg.isEmpty {
            showError(errmsg: errMsg)
        }
        
        return errMsg.isEmpty
    }
    
    
    //MARK: DatePicker
    
    func configureDatePicker() {
        datepicker = UIDatePicker()
        datepicker?.datePickerMode = .date
        btnEventDate.inputView = datepicker
        if currentMeet.dualMeetID == 0 {
            datepicker?.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        }else{
            datepicker?.date = currentMeet.meetDate
        }
        
        datepicker?.addTarget(self, action: #selector(DualMeetViewController.dateChanged(datepicker:)), for: .valueChanged)
        
    }
    
    @objc func dateChanged(datepicker:UIDatePicker) {
        
        lblMeetDate.text = myFunc.formatDate(thedate: datepicker.date)
        
        //COME BACK - need to update photos and member names blah blah ??
        removeKeyBoard()
        
    }
    //MARK: IBActons
    
    
    @IBAction func addRace(_ sender: UIBarButtonItem) {
        if validateDetails() {
            saveDetails()
            selectedEvent = Event()
            performSegue(withIdentifier: eventSeg, sender: self)
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func addNewTeam(_ sender: UIButton) {
        var bok = true
        removePickerViews()
        
        if currentMeet.selectedEvents.count != 0 {
            showError(errmsg: "Cant change teams once races are entered")
            bok = false
        }
        
        if bok {
            let useTeam1 = (sender.tag==1)
            var bContinue = false
            var userTextField = UITextField() //textfile used in the closure
            userTextField.autocapitalizationType = .words
            
            let alert = UIAlertController(title: "Add New Team", message: "", preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Add Team", style: .default) {
                (action) in
                
                //var item = Item(thetitle: userTextField.text!)
                let newName = userTextField.text!
                
                if !newName.isEmpty {
                    bContinue = !self.myFunc.isDuplicateClub(newClubname: newName)
                }
                
                if bContinue {
                    
                    do {
                        try self.realm.write {
                            let newClub = SwimClub()
                            newClub.clubID = self.myDefs.getNextClubId()
                            newClub.clubName = newName
                            newClub.isDefault = false
                            self.realm.add(newClub)
                            if useTeam1 {
                                self.lblTeam1.text = newName
                                self.currentMeet.selectedTeams[0] = newClub
                                
                            }else{
                                self.lblTeam2.text = newName
                                if self.currentMeet.selectedTeams.count == 1 {
                                    self.currentMeet.selectedTeams.append(newClub)
                                    
                                }else{
                                    self.currentMeet.selectedTeams[1] = newClub
                                    
                                }
                            }
                            self.loadPickerViewTeams()
                            
                        }
                    } catch {
                        print("Error saving items: \(error)")
                    }
                    
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (action) in
                self.removeKeyBoard()
            }
            
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Create New Team"
                alertTextField.autocapitalizationType = .words
                userTextField = alertTextField
            }
            
            alert.addAction(cancelAction)
            alert.addAction(alertAction)
            
            present(alert, animated: true, completion: nil)
        //self.saveData(item: item)
        }
    }
    
    
   
    
    
    @IBAction func pickTeam(_ sender: UIButton) {
        removeKeyBoard()
        var bok = true
       
        pickingTeam1 = sender.tag == 1
        
        if pickerTeams.isHidden {
            if !pickingTeam1 && pickerTeamItems?.count == 1  {
                showError(errmsg: "You only have one team in the database. You will need to create another team using the + buttons on the left")
                bok = false
            }else{
                if currentMeet.selectedEvents.count != 0 {
                    showError(errmsg: "Cant change teams once races are entered")
                    bok = false
                }
            }
        }else{
            bok = false
        }
        if bok {
            pickerTeams.isHidden = false
            pickerTeams.bringSubviewToFront(self.view)
        }else{
            pickerTeams.isHidden = true
        }
    }
    //MARK: - Errors
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func removeKeyBoard() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == eventSeg {
            let vc = segue.destination as! EventViewController
            vc.selectedDualMeet = currentMeet
            vc.currentEvent = selectedEvent
            vc.dualMeetdelegate = self
        }else{
            if segue.identifier == resultSeg {
                let vc = segue.destination as! ResultsViewController
                vc.selectedDualMeet = currentMeet
                vc.currentEvent = selectedEvent
                
            }
        }
    }
    
    func updateDualMeet(dualMeet: DualMeet) {
        currentMeet = dualMeet
        loadEvents()
        myTableView.reloadData()
        
    }

}

extension DualMeetViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return eventList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //dualEventCell
         let cell = tableView.dequeueReusableCell(withIdentifier: "dualEventCell", for: indexPath)
        let ev = eventList![indexPath.row + indexPath.section]
        
        
        var mainText = String(format:"%d mtrs ",ev.eventDistance)
        if let pse = ev.presetEvent {
            if pse.isRelay {
                mainText = mainText + " Relay "
            }
        }
        
        var detailText = ""
        if ev.eventResults.count != 0 {
            detailText = String(format:"%d entrants",ev.eventResults.count)
        }
        
        if ev.isFinished {
            detailText += " RACE COMPLETED"
        }
        cell.textLabel?.font = UIFont(name:"Helvetica", size:40.0)
        
        cell.detailTextLabel?.font = UIFont(name:"Helvetica", size:20.0);
        
        cell.detailTextLabel?.textColor = UIColor.red
        
        cell.textLabel?.text = mainText
        
        cell.detailTextLabel?.text = detailText
        
        return cell
        
    }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = eventList![indexPath.row + indexPath.section]
        if selectedEvent.isFinished {
            performSegue(withIdentifier: resultSeg, sender: self)
        }else{
            performSegue(withIdentifier: eventSeg, sender: self)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let ev = eventList![indexPath.row + indexPath.section]
        return !ev.isFinished
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ev = eventList![indexPath.row + indexPath.section]
            let evResults = ev.eventResults
            do {
                try realm.write {
                    
                    //remove the event result from the member
                    for eResult in evResults {
                        if  let thismem = eResult.myMember.first {
                            //print(thismem.memberName)
                            if let mxm = thismem.eventResults.index(where: {$0.eventResultId == eResult.eventResultId}) {
                                thismem.eventResults.remove(at: mxm)
                            }
                            
                            
                        }
                        
                    }
                    if let mxm = currentMeet.selectedEvents.index(where:{$0.eventID == ev.eventID}) {
                        currentMeet.selectedEvents.remove(at: mxm)
                    }
                    
                    realm.delete(evResults)
                    realm.delete(ev)
                    
                }
            }catch{
                showError(errmsg: "Cant remove result")
            }
            loadEvents()
            myTableView.reloadData()
        }
    }
    
}

extension DualMeetViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    //Ive got two pickerviewws. One with Preset meet info and one with club info thats used in 2 places
    func loadPickerViews() {
         pickerTeams = myFunc.makePickerView()
        pickerTeams.delegate = self
        pickerTeams.dataSource = self
        
        pickerTeams.tag = 1
        
        view.addSubview(pickerTeams)
        
        loadPickerViewTeams()
        
        removePickerViews()
        
    }
    
    func removePickerViews() {
        pickerTeams.isHidden = true
        
    }
    
    
    func loadPickerViewTeams() {
        pickerTeamItems = realm.objects(SwimClub.self).sorted(byKeyPath: "clubID")
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
            return pickerTeamItems!.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
            //let sc = pickerTeamItems![row]
            //print("\(lastSelectedTeam!.clubName)")
            return pickerTeamItems![row].clubName
        
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
            let thisteam = pickerTeamItems![row]
            
            if pickingTeam1 {
                lblTeam1.text = thisteam.clubName
                currentMeet.selectedTeams[0] = thisteam //0 will always exist
            }else{
                lblTeam2.text = thisteam.clubName
                if currentMeet.selectedTeams.count == 1 {
                    currentMeet.selectedTeams.append(thisteam)
                }else{
                    currentMeet.selectedTeams[1] = thisteam
                }
                
                
            }
        
       //COME BACK NEED TO VAIDATE CANT CHANGE TEAM ONCE EVENTS ARE IN
        
        pickerView.isHidden = true
        
        
        
    }
    
    
}
