//
//  EventViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift

protocol DualMeetDelegate {
    func updateDualMeet(dualMeet:DualMeet)
}

class EventViewController: UIViewController,
 UITableViewDataSource,UITableViewDelegate,StoreFiltersDelegate {

    let realm = try! Realm()
    var dualMeetdelegate : DualMeetDelegate?
    
    var timer : Timer!
    var timerOn = false
    var useRaceNos = false
    var returnFromMembers = false
    var isDualMeet = false
    var eventIsRunning = false //if true then the current even is running so we start it back off
    
    var isRelay = false
    
    //var usePresetEvents = false
    var noSeconds : Int = 1
    
    //used for filtering the members for eventlist
    var lastSelectedAgeGroup : PresetEventAgeGroups?
    var lastSelectedTeam : SwimClub?
    
    //if called from the dua meet window then selectedDualMeet will be set. //COME BACK watch for returning event from home button
    var selectedDualMeet = DualMeet()
    var currentEvent = Event() //this will be
    
    var eventResults : [EventResult] = []
    
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
    
    
    @IBOutlet weak var btnPickEvent: UIButton!
    
    
    
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
    
    
    
    var pickerPresetEvent : UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if selectedDualMeet.dualMeetID != 0 {
            isDualMeet = true
            defSwimClub = selectedDualMeet.selectedTeams[0]
        }else{
           defSwimClub = myDefs.getDefSwimClub()
            lastSelectedTeam = defSwimClub
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
        
        if isDualMeet {
           dualmeetView.frame = origInternalDetailsFrame
            
        }else{
            exhibitionView.frame = origInternalDetailsFrame
        }
        
        exhibitionView.isHidden = isDualMeet
        dualmeetView.isHidden = !isDualMeet
        btnEventDate.isHidden = isDualMeet
        
        txtLocation.isUserInteractionEnabled = !isDualMeet
        
        if isDualMeet  {
            
            if currentEvent.eventID != 0 && currentEvent.eventResults.count != 0 {
                dualmeetView.isUserInteractionEnabled = false //cant chnage if its been saved
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
                    er.activeForRelay = false
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
            if isDualMeet {
                dualMeetdelegate?.updateDualMeet(dualMeet:selectedDualMeet)
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
            var bok = true
            if let pse = currentEvent.presetEvent {
                if currentEvent.eventResults.count == pse.maxPerEvent {
                    bok = false
                    showError(errmsg: String(format:"Race is full, max entrants is %d",pse.maxPerEvent))
                }
            }
            
            if bok {
               
                removeKeyBoard()
                
                if saveEvent() {
                    performSegue(withIdentifier: eventToMemberseg, sender: self)
                }
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
                
                
                if self.eventResults.count != 0 {
                    for er in self.eventResults {
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
                if self.isDualMeet {
                    var evNotFinished = 0
                    for ev in self.selectedDualMeet.selectedEvents {
                        if ev.eventID != self.currentEvent.eventID && !ev.isFinished {
                            evNotFinished += 1
                        }
                    }
                    if evNotFinished == 0 {
                        self.selectedDualMeet.isFinished = true //finish the dual meet once all events are finished
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
        var sLocation = ""
        
        if isDualMeet {
            lblIPMeet.text = currentEvent.presetEvent?.getPresetName()
            lblIPTeam1.text = selectedDualMeet.selectedTeams[0].clubName
            sDateText =  myFunc.formatDate(thedate: selectedDualMeet.meetDate)
            sLocation = selectedDualMeet.meetLocation
            lastSelectedTeam = selectedDualMeet.selectedTeams[0]
            if selectedDualMeet.selectedTeams.count > 1 {
                lblIPTeam2.text = selectedDualMeet.selectedTeams[1].clubName
            }
           
        }else{
            if currentEvent.eventDistance != 0 {
                txtDistance.text = "\(currentEvent.eventDistance)"
                sLocation = currentEvent.eventLocation
                sDateText = myFunc.formatDate(thedate: currentEvent.eventDate)
                
            
            }
            
        }
        
        opRaceNo.isOn = currentEvent.useRaceNos
        useRaceNos = currentEvent.useRaceNos
        
        lblEventDate.text = sDateText
        txtLocation.text = sLocation
        
    }
    
    func startRelay() {
        //idea here is to get al the no 1 swimmers and mark them as ativefor event
        do {
            try realm.write {
                for er in self.currentEvent.eventResults {
                    if er.relayOrder == 1 {
                        er.activeForRelay = true
                    }else{
                        er.activeForRelay = false
                    }
                }
            }
        }catch{
            showError(errmsg: "Cant start relay")
        }
        
        
    }
    func loadEventResults() {
       
        if currentEvent.eventResults.count != 0 {
            if isRelay {
                eventResults = Array(currentEvent.eventResults)
                if timerOn {
                    eventResults = Array(currentEvent.eventResults.filter("activeForRelay=true")).sorted(by: {$0.relayNo < $1.relayNo})
                    
                }else{
                    //eventResults = currentEvent.eventResults.sorted(byKeyPath: "getRelayOrder()", ascending: true)
                    eventResults = Array(currentEvent.eventResults).sorted(by: {$0.relayNo < $1.relayNo && $0.relayOrder < $1.relayOrder})
                }
            }else{
                eventResults = Array(currentEvent.eventResults.filter("resultSeconds=0").sorted(byKeyPath: "expectedSeconds", ascending: true))
            }
            
            if eventResults.count != 0 {
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
            buildSectionsAgeGroup()
        }else{
            if useRelaySectionsInTableView() {
                builSectionsRelay()
            }
        }
    }
    
    func buildSectionsAgeGroup() {
        for er in eventResults {
            /*var groupDict : [String : [EventResult]] = [:]
             var sectionGroups : [PresetEventAgeGroups] = []
             */
            if let grp = er.selectedAgeCategory {
                
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
            //var mArr = eventResults.filter("selectedAgeCategory.presetAgeGroupName = %@",sd.presetAgeGroupName)
            var mArr = eventResults.filter({$0.selectedAgeCategory!.presetAgeGroupName==sd.presetAgeGroupName})
            mArr = mArr.sorted(by: {$0.myMember.first!.gender < $1.myMember.first!.gender})
            groupDict[sd.presetAgeGroupName] = mArr
        }
    }
    func builSectionsRelay() {
        //first build our groups of clu - Tema A etc
       
            for er in eventResults {
                //var sectionRelayGroups : [(displayname:String, clubname:String, relayLetter:String)] = []
                if let em = er.myMember.first {
                    if let cb = em.myClub.first {
                        let sDisplay = String(format:"%@ - Team %@",cb.clubName,er.getRelayLetter())
                        //print("RelayNo \(er.relayNo) order= \(er.relayOrder)")
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
            
            sectionRelayGroups = sectionRelayGroups.sorted(by: {$0.relayNo < $1.relayNo})
            for sd in sectionRelayGroups {
                var mArr : [EventResult]=[]
                //cant filter using myMeber.MyClub.clbname in realm
                for er in eventResults {
                    if let mem = er.myMember.first {
                        if let myclub = mem.myClub.first {
                            if myclub.clubName == sd.clubname && er.relayNo == sd.relayNo {
                                mArr.append(er)
                            }
                        }
                    }
                }
                mArr = mArr.sorted(by: {$0.relayOrder < $1.relayOrder})
                //print(sd.displayname)
                groupDict[sd.displayname] = mArr
            }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if useAgeGroupSectionsinTableView() {
            return sectionAgeGroups.count
        }else{
            if useRelaySectionsInTableView() {
                return sectionRelayGroups.count
            }else{
                return eventResults.count
            }
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if useAgeGroupSectionsinTableView() {
            //print("\(sectionGroups[section].presetAgeGroupName)")
            return (groupDict[sectionAgeGroups[section].presetAgeGroupName]?.count)!
        }else{
            if useRelaySectionsInTableView() {
                return (groupDict[sectionRelayGroups[section].displayname]?.count)!
            }else{
                return 1
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if useAgeGroupSectionsinTableView() || useRelaySectionsInTableView() {
            return 30.0
        }else{
            return 3.0
        }
        
    }
    
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let offset : CGFloat = 5.0
        var sHeader = ""
    
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: myTableView.frame.size.width - (offset * 2.0), height: 100.0))
    
        if useAgeGroupSectionsinTableView() || useRelaySectionsInTableView() {
            if useAgeGroupSectionsinTableView() {
                let grp = sectionAgeGroups[section]
                sHeader = grp.presetAgeGroupName
                if let myArray = groupDict[grp.presetAgeGroupName] {
                    sHeader += String(format:"  (%d entrants)" ,myArray.count)
                }
                
                if grp.staggerSeconds != 0 {
                    sHeader += String(format:" Start:%@ behind",myFunc.convertSecondsToTime(timeinseconds: grp.staggerSeconds,showMinuteOnly: true))
                }
            }else{
                sHeader = sectionRelayGroups[section].displayname
            }
           
            headerView.backgroundColor = UIColor.black
            let label = UILabel(frame: CGRect(x: 0, y: 1.5, width: myTableView.frame.size.width, height: 30.0))
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
            if useRelaySectionsInTableView() {
                if let myArray = groupDict[sectionRelayGroups[indexPath.section].displayname] {
                    er = myArray[indexPath.row]
                }
                
            }else{
                er = eventResults[indexPath.row + indexPath.section]
            }
           
        }
        
        let mem = er.myMember.first!
        let grp = mem.myClub.first!
        
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 35.0)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 20.0)
        
        
        var txtLabel : String = ""
        
        if currentEvent.useRaceNos {
            txtLabel = ("\(er.raceNo) - ")
        }else{
            if isRelay && timerOn {
                
                cell.textLabel?.font = UIFont(name: "Helvetica", size: 30.0)
                
                txtLabel = String(format:"%@ Team %@ - ",grp.clubName, er.getRelayLetter())
            }
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
        
        
        cell.backgroundColor = myFunc.getTableCellBackgroundColour() //light blue.-- hard setting ths doesnt seem to work as well
        let imgframe = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 75.0)
        
        
        if isRelay && timerOn {
            var theimg = ""
            switch er.relayOrder {
            case 1 :
                theimg = "one"
                break
            case 2 :
                theimg = "two"
                break
            case 3 :
                theimg = "three"
                break
            case 4 :
                theimg = "four"
                break
            default :
                break
            }
        
            let imgRelayNo = UIImageView(image: UIImage(named: theimg))
            //let imgRelayNo = UIImageVi
            imgRelayNo.frame = imgframe
            //imgRelayNo.layer.masksToBounds = true
            imgRelayNo.clipsToBounds = true
            //imgRelayNo.sizeToFit()
            //cell.accessoryView?.frame = imgframe
            cell.accessoryView = imgRelayNo
            cell.accessoryView?.tintColor = UIColor.clear
            cell.accessoryView?.isHidden = false
            
        }else{
            if imgMemberPhoto.image != nil {
                
                
                imgMemberPhoto.frame = imgframe
                imgMemberPhoto.layer.masksToBounds = true
                imgMemberPhoto.layer.cornerRadius = 20.0
                cell.accessoryView = imgMemberPhoto
                cell.accessoryView?.tintColor = UIColor.clear
                cell.accessoryView?.isHidden = false
                
            }else{
                cell.accessoryView?.isHidden = true
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let er = eventResults[indexPath.row + indexPath.section]
        if timerOn {
            do {
                try realm.write {
                    let resultseconds = myFunc.convertTimeToSeconds(thetimeClock: lblTimeDisplay.text!)
                    er.rawresultSeconds = resultseconds
                    er.resultSeconds = resultseconds - er.staggerStartBy
                    er.diffSeconds = er.resultSeconds - er.expectedSeconds
                    //print("\(er.resultSeconds)")
                    if let mem = er.myMember.first {
                        er.ageAtEvent = mem.age() //this is how old they are when the event was started
                    }
                    if self.isRelay {
                        
                        er.activeForRelay = false
                        if er.relayOrder < 4 {
                            //let iNextOrder = er.relayOrder + 1
                            let myNextgroup = Array(self.currentEvent.eventResults).filter({$0.getClubID() == er.getClubID() && $0.relayNo == er.relayNo && $0.relayOrder == er.relayOrder + 1})
                            //let myNextgroup = myArr.filter({$0.relayNo == er.relayNo && $0.relayOrder == er.relayOrder + 1})
                            
                            if myNextgroup.count != 0 {
                                let nexter = myNextgroup.first
                                nexter?.staggerStartBy = resultseconds
                                nexter?.expectedSeconds += resultseconds
                                nexter?.activeForRelay = true
                            }
                        }
                    }
                }
                
                
            }catch{
                showError(errmsg: "Cannot find this result")
            }
            
            loadEventResults()
            if eventResults.count == 0 {
                
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
            var mydelArray : [EventResult] = []
            
            if useAgeGroupSectionsinTableView() {
                if let myArray = groupDict[sectionAgeGroups[indexPath.section].presetAgeGroupName] {
                    
                     mydelArray.append(myArray[indexPath.row])
                }
                
            }else{
                if useRelaySectionsInTableView() {
                    // for a rlay remove all membes of the relay
                    if let myGroup = groupDict[sectionRelayGroups[indexPath.section].displayname] {
                        let er = myGroup[indexPath.row]
                        if let mem = er.myMember.first {
                            mydelArray = myGroup.filter({$0.getClubID() == mem.myClub.first?.clubID && $0.relayNo == er.relayNo})
                        }
                        
                    }
                }else{
                   mydelArray.append(eventResults[indexPath.row + indexPath.section])
                    
                }
            }
            
            
            do {
                try realm.write {
                    
                    //remove the event result from the member
                    for etoremove in mydelArray {
                        if  let thismem = etoremove.myMember.first {
                            //print(thismem.memberName)
                            if let mxm = thismem.eventResults.index(where: {$0.eventResultId == etoremove.eventResultId}) {
                                thismem.eventResults.remove(at: mxm)
                            }
                            if let evmxm = self.currentEvent.eventResults.index(where: {$0.eventResultId == etoremove.eventResultId}) {
                                self.currentEvent.eventResults.remove(at: evmxm)
                            }
                            realm.delete(etoremove)
                        }
                        
                    }
                    self.loadEventResults()
                    
                }
            }catch{
                showError(errmsg: "Cant remove result")
            }
            
            
        }
    }
    
    
    
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == eventToMemberseg {
            returnFromMembers = true
            let vc = segue.destination as! MembersForEventViewController
            vc.selectedEvent = currentEvent
            
            if isDualMeet {
                vc.selectedTeams = Array(selectedDualMeet.selectedTeams)
                
            }else{
                vc.selectedTeams.append(defSwimClub)
            }
            //vc.usePreset = usePresetEvents
            if let sc = lastSelectedTeam {
                //print("\(sc.clubName)")
                vc.lastTeamFilter = sc
            }else{
                if isDualMeet {
                    vc.lastTeamFilter = selectedDualMeet.selectedTeams[0]
                }else{
                    vc.lastTeamFilter = defSwimClub
                }
                
            }
            if let agp = lastSelectedAgeGroup {
                //print(agp.presetAgeGroupName)
                vc.lastAgeGroupFilter = agp
            }
            vc.delegate = self
        }else {
            if segue.identifier == eventToResultsseg {
                let vc = segue.destination as! ResultsViewController
                vc.selectedDualMeet = selectedDualMeet
                vc.currentEvent = currentEvent
            }
        }
    }
    
    //MARK: - Data stuff
    func canChangeDetails() -> Bool {
        return currentEvent.eventID == 0 && currentEvent.eventResults.count == 0
            
        
    }
    
    
    func saveEvent() -> Bool {
        var ok = false
            if validateEvent() {
                
                do {
                    try realm.write {
                        currentEvent.eventLocation = txtLocation.text!
                        if isDualMeet {
                            currentEvent.hasPresetEvent=true
                            currentEvent.eventDistance = currentEvent.presetEvent!.distance
                            
                        }else{
                            currentEvent.eventDistance = Int(txtDistance.text!)!
                            currentEvent.useRaceNos = useRaceNos
                        }
                        
                        currentEvent.eventDate = myFunc.dateFromString(stringdate: self.lblEventDate.text!)
                        if currentEvent.eventID == 0 {
                            
                            currentEvent.eventID = myDefs.getNextEventId()
                            realm.add(currentEvent)
                            if self.isDualMeet {
                                selectedDualMeet.selectedEvents.append(currentEvent)
                            }
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
        
        if !isDualMeet {
            if let sDistance = txtDistance.text {
                if sDistance.isEmpty {
                    sErrmsg = "Please enter a distance"
                }
            }else{
                sErrmsg = "Please enter a distance"
            }
        }else{
            if let _ = currentEvent.presetEvent {
                
            }else{
                sErrmsg = "Please enter a preset distance race"
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
        if isRelay {
            startRelay()
        }
        loadEventResults()
        //myTableView.reloadData()
    }
    
}
    
    func updateNavTitle() {
        //if in race mode where everything moves up the chnage the nav title to be the currect race
        if timerOn {
            navigationItem.title = currentEvent.getRaceName()
        }else{
            navigationItem.title = "Race"
        }
    }
    
    func useAgeGroupSectionsinTableView() -> Bool {
        return (!timerOn) && eventHasAgeGroups
    }
    
    func useRelaySectionsInTableView() -> Bool {
        return (!timerOn) && isRelay
    }
    
    func moveStartViewUp() {
        
        updateNavTitle()
        
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
        updateNavTitle()
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
       
        pickerPresetEvent = UIPickerView()
        
        configurePickerView(pckview: pickerPresetEvent)
        
        
        
        view.addSubview(pickerPresetEvent)
        
        loadPickViewPresetEvents()
        removePickerViews()
        
    }
    
    func removePickerViews() {
        
        pickerPresetEvent.isHidden = true
    }
    
    func configurePickerView(pckview:UIPickerView) {
        
        pckview.frame = pickerViewFrame
        pckview.backgroundColor = UIColor(hexString: "89D8FC")
        pckview.layer.cornerRadius = 10.0
        pckview.delegate = self
        pckview.dataSource = self
    }
    
    
    
    func loadPickViewPresetEvents() {
        pickerPresetEventItems = realm.objects(PresetEvent.self).sorted(byKeyPath: "presetEventID")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
            return pickerPresetEventItems!.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
            return pickerPresetEventItems![row].getPresetName()
       
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        var bOK = true
        
            
            let thispse = pickerPresetEventItems![row]
            if let pse = currentEvent.presetEvent {
                if currentEvent.eventResults.count != 0 && pse.presetEventID != thispse.presetEventID {
                   bOK = false
                    showError(errmsg: "Once members are selected you cant change the race rules")
                }
                
                
            }
            
            if bOK {
                lblIPMeet.text = pickerPresetEventItems![row].getPresetName()
                
                currentEvent.presetEvent = thispse
                eventHasAgeGroups = thispse.eventAgeGroups.count != 0
                isRelay = thispse.isRelay
                
            }
           
        
        pickerView.isHidden = true
        //Im gonna remove the member from the list
        
    }

    
}
