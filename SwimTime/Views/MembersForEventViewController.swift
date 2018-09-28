//
//  MembersForEventViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift


protocol StoreFiltersDelegate {
    func updateDefaultFilters(team : SwimClub,ageGroup: PresetEventAgeGroups?)
}

class MembersForEventViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let realm = try! Realm()
    var membersList : Results<Member>?
    var myfunc = appFunctions()
    var mydefs = appUserDefaults()
    var isRelay = false
    var pickerTeams : UIPickerView!
    var pickerAgeGroups : UIPickerView!
    
    var pickerTeamItems = [SwimClub]()
    var pickerAgeGroupItems = [PresetEventAgeGroups]()
    
    var lastAgeGroupFilter : PresetEventAgeGroups?//this has a dua purpose for preset events wiht preset age groups. This will be thw age group the ember is in for validation purposes
    var lastTeamFilter : SwimClub?
    
    var selectedEvent = Event()
    var selectedTeams : [SwimClub] = []
    
    
    var currentRelayNo = 1 //this is the relay numer for this club. ser cant chnage clubs while selecting relay people
    
    var usePreset : Bool = false
    
    
    var origtableframe  : CGRect = CGRect(x: 1.0, y: 1.0, width: 1.0, height: 1.0)
    var origFilterFrame : CGRect = CGRect(x: 1.0, y: 1.0, width: 1.0, height: 1.0)
    var pickerViewFrame = CGRect(x: 1.0, y: 1.0 , width: 1.0, height: 1.0)
    
    let quickEntrySeg = "quickEntry"
  
    var origFilterViewHeight : CGFloat = 1.0
    
    var delegate : StoreFiltersDelegate?

    var backFromQuickEntry = false
    
    //one array for all members not in the event and their age at event time
    var memAges = [(memberid: 0, ageAtEvent: 0)]
    
    var filterShowing : Bool = false
    //one arrya for all existing event result members used to validate the numbers
    var memForEvent = [PresetEventMember]()
    
    
    @IBOutlet weak var lblTeam: UILabel!
    
    @IBOutlet weak var lblAgeGroup: UILabel!
    @IBOutlet weak var filterView: UIView!
    
    @IBOutlet weak var btnTeam: UIButton!
    
    @IBOutlet weak var btnAgeGroup: UIButton!
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pse = selectedEvent.presetEvent {
            isRelay = pse.isRelay
            usePreset = true
        }
        
        
        navigationItem.setHidesBackButton(true, animated: false)
        //adjuts the height
        origtableframe = myTableView.frame
        
        origFilterViewHeight = filterView.frame.size.height
        
        
        origFilterFrame = CGRect(x: filterView.frame.origin.x, y: (view.frame.size.height - filterView.frame.size.height)/2, width: filterView.frame.size.width, height: filterView.frame.size.height)
        
        filterView.isHidden = true
        
        pickerViewFrame = CGRect(x: 120.0, y: (view.frame.size.height/2) + origFilterFrame.size.height , width: 600.00, height: 143.0)
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        lblTeam.text = lastTeamFilter?.clubName
        
        loadPickerViews()
        
        hideShowFilter(self)
        
        loadPresetEventMembers()
        
        currentRelayNo = getNextRelayNo(clubid: getClubID()) //last team filter is always set
        
        if loadMembers() {
            myTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if backFromQuickEntry {
            if loadMembers() {
                
            }
            myTableView.reloadData()
            backFromQuickEntry = false
        }
    }
   
    
    
    //MARK: - IBActions
    
    
    @IBAction func filterClicked(_ sender: UIButton) {
        if sender.tag == 0 {
            if let sName = lastTeamFilter?.clubName {
                if let idx = pickerTeamItems.index(where: {$0.clubName == sName}) {
                        pickerTeams.selectRow(idx, inComponent: 0, animated: true)
                    
                }
            }
                
            pickerTeams.isHidden = false
            
        }else{
            if let sName = lastAgeGroupFilter?.presetAgeGroupName {
                if let idx = pickerAgeGroupItems.index(where: {$0.presetAgeGroupName == sName}) {
                    //print("name=\(sName) index=\(idx)")
                    pickerAgeGroups.selectRow(idx, inComponent: 0, animated: true)
                }
            }
             pickerAgeGroups.isHidden = false
        }
    }
    

    
    
    @IBAction func hideShowFilter(_ sender: Any) {
        filterShowing = !filterShowing

        
        let hidingFilterFrame = CGRect(x: 200.0, y: origFilterFrame.origin.y, width: origFilterFrame.size.width, height: origFilterFrame.size.height)
        UIView.animate(withDuration: 1, animations: {
            if self.filterShowing {
                self.filterView.frame = hidingFilterFrame
                self.filterView.frame = self.origFilterFrame
                self.view.bringSubviewToFront(self.filterView)
                self.filterView.isHidden = false
            }else{
                self.filterView.frame = self.origFilterFrame
                self.filterView.frame = hidingFilterFrame
                self.filterView.isHidden = true
            }
        })
   

    }
    
    @IBAction func quickEntry(_ sender: UIBarButtonItem) {
                backFromQuickEntry = true
                performSegue(withIdentifier: quickEntrySeg, sender: self)
    }
    
    
    
    
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        
        if let _ = membersList?.count {
            if membersList?.count != 0 {
            
                do {
                    try realm.write {
                        for mem in membersList! {
                            if mem.selectedForEvent {
                                mem.selectedForEvent = false
                                let er = EventResult()
                                er.eventResultId = mydefs.getNextEventResultId()
                                if selectedEvent.useRaceNos {
                                    er.raceNo = mydefs.getNextRaceNo()
                                    
                                }
                                er.ageAtEvent = myfunc.getAgeFromDate(fromDate: mem.dateOfBirth, toDate: selectedEvent.eventDate)//mem.age()
                                
                                er.expectedSeconds = myfunc.adjustOnekSecondsForDistance(distance: selectedEvent.eventDistance , timeinSeconds: mem.onekSeconds)
                                
                                
                                let pse = self.memForEvent.filter({$0.memberid == mem.memberID}).first
                                
                                if let psage = pse?.PresetAgeGroup {
                                    if er.selectedAgeCategory.count == 0 {
                                        er.selectedAgeCategory.append(psage)
                                    }else{
                                        er.selectedAgeCategory[0] = psage
                                    }
                                    
                                    er.staggerStartBy = psage.staggerSeconds
                                    er.expectedSeconds += psage.staggerSeconds
                                }
                               
                                
                                realm.add(er)
                                mem.eventResults.append(er)
                                selectedEvent.eventResults.append(er)
                            }
                        }
                        
                    }
                }catch{
                    showError(errmsg: "Cant save members")
                }
            }
        }
        if let agp = lastAgeGroupFilter {
            delegate?.updateDefaultFilters(team: lastTeamFilter!, ageGroup: agp)
        }else{
            delegate?.updateDefaultFilters(team: lastTeamFilter!, ageGroup: nil)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - my Data stuff
    func loadPresetEventMembers() {
        
        //wil use this list to validate how many ppl as agegroups are allowed in each time
        //a member is selected
        if usePreset {
            
                for er in selectedEvent.eventResults {
                    let mem = er.myMember.first!
                    if let agrp = er.selectedAgeCategory.first {
                        addMemberToPreset(mem: mem,agegrp: agrp,relayno: er.relayNo, relayorder: er.relayOrder)
                    }else{
                        addMemberToPreset(mem: mem,agegrp: nil,relayno: er.relayNo, relayorder: er.relayOrder)
                    }
                    
                }
            
            
        }
        
    }
    
    func addMemberToPreset(mem:Member,agegrp:PresetEventAgeGroups?,relayno:Int=0,relayorder:Int=0) {
        let pse = PresetEventMember()
        pse.memberid = mem.memberID
        pse.ageAtEvent = myfunc.getAgeFromDate(fromDate: mem.dateOfBirth, toDate: selectedEvent.eventDate)
        pse.gender = mem.gender
        pse.clubID = (mem.myClub.first?.clubID)!
        //print("\(pse.clubID)")
        pse.relayNo = relayno
        pse.relayOrder = relayorder
        if let ag =  agegrp  {
            //print("agegrpid=\(ag.presetAgeGroupID) name=\(ag.presetAgeGroupName)")
            pse.PresetAgeGroup = ag
            
        }

        memForEvent.append(pse)
    }
    
    
    func getNextRelayNo(clubid:Int) -> Int {
        //we need to go through the selected list and find either a relayno thats not used or a relayNo that is used but has less than 4 members
        var iNextRelayNo = 1
        
            for er in memForEvent {
                if er.clubID == clubid && er.relayNo == iNextRelayNo {
                    // see if there are 4 people
                    let myarr = memForEvent.filter({$0.clubID == clubid && $0.relayNo == iNextRelayNo})
                    if myarr.count == 4 {
                        iNextRelayNo += 1 //found 4 members so add 1
                    }else{
                        break
                    }
                    
                }
                
            }
        
        
        return iNextRelayNo
        
    }
    
    func getRelayOrderForMember(thismemberid:Int) -> Int {
        
        if memForEvent.count != 0 {
            if let pse = memForEvent.filter({$0.memberid == thismemberid}).first {
                return pse.relayOrder
            }else{
                return 0
            }
            
        }else{
            return 0
        }
    }
    func getNextRelayOrder(clubid:Int) -> Int {
        var iNextRelayOrder = 1
        
            for er in memForEvent {
                if er.clubID == clubid && er.relayNo == currentRelayNo {
                    // see if there are 4 people
                    let myarr = memForEvent.filter({$0.clubID == clubid && $0.relayNo == currentRelayNo})
                    if myarr.count < 4 { //checkmemis valid will check there is not 4 for currentRelayno
                        iNextRelayOrder += 1 //found 4 members so add 1
                    }else{
                        break
                    }
                    
                }
                
            }
        
        return iNextRelayOrder
    }
    
    func checkMemIsvalid(mem:Member) -> Bool {
        var errMsg = ""
        if usePreset {
            if let pse = selectedEvent.presetEvent {
                if memForEvent.count != 0 {
                    if pse.maxPerEvent != 0 {
                        if pse.maxPerEvent == memForEvent.count {
                            errMsg = "Maximum number for the Race exceeded. Max entrants is \(pse.maxPerEvent)"
                        }
                    }
                    if pse.maxPerClub != 0 {
                        if let myclub = mem.myClub.first {
                            
                            let clubs  = memForEvent.filter({$0.clubID == myclub.clubID})
                            if clubs.count == pse.maxPerClub {
                                errMsg = "Maximum number exceeded. Max entrants for each club is \(pse.maxPerClub)"
                            }
                        }
                        
                    }
                    
                    if pse.maxPerGenderAndAgeGroup != 0 && pse.eventAgeGroups.count != 0 {
                        if let myclub = mem.myClub.first {
                            //print("\(mem.gender) agegrpid=\(lastAgeGroupFilter!.presetAgeGroupID) clubid=\(myclub.clubID)")
                            let matchingmems  = memForEvent.filter({$0.clubID == myclub.clubID && $0.gender == mem.gender && $0.PresetAgeGroup.presetAgeGroupID == lastAgeGroupFilter!.presetAgeGroupID})
                                if matchingmems.count == pse.maxPerGenderAndAgeGroup {
                                    errMsg = "Maximum number per club, gender and age group exceeded. Max entrants for \(mem.gender) for \(lastAgeGroupFilter!.presetAgeGroupName) each club is \(pse.maxPerGenderAndAgeGroup)"
                                }
                            
                            
                           
                        }
                    }else{
                        if isRelay && errMsg.isEmpty {
                            //have checked member numbers and the like. cant add this guy form currentRelayNo if 4 already in
                            let marr = memForEvent.filter({$0.clubID == getClubID() && $0.relayNo == currentRelayNo})
                            if marr.count == pse.maxPerRelay {
                                errMsg = "Max for this relay and Team is \(pse.maxPerRelay)"
                            }
                        }
                    }
                
                }
            }
            
        }
        
        if !errMsg.isEmpty {
            showError(errmsg: errMsg)
        }else{
            
                if selectedEvent.presetEvent?.eventAgeGroups.count != 0 {
                    addMemberToPreset(mem: mem, agegrp: lastAgeGroupFilter)
                }else{
                    if isRelay {
                        addMemberToPreset(mem: mem, agegrp: nil,relayno: currentRelayNo,relayorder: getNextRelayOrder(clubid: getClubID()))
                    }else{
                       addMemberToPreset(mem: mem, agegrp: nil)
                    }
                    
                }
            
        }
        return errMsg.isEmpty
    }
    
    func getClubID() -> Int {
        if let thisclub = lastTeamFilter?.clubID {
            return thisclub
        }else{
            return 0
        }
    }
    func loadMembers() -> Bool{
        //Im trying to list Members that are NOT in this event
        
        
        var found : Bool = false
        
        //print(lastTeamFilter!.clubName)
        var membersNotInEvent : Results<Member> = realm.objects(Member.self).filter("ANY myClub.clubName = %@",lastTeamFilter!.clubName).sorted(byKeyPath: "memberName") //start wiht them all then filter if applicable
        
        //update the age list from the everyone list everyone
        
        memAges.removeAll()
        //print("count=\(membersNotInEvent.count)")
        for mem in membersNotInEvent {
            memAges.append((memberid: mem.memberID , ageAtEvent: myfunc.getAgeFromDate(fromDate: mem.dateOfBirth, toDate: selectedEvent.eventDate)))
        }
        
        //memForEvent is a list of the selctions and anyine already in the event so i can validate them
        //some preset event have rule for how many ppl per gender can be in it
        
        
        var memIdInEvent = [Int]()
        
         let resultsInEvent = selectedEvent.eventResults
        
        for rs in resultsInEvent {
            if let memberInEvent = rs.myMember.first {
                memIdInEvent.append(memberInEvent.memberID)
            }
            
        }
        //print("not in event count=\(membersNotInEvent.count)")
        if memIdInEvent.count != 0 {
            membersNotInEvent = membersNotInEvent.filter("NOT (memberID IN %@)",memIdInEvent)
        }
        //print("not in event count=\(membersNotInEvent.count)")
        var memidsForAge = [Int]()
        
        if let agp = lastAgeGroupFilter {
            
            
                    for ma in memAges {
                        if ma.ageAtEvent >= agp.minAge && agp.useOverMinForSelect {
                            memidsForAge.append(ma.memberid)
                        }else{
                            if ma.ageAtEvent <= agp.maxAge && !agp.useOverMinForSelect {
                                 memidsForAge.append(ma.memberid)
                            }
                        }
                    }
            
            //print("age is ok count=\(memidsForAge.count)")
            if memidsForAge.count != 0 {
                membersNotInEvent = membersNotInEvent.filter("memberID IN %@",memidsForAge)
            }
           //print("not in event count=\(membersNotInEvent.count)")
            
        }
        
       
        if (membersNotInEvent.count == 0) {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: myTableView.bounds.size.width, height: myTableView.bounds.size.height))
            
            noDataLabel.text             = "No Members to List"
            noDataLabel.textColor        = UIColor.black
            noDataLabel.backgroundColor = UIColor.gray
            
            noDataLabel.textAlignment    = .center
            noDataLabel.font = UIFont(name:"Verdana",size:40)
            
            myTableView.backgroundView = noDataLabel;
            membersList = membersNotInEvent
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }else{
            myTableView.backgroundView=nil
            
            //get all members not in event and create the age at event array to help the filter get people of the right ages
            //memAges.removeAll()
            
            membersList = membersNotInEvent
            found = true
        }
        return found
    }
    
    
    // MARK: - Table view data source
    
   func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return membersList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return membersList?.count == 0 ? 0 : 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventMemberCell", for: indexPath)
        
        configureCell(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:IndexPath) {
        
        
        let lh = membersList![indexPath.row + indexPath.section]
    
        cell.textLabel?.font = UIFont(name:"Helvetica", size:40.0)
        
        cell.textLabel?.text = lh.memberName
        
        cell.detailTextLabel?.font = UIFont(name:"Helvetica", size:20.0);
        
        cell.detailTextLabel?.textColor = UIColor.red
        
        
        var dtText = String(format:"(%@)   Age: %d",lh.gender,myfunc.getAgeFromDate(fromDate:lh.dateOfBirth, toDate: selectedEvent.eventDate))
        
        
        if let grp = lh.myClub.first {
            dtText = dtText + String(format:"   Team: %@",grp.clubName)
        }
        
        dtText = dtText + String(format:"   One K: %@",myfunc.convertSecondsToTime(timeinseconds: lh.onekSeconds))
        
        cell.detailTextLabel?.text = dtText
        cell.layer.cornerRadius = 8
        
        let imgFilePath = myfunc.getFullPhotoPath(memberid: lh.memberID)
        let imgMemberPhoto = UIImageView(image: UIImage(contentsOfFile: imgFilePath))
        
        
        cell.backgroundColor = UIColor(hexString: "89D8FC") //hard setting ths doesnt seem to work as well
        
        cell.accessoryView?.tintColor = UIColor.clear
        cell.accessoryView?.isHidden = false
        
        if lh.selectedForEvent {
            var theimg = "ticknew"
            if isRelay {
                let thismemrelayorder = getRelayOrderForMember(thismemberid: lh.memberID)
                switch thismemrelayorder {
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
            }
            let imageView = UIImageView(image: UIImage(named: theimg))
            
            imageView.sizeToFit()
            cell.accessoryView = imageView
            
        }else {
            if imgMemberPhoto.image != nil {
                
                let frame = CGRect(x: 0.0, y: 0.0, width: 100.00, height: 100.00)
                
                imgMemberPhoto.frame = frame
                imgMemberPhoto.layer.masksToBounds = true
                imgMemberPhoto.layer.cornerRadius = 20.0
                cell.accessoryView = imgMemberPhoto
                
                
            }else{
                cell.accessoryView?.isHidden = true
            }
            
        }
        
        
        
        
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
        let mem = membersList![indexPath.row + indexPath.section]
        
        var bok = false
        
        if mem.selectedForEvent  {
            //remove if was selected
            bok = true
            if let mxm = memForEvent.index(where: {$0.memberid == mem.memberID}) {
                memForEvent.remove(at: mxm)
            }
            
            
        }else{
            if checkMemIsvalid(mem: mem) {
                bok = true
            }
        }
        
        if bok {
            do {
                try realm.write {
                    mem.selectedForEvent = !mem.selectedForEvent
                    
                    
                }
            }catch{
                showError(errmsg: "Couldnt update item")
            }
            tableView.reloadData()
        }
        
        
    }
    
  
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == quickEntrySeg {
            let vc = segue.destination as! MembersViewController
            if let thisclub = lastTeamFilter {
                vc.selectedClub = thisclub
            }
        }
    }
    
    //MARK: - Errors
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
        
    }
    
}
extension MembersForEventViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    func loadPickerViews() {
        pickerTeams = UIPickerView()
        pickerAgeGroups = UIPickerView()
        configurePickerView(pckview: pickerTeams)
        pickerTeams.tag = 1
        configurePickerView(pckview: pickerAgeGroups)
        pickerAgeGroups.tag = 2
        
