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
 UITableViewDataSource,UITableViewDelegate,StoreFiltersDelegate {

    var timer : Timer!
    var timerOn = false
    var useRaceNos = false
    var returnFromMembers = false
    var eventIsRunning = false //if true then the current even is running so we start it back off
    
    var isRelay = false
    
    var usePresetEvents = false
    var noSeconds : Int = 1
    
    var lastSelectedAgeGroup : PresetEventAgeGroups?
    var lastSelectedTeam : SwimClub?
    
    var pickingTeam1 : Bool = false //when the team picker view cmes up i need to know which label to retrun the result
    
    let realm = try! Realm()
    
    var currentEvent = Event()
    
    var eventResults : Results<EventResult>?
    var pickerTeamItems : Results<SwimClub>?
    var pickerPresetEventItems : Results<PresetEvent>?
    var eventHasAgeGroups = false
    //var presetEventExtension = PresetEventExtension()
    
    
    var groupDict : [String : [EventResult]] = [:]
    var sectionAgeGroups : [PresetEventAgeGroups] = []
    
    
    //each group will be example Seas the limit Team A
    var sectionRelayGroups : [(displayname:String, clubname:String, relayNo:Int)] = []
    
    
    private var datepicker : UIDatePicker?
    
    let eventToMemberseg = "eventToMembers"
    let eventToResultsseg = "eventToResults"
    let myDefs = appUserDefaults()
    let myFunc = appFunctions()
    
    var origStartFrame = CGRect(x: 1.0, y: 1.0, width: 1.0, height: 1.0)
    var origTableFrame = CGRect(x: 1.0, y: 1.0, width: 1.0, height: 1.0)
    var origDetailsFrame = CGRect(x: 1.0, y: 1.0, width: 1.0, height: 1.0)
    
    var origInternalDetailsFrame = CGRect(x: 8.0, y: 60.0, width: 750.0, height: 170.0)
    
    var pickerViewFrame = CGRect(x: 120.0, y: 100.0, width: 600.00, height: 143.0)
    var defSwimClub = SwimClub()
    
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtDistance: UITextField!
    @IBOutlet weak var opRaceNo: UISwitch!
    //internal presetview
    
    @IBOutlet weak var lblIPMeet: UILabel!
    @IBOutlet weak var lblIPTeam1: UILabel!
    @IBOutlet weak var lblIPTeam2: UILabel!
    
    @IBOutlet weak var btnPickTeams1: UIButton!
    
    @IBOutlet weak var btnPickEvent: UIButton!
    
    @IBOutlet weak var btnPickTeams2: UIButton!
    
    
    @IBOutlet weak var lblEventDate: UILabel!
    
   
    
    @IBOutlet weak var btnEventDate: UITextField! //yes ots a text filed
    
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var lblTimeDisplay: UILabel!
    
    
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var startView: UIView!
    
    @IBOutlet weak var detailView: UIView!
    
    @IBOutlet weak var exhibitionView: UIView!
    @IBOutlet weak var dualmeetView: UIView!
    
    
    var pickerTeams : UIPickerView!
    var pickerPresetEvent : UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defSwimClub = myDefs.getDefSwimClub()
        
        if currentEvent.eventID  == 0 && currentEvent.selectedTeams.count == 0 {
            currentEvent.selectedTeams.append(defSwimClub)
        }
        
        if currentEvent.eventID != 0 {
            if let pse = currentEvent.presetEvent {
                isRelay = pse.isRelay
            }
        }
        loadPickerViews()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        
        btnReset.layer.borderColor = UIColor.white.cgColor
        btnStart.layer.borderColor = UIColor.white.cgColor
        
        
        origStartFrame = startView.frame
        origTableFrame = myTableView.frame
        origDetailsFrame = detailView.frame
        
        
        configureDatePicker()
        
        exhibitionView.backgroundColor = UIColor.clear
        dualmeetView.backgroundColor = UIColor.clear
  
        if let ev = currentEvent.presetEvent {
            eventHasAgeGroups = ev.eventAgeGroups.count != 0
        }
        
        changeBorderColours()
        
        loadEventDetails()
        
        loadEventResults()
        
        if usePresetEvents {
           dualmeetView.frame = origInternalDetailsFrame
            
        }else{
            exhibitionView.frame = origInternalDetailsFrame
        }
        
        exhibitionView.isHidden = usePresetEvents
        dualmeetView.isHidden = !usePresetEvents
        
        if usePresetEvents  {
            initPresetEvent()
            if currentEvent.eventID != 0 && currentEvent.eventResults.count != 0 {
                dualmeetView.isUserInteractionEnabled = false //cant chnage if its been saved
            }
            
            
        }
        
       
    }

    func initPresetEvent() {
        if currentEvent.eventID == 0 {
            //set team 1 to be the default swim club
            lblIPTeam1.text = defSwimClub.clubName
            
                do {
                    try realm.write {
                        self.currentEvent.selectedTeams.append(defSwimClub)
                    }
                }catch{
                    self.showError(errmsg: "Could not initailise")
                }
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        if returnFromMembers {
            returnFromMembers = false
            loadEventResults()
            //myTableView.reloadData()
        }
    }
    //MARK: - Datepicker
    
    
    
   
    
    
    func configureDatePicker() {
        datepicker = UIDatePicker()
        datepicker?.datePickerMode = .date
        btnEventDate.inputView = datepicker
        if currentEvent.eventID == 0 {
            datepicker?.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        }else{
           datepicker?.date = currentEvent.eventDate
        }
        
        datepicker?.addTarget(self, action: #selector(EventViewController.dateChanged(datepicker:)), for: .valueChanged)
        
    }
    
    @objc func dateChanged(datepicker:UIDatePicker) {
        
        lblEventDate.text = myFunc.formatDate(thedate: datepicker.date)
        
        //COME BACK - need to update photos and member names blah blah ??
        removeKeyBoard()
        
    }
    //MARK: - Actions

    
    
    
    @IBAction func btnPickPresetEvent(_ sender: UIButton) {
        removeKeyBoard()
        pickerPresetEvent.isHidden = false
         pickerPresetEvent.bringSubviewToFront(self.view)
    }
    
    
    @IBAction func btnPickTeams(_ sender: UIButton) {
            removeKeyBoard()
            pickerTeams.isHidden = false
            pickingTeam1 = sender.tag == 1
       pickerTeams.bringSubviewToFront(self.view)
    }
    
    
    @IBAction func useRaceNosChanged(_ sender: UISwitch) {
        removeKeyBoard()
        useRaceNos = sender.isOn
        if currentEvent.eventID != 0 {
            resetEvent()
        }
    }
    
    @IBAction func btnResetClicked(_ sender: UIButton) {
        removeKeyBoard()
        
        if timerOn {
            stopTimer()
        }
        
      resetEvent()
        
    }
    
    func resetEvent() {
        do {
            try realm.write {
                if let dist = Int(txtDistance.text!) {
                    currentEvent.eventDistance = dist
                }
                currentEvent.useRaceNos = opRaceNo.isOn
                
                for er in currentEvent.eventResults {
                    let mem = er.myMember.first!
                    er.resultSeconds = 0
                    er.expectedSeconds = myFunc.adjustOnekSecondsForDistance(distance: currentEvent.eventDistance , timeinSeconds: mem.onekSeconds)
                    if useRaceNos && er.raceNo == 0 {
                        er.raceNo = myDefs.getNextRaceNo()
                    }
                    er.activeForRelay = false
                    //print("\(er.expectedSeconds)")
                }
                
            }
            loadEventResults()
            moveStartViewDown()
            myTableView.reloadData()
        }catch{
            showError(errmsg: "Cant Reset")
        }
        
        changeBorderColours()
        
        lblTimeDisplay.text = "00:00:00"
        noSeconds=1;
        btnStart.setTitle("Start", for: .normal)
        myTableView.reloadData()
    }
    @IBAction func btnDone(_ sender: UIBarButtonItem) {
        //delete event if no members in event
        
        if !timerOn {
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
           
            
            self.navigationController?.popViewController(animated: true)
        }else{
            showError(errmsg: "Finish or Reset the event or press home to exit")
        }
    }
    
    @IBAction func startStopTimer(_ sender: UIButton) {
         removeKeyBoard()
        var bContinue = true
        var finishTheEvent = false
        if !timerOn {
            /*we are startng so check we have people in the race*/
            if currentEvent.eventResults.count == 0 {
                
                bContinue = false
            }
        }
        if (bContinue) {
            if timerOn {
                timer.invalidate()
                //finish the event
                finishTheEvent = true
                
            }else {
                
                
               doEventStart()
            }
            
            //timerOn = !timerOn
            
            if finishTheEvent {
                finishEvent()
            }else{
                 myTableView.reloadData()
            }
           
            
        }
        changeBorderColours()
    }
    
    @IBAction func btnAddMembers(_ sender: UIBarButtonItem) {
        //lets save the event here
        view.endEditing(true)
        if !timerOn {
            removeKeyBoard()
            
            if saveEvent() {
                performSegue(withIdentifier: eventToMemberseg, sender: self)
            }
        }else{
            showError(errmsg: "Cant add members while the event is running")
        }
    }
    
    func changeBorderColours() {
        var myCol : CGColor
        if timerOn {
            myCol = UIColor(hexString: "8EFF25")!.cgColor //same colour as start buttion
        }else{
            myCol = UIColor.red.cgColor
        }
        
        myTableView.layer.borderColor = myCol
        lblTimeDisplay.layer.borderColor = myCol
        
    }
    //MARK: - TableView stuff
    
    func finishEvent() {
        do {
            try realm.write {
                currentEvent.isFinished = true
                if self.eventResults?.count != 0 {
                    for er in self.eventResults! {
                        if er.resultSeconds == 0 {
                            //didnt finish so remove them from the event
                            let mem = er.myMember.first
                            if let mxm = mem?.eventResults.index(where: {$0.eventResultId == er.eventResultId}) {
                                mem?.eventResults.remove(at: mxm)
                            }
                           
                            realm.delete(er)
                        }
                    }
                }
                
            }
        }catch{
            showError(errmsg: "Cant finish Event")
        }
        stopTimer()
        timerOn = false
        
        performSegue(withIdentifier: eventToResultsseg, sender: self)
    }
    
    
    func stopTimer() {
        timer.invalidate()
        timerOn = false
    }
    
    func removeKeyBoard() {
         view.endEditing(true)
    }
    
    
    func loadEventDetails() {
        var sDateText = ""
        if currentEvent.eventDistance != 0 {
            txtDistance.text = "\(currentEvent.eventDistance)"
            sDateText = myFunc.formatDate(thedate: currentEvent.eventDate)
            if currentEvent.hasPresetEvent {
                lblIPMeet.text = currentEvent.presetEvent?.getPresetName()
                lblIPTeam1.text = currentEvent.selectedTeams[0].clubName
                lastSelectedTeam = currentEvent.selectedTeams[0]
                if currentEvent.selectedTeams.count > 1 {
                    lblIPTeam2.text = currentEvent.selectedTeams[1].clubName
                }
            }
        }else{
            txtDistance.text = ""
        }
        
        
        lblEventDate.text = sDateText
        txtLocation.text = currentEvent.eventLocation
        
        opRaceNo.isOn = currentEvent.useRaceNos
        useRaceNos = currentEvent.useRaceNos
        
    }
    
    func loadEventResults() {
       
        if currentEvent.eventResults.count != 0 {
            if isRelay {
                if timerOn {
                    eventResults = currentEvent.eventResults.filter("activeForRelay=true").sorted(byKeyPath: "getRelayOrder()", ascending: true)
                }else{
                    eventResults = currentEvent.eventResults.sorted(byKeyPath: "getRelayOrder()", ascending: true)
                }
            }else{
                eventResults = currentEvent.eventResults.filter("resultSeconds=0").sorted(byKeyPath: "expectedSeconds", ascending: true)
            }
            
            if eventResults?.count != 0 {
                if eventIsRunning  {
                    //come back from a home button close where an event was running
                    let secondsElapsed = myDefs.getRunningEventSecondsStopped()
                    let addseconds = myFunc.getDateDiffSeconds(fromDate: myDefs.getRunningEventStopDate())
                    
                    let dateFormatter = DateFormatter()
                    
                    dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
                    noSeconds = secondsElapsed + addseconds + 1
                    myDefs.setRunningEventID(eventID: 0) //turn this off
                    myDefs.setRunningEventSecondsStopped(clockseconds: 0)
                    eventIsRunning = false
                    doEventStart()
                }else{
                    if (eventHasAgeGroups || isRelay) && !timerOn {
                        loadGroupTableData()
                    }else{
                        groupDict.removeAll()
                        sectionAgeGroups.removeAll()
                        sectionRelayGroups.removeAll()
                    }
                }
            }

        }
        
        myTableView.reloadData()
        
    }
    
    func loadGroupTableData() {
        if groupDict.count != 0 {
            groupDict.removeAll()
        }
        
        if sectionAgeGroups.count != 0 {
            sectionAgeGroups.removeAll()
        }
        
        if sectionRelayGroups.count != 0 {
            sectionRelayGroups.removeAll()
        }
        
        if useAgeGroupSectionsinTableView() {
            for er in eventResults! {
                /*var groupDict : [String : [EventResult]] = [:]
                var sectionGroups : [PresetEventAgeGroups] = []
                 */
                if let grp = er.selectedAgeCategory.first {
                
                    if sectionAgeGroups.count == 0 {
                        sectionAgeGroups.append(grp)
                    }else{
                        if let _ = sectionAgeGroups.index(where: {$0.presetAgeGroupName == grp.presetAgeGroupName}) {
                            
                        }else{
                            sectionAgeGroups.append(grp)
                        }
                    }
                   
                    //groupDict[grp.presetAgeGroupName]?.append(er)
                    //print("\(groupDict[grp.presetAgeGroupName]?.count ?? "Help")")
                }
                sectionAgeGroups = sectionAgeGroups.sorted(by: {$0.presetAgeGroupID < $1.presetAgeGroupID})
            }
            
            for sd in sectionAgeGroups {
                var mArr = Array(eventResults!.filter("ANY selectedAgeCategory.presetAgeGroupName = %@",sd.presetAgeGroupName))
                mArr = mArr.sorted(by: {$0.myMember.first!.gender < $1.myMember.first!.gender})
                groupDict[sd.presetAgeGroupName] = mArr
            }
        }else{
            if useRelaySectionsInTableView() {
                 for er in eventResults! {
                    //var sectionRelayGroups : [(displayname:String, clubname:String, relayLetter:String)] = []
                    if let em = er.myMember.first {
                        if let cb = em.myClub.first {
                            let sDisplay = String(format:"%@ - Team %@",cb.clubName,er.getRelayLetter())
                            if sectionRelayGroups.count == 0 {
                                sectionRelayGroups.append((displayname: sDisplay, clubname: cb.clubName, relayNo: er.relayNo))
                            }else{
                                if let _ = sectionRelayGroups.index(where: {$0.displayname == sDisplay}) {
                                    
                                }else{
                                   sectionRelayGroups.append((displayname: sDisplay, clubname: cb.clubName, relayNo: er.relayNo))
                                }
                            }
                        }
                        
                    }
                 }
                //COME BACK
//                sectionRelayGroups = sectionRelayGroups.sorted(by: {$0.relayLetter < $1.relayLetter})
//                for sd in sectionRelayGroups {
//                    var mArr = Array(eventResults!.filter("ANY myMember.myClub.clubName = %@ AND relayNo = %d",sd.clubname,sd.relayNo))
//                    mArr = mArr.sorted(by: {$0.display})
//                    groupDict[sd.displayname] = mArr
//                }
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if useAgeGroupSectionsinTableView() {
            return sectionAgeGroups.count
        }else{
            return eventResults?.count ?? 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if useAgeGroupSectionsinTableView() {
            //print("\(sectionGroups[section].presetAgeGroupName)")
            return (groupDict[sectionAgeGroups[section].presetAgeGroupName]?.count)!
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if useAgeGroupSectionsinTableView() {
            return 30.0
        }else{
            return 3.0
        }
        
    }
    
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let offset : CGFloat = 5.0

    
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: myTableView.frame.size.width - (offset * 2.0), height: 100.0))
    
        if useAgeGroupSectionsinTableView() {
            var sHeader = sectionAgeGroups[section].presetAgeGroupName
            if let myArray = groupDict[sectionAgeGroups[section].presetAgeGroupName] {
                sHeader += String(format:"  (%d entrants)" ,myArray.count)
            }
            headerView.backgroundColor = UIColor.black
            let label = UILabel(frame: CGRect(x: 0, y: -5, width: myTableView.frame.size.width, height: 30.0))
            label.clipsToBounds = true
            label.layer.cornerRadius = 5.0
            label.backgroundColor = UIColor.black
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont(name: "Helvetica", size: 25.0)
            label.text = sHeader
            //print(sectionGroups[section].groupName)
            headerView.addSubview(label)
            
        }else{
            headerView.backgroundColor = UIColor.clear
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        configureCell(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:IndexPath) {
        var er = EventResult()
        if useAgeGroupSectionsinTableView() {
            if let myArray = groupDict[sectionAgeGroups[indexPath.section].presetAgeGroupName] {
                er = myArray[indexPath.row]
            }
           
        }else{
           er = eventResults![indexPath.row + indexPath.section]
        }
        
        let mem = er.myMember.first!
        let grp = mem.myClub.first!
        
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 35.0)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 20.0)
        
        //NSLog(@"memberid=%d name=%@",lh.member.memberid,lh.member.membername);
        
        var txtLabel : String = ""
        
        if currentEvent.useRaceNos {
            txtLabel = ("\(er.raceNo) - ")
        }
        txtLabel += mem.memberName
        
        var dtText = String(format:"  (%@)   Age: %d",mem.gender,mem.age())
        dtText = dtText + String(format:"  Team: %@",grp.clubName)
            
        
       let dtlLabel = "Est Time: " + myFunc.convertSecondsToTime(timeinseconds: er.expectedSeconds) + dtText
        
       
        cell.textLabel?.text = txtLabel
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
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let er = eventResults![indexPath.row + indexPath.section]
        if timerOn {
            do {
                try realm.write {
                    let resultseconds = myFunc.convertTimeToSeconds(thetimeClock: lblTimeDisplay.text!)
                    er.rawresultSeconds = resultseconds
                    er.resultSeconds = resultseconds - er.staggerStartBy
                    er.diffSeconds = er.resultSeconds - er.expectedSeconds
                    if let mem = er.myMember.first {
                        er.ageAtEvent = mem.age() //this is how old they are when the event was started
                    }
                }
                
                
            }catch{
                showError(errmsg: "Cannot find this result")
            }
            
            loadEventResults()
            if eventResults?.count == 0 {
                
                finishEvent()
            }
        }else{
            //MARK: -COME BACK 1
            //go to member update estimate and maybe a photo change club
        }
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return !timerOn
    }
    
    
    
    // Override to support editing the table view.
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let er = eventResults![indexPath.row + indexPath.section]
            do {
                try realm.write {
                    let mem = er.myMember.first
                    //remove the event result from the member
                    if let mxm = mem?.eventResults.index(where: {$0.eventResultId == er.eventResultId}) {
                        mem?.eventResults.remove(at: mxm)
                    }
                    realm.delete(er)
                    
                }
            }catch{
                showError(errmsg: "Cant remove result")
            }
            loadEventResults()
        }
    }
    
    
    
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == eventToMemberseg {
            returnFromMembers = true
            let vc = segue.destination as! MembersForEventViewController
            vc.selectedEvent = currentEvent
            vc.usePreset = usePresetEvents
            if let sc = lastSelectedTeam {
                //print("\(sc.clubName)")
                vc.lastTeamFilter = sc
            }else{
                vc.lastTeamFilter = currentEvent.selectedTeams[0]
            }
            if let agp = lastSelectedAgeGroup {
                //print(agp.presetAgeGroupName)
                vc.lastAgeGroupFilter = agp
            }
            vc.delegate = self
        }else {
            if segue.identifier == eventToResultsseg {
                let vc = segue.destination as! ResultsViewController
                vc.currentEvent = currentEvent
            }
        }
    }
    
    //MARK: - Data stuff
    func canChangeDetails() -> Bool {
        return currentEvent.eventID == 0 && currentEvent.eventResults.count == 0
            
        
    }
    @IBAction func addNewTeam(_ sender: UIButton) {
        removePickerViews()
        
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
                                self.lblIPTeam1.text = newName
                                self.currentEvent.selectedTeams[0] = newClub
                                
                            }else{
                                self.lblIPTeam2.text = newName
                                if self.currentEvent.selectedTeams.count == 1 {
                                    self.currentEvent.selectedTeams.append(newClub)
                                    
                                }else{
                                    self.currentEvent.selectedTeams[1] = newClub
                                   
                                }
                            }
                            self.loadPickerViewTeams()
                            self.lastSelectedTeam = newClub
                            //print(newClub.clubName)
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
    
    func saveEvent() -> Bool {
        var ok = false
            if validateEvent() {
                let df = DateFormatter()
                df.dateFormat = myFunc.getGlobalDateFormat()
                do {
                    try realm.write {
                        currentEvent.eventLocation = txtLocation.text!
                        if usePresetEvents {
                            currentEvent.hasPresetEvent=true
                            currentEvent.eventDistance = currentEvent.presetEvent!.distance
                            
                        }else{
                            currentEvent.eventDistance = Int(txtDistance.text!)!
                            currentEvent.useRaceNos = useRaceNos
                        }
                        
                        currentEvent.eventDate = df.date(from: lblEventDate.text!)!
                        if currentEvent.eventID == 0 {
                            
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
        
        
        if let sEvent = lblEventDate.text {
            if sEvent.isEmpty {
                sErrmsg = "Please select an Event Date"
            }
            
        }else{
            sErrmsg = "Please select an Event Date"
        }
        
        if usePresetEvents {
            if let _ = currentEvent.presetEvent {
                
            }else{
                sErrmsg = "Please select a Preset Distance"
            }
        }else {
            if let sDistance = txtDistance.text {
                if sDistance.isEmpty {
                    sErrmsg = "Please enter a distance"
                }
            }else{
                sErrmsg = "Please enter a distance"
            }
        }
        
        if !sErrmsg.isEmpty {
            showError(errmsg: sErrmsg)
        }
        
        return sErrmsg.isEmpty
    }
    
    //MARK: Timer
func doEventStart() {
    btnStart.setTitle("Finish",for: .normal)
    timerOn = true
    
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    
    if saveEvent() {
        moveStartViewUp()
        loadEventResults()
        //myTableView.reloadData()
    }
    
}
    
    func useAgeGroupSectionsinTableView() -> Bool {
        return (!timerOn) && eventHasAgeGroups
    }
    
    func useRelaySectionsInTableView() -> Bool {
        return (!timerOn) && isRelay
    }
    
    func moveStartViewUp() {
        let xPosition = origDetailsFrame.origin.x + 3.0
        
        let yPosition = origDetailsFrame.origin.y + 8.0 //off set from the top
        
        let myTableNewHeight = origTableFrame.size.height + (origDetailsFrame.size.height)
        let myTableYPosition = origDetailsFrame.origin.y + origStartFrame.size.height
        
        UIView.animate(withDuration: 1, animations: {
            
            
            self.startView.frame = CGRect(x: xPosition, y: yPosition, width: self.origStartFrame.size.width, height: self.origStartFrame.size.height)
            
            self.myTableView.frame = CGRect(x: self.origTableFrame.origin.x, y: myTableYPosition, width: self.origTableFrame.size.width, height: myTableNewHeight)
            
           
            self.detailView.frame = CGRect(x: xPosition + self.view.frame.size.width, y: yPosition, width: self.origDetailsFrame.size.width, height: self.origDetailsFrame.size.height)
            
            self.detailView.isHidden = true
            
            self.view.layoutIfNeeded()
        })

    }
    
    func moveStartViewDown() {

        UIView.animate(withDuration: 1, animations: {
            
            
            self.startView.frame = self.origStartFrame
             self.myTableView.frame = self.origTableFrame
            self.detailView.frame = self.origDetailsFrame
            self.detailView.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    
    @objc func updateTimer() {
       
            noSeconds += 1
    
        lblTimeDisplay.text = myFunc.convertSecondsToTime(timeinseconds: noSeconds)
    
    
    }
    //MARK: - Delegate Store Filters
    func updateDefaultFilters(team : SwimClub,ageGroup: PresetEventAgeGroups?) {
        lastSelectedTeam = team
        if let ag = ageGroup {
            //print(ag.presetAgeGroupName)
            lastSelectedAgeGroup = ag
        }
        
    }
    //MARK: - Errors
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
}

//MARK: - PickerView

extension EventViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    //Ive got two pickerviewws. One with Preset meet info and one with club info thats used in 2 places
    func loadPickerViews() {
        pickerTeams = UIPickerView()
        pickerPresetEvent = UIPickerView()
        configurePickerView(pckview: pickerTeams)
        pickerTeams.tag = 1
        configurePickerView(pckview: pickerPresetEvent)
        pickerPresetEvent.tag = 2
        
        view.addSubview(pickerTeams)
        view.addSubview(pickerPresetEvent)
        loadPickerViewTeams()
        loadPickViewPresetEvents()
        removePickerViews()
        
    }
    
    func removePickerViews() {
        pickerTeams.isHidden = true
        pickerPresetEvent.isHidden = true
    }
    
    func configurePickerView(pckview:UIPickerView) {
        
        pckview.frame = pickerViewFrame
        pckview.backgroundColor = UIColor(hexString: "89D8FC")
        pckview.layer.cornerRadius = 10.0
        pckview.delegate = self
        pckview.dataSource = self
    }
    
    func loadPickerViewTeams() {
        pickerTeamItems = realm.objects(SwimClub.self).sorted(byKeyPath: "clubID")
    }
    
    func loadPickViewPresetEvents() {
        pickerPresetEventItems = realm.objects(PresetEvent.self).sorted(byKeyPath: "presetEventID")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return pickerTeamItems!.count
        }else{
            return pickerPresetEventItems!.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
         if pickerView.tag == 1 {
            //let sc = pickerTeamItems![row]
            //print("\(lastSelectedTeam!.clubName)")
            return pickerTeamItems![row].clubName
         }else{
            return pickerPresetEventItems![row].getPresetName()
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        var bOK = true
        if pickerView.tag == 1 {
            let thisteam = pickerTeamItems![row]
            
                if pickingTeam1 {
                    lblIPTeam1.text = thisteam.clubName
                    currentEvent.selectedTeams[0] = thisteam //0 will always exist
                }else{
                    lblIPTeam2.text = thisteam.clubName
                    if currentEvent.selectedTeams.count == 1 {
                        currentEvent.selectedTeams.append(thisteam)
                    }else{
                        currentEvent.selectedTeams[1] = thisteam
                    }
                    
                    
                }
            
            lastSelectedTeam = thisteam
            //print("\(thisteam.clubName)")
        }else{
            
            let thispse = pickerPresetEventItems![row]
            if let pse = currentEvent.presetEvent {
                if currentEvent.eventResults.count != 0 && pse.presetEventID != thispse.presetEventID {
                   bOK = false
                    showError(errmsg: "Once members are selected you cant change the event rules")
                }
                
                
            }
            
            if bOK {
                lblIPMeet.text = pickerPresetEventItems![row].getPresetName()
                
                currentEvent.presetEvent = thispse
                eventHasAgeGroups = thispse.eventAgeGroups.count != 0
                isRelay = thispse.isRelay
                
            }
           
        }
        pickerView.isHidden = true
        //Im gonna remove the member from the list
        
    }

    
}