        view.addSubview(pickerTeams)
        view.addSubview(pickerAgeGroups)
        
        loadPickerViewTeams()
        loadPickerViewAgeGroups()
        
        pickerTeams.isHidden = true
        pickerAgeGroups.isHidden = true
    }
    
    private func loadPickerViewTeams() {
        pickerTeamItems = selectedTeams
        if pickerTeamItems.count == 1 {
            btnTeam.isHidden = true
        }
    }
    
    func loadPickerViewAgeGroups() {
        if usePreset  {
            if selectedEvent.presetEvent?.eventAgeGroups.count != 0 {
                pickerAgeGroupItems = Array(selectedEvent.presetEvent!.eventAgeGroups)
                //set lastAgegroup filter
                var selagegrp = PresetEventAgeGroups()
                if let _ = lastAgeGroupFilter {
                    selagegrp = lastAgeGroupFilter!
                }else{
                    for ag in selectedEvent.presetEvent!.eventAgeGroups {
                        selagegrp = ag
                        if ag.useOverMinForSelect {
                            break
                        }
                    }
                }
                lastAgeGroupFilter = selagegrp
                lblAgeGroup.text = selagegrp.presetAgeGroupName
            }else{
                loadAllAgeGroups()
            }
            
        }else{
            loadAllAgeGroups()
        }
    }
    func loadAllAgeGroups() {
        pickerAgeGroupItems = Array(realm.objects(PresetEventAgeGroups.self).sorted(byKeyPath: "presetAgeGroupID"))
        //print("count=\(pickerAgeGroupItems.count)")
    }
    
    func configurePickerView(pckview:UIPickerView) {
        
        pckview.frame = pickerViewFrame
        pckview.backgroundColor = UIColor(hexString: "FFC991")
        pckview.clipsToBounds = true
        pckview.layer.cornerRadius = 10.0
        pckview.delegate = self
        pckview.dataSource = self
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return pickerTeamItems.count
        }else{
            //print("count=\(pickerAgeGroupItems.count)")
            return pickerAgeGroupItems.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            
            return pickerTeamItems[row].clubName
        }else{
            //print(pickerAgeGroupItems[row].presetAgeGroupName)
            return pickerAgeGroupItems[row].presetAgeGroupName
            
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        if pickerView.tag == 1 {
            lastTeamFilter = pickerTeamItems[row]
            lblTeam.text = lastTeamFilter?.clubName
        }else{
            
            lastAgeGroupFilter = pickerAgeGroupItems[row]
            lblAgeGroup.text = lastAgeGroupFilter?.presetAgeGroupName
        }
        
        if loadMembers() {
            
        
        }
        myTableView.reloadData()
        
        pickerView.isHidden = true
        
        
    }

    

}
