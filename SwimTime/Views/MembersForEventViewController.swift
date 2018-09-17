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

class MembersForEventViewController: UITableViewController {

    let realm = try! Realm()
    var membersList : Results<Member>?
    var myfunc = appFunctions()
    var mydefs = appUserDefaults()
    
    var pickerTeams : UIPickerView!
    var pickerAgeGroups : UIPickerView!
    
    var pickerTeamItems = [SwimClub]()
    
    var pickerAgeGroupItems = [PresetEventAgeGroups]()
    
    var lastAgeGroupFilter : PresetEventAgeGroups?
    var lastTeamFilter : SwimClub?
    
    var selectedEvent = Event()
    var filterShowing : Bool = false
    var usePreset : Bool = false
    var origtableframe  : CGRect = CGRect(x: 1.0, y: 1.0, width: 1.0, height: 1.0)
    var origFilterFrame : CGRect = CGRect(x: 1.0, y: 1.0, width: 1.0, height: 1.0)
    var pickerViewFrame = CGRect(x: 120.0, y: 100.0, width: 600.00, height: 143.0)
    let quickEntrySeg = "quickEntry"
  
    var origFilterViewHeight : CGFloat = 1.0
    
    var delegate : StoreFiltersDelegate?

    var backFromQuickEntry = false
    
    //one array for all members not in the event and their age at event time
    var memAges = [(memberid: 0, ageAtEvent: 0)]
    
    
    //one arrya for all existing event result members used to validate the numbers
    var memForEvent = [PresetEventMember]()
    
    
    @IBOutlet weak var lblAgeGroup: UILabel!
    @IBOutlet weak var lblTeam: UILabel!
    @IBOutlet weak var filterView: UIView!
    
    @IBOutlet weak var btnAgeGroup: UIButton!
    @IBOutlet weak var btnTeam: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        //adjuts the height
        origtableframe = tableView.frame
        
        origFilterViewHeight = filterView.frame.size.height
        //origFilterFrame = CGRect(x: filterView.frame.origin.x, y: (view.frame.size.height - filterView.frame.size.height)/2, width: filterView.frame.size.width, height: filterView.frame.size.height)
        
        filterView.isHidden = true
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        lblTeam.text = lastTeamFilter?.clubName
        
        loadPickerViews()
        
        hideShowFilter(self)
        
        
        loadPresetEventMembers()
        
        if loadMembers() {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if backFromQuickEntry {
            if loadMembers() {
                
            }
            tableView.reloadData()
            backFromQuickEntry = false
        }
    }
   
    
    
    //MARK: - IBActions
    
    
    @IBAction func filterClicked(_ sender: UIButton) {
        if sender.tag == 1 {
            pickerTeams.isHidden = false
            
        }else{
            pickerAgeGroups.isHidden = false
        }
    }
    
    
    @IBAction func hideShowFilter(_ sender: Any) {
        filterShowing = !filterShowing
//        if filterShowing {
//            print("Im gonna show it")
//        }else{
//            print("Im swithcin it off")
//        }
        
        //tried floatomg waste of time on a table view
//        let hidingFilterFrame = CGRect(x: 200.0, y: origFilterFrame.origin.y, width: origFilterFrame.size.width, height: origFilterFrame.size.height)
//        UIView.animate(withDuration: 1, animations: {
//            if self.filterShowing {
//                self.filterView.frame = hidingFilterFrame
//                self.filterView.frame = self.origFilterFrame
//                self.view.bringSubview(toFront: self.filterView)
//            }else{
//                self.filterView.frame = self.origFilterFrame
//                self.filterView.frame = hidingFilterFrame
//
//            }
//        })
       // filterView.isHidden = !filterShowing
        
        
        let newtbFrame = CGRect(x: origtableframe.origin.x, y: origtableframe.origin.y - origFilterViewHeight, width: origtableframe.width, height: origtableframe.size.height + origFilterViewHeight)
        UIView.animate(withDuration: 1
            , animations: {
                if self.filterShowing {
                    self.tableView.setContentOffset(.zero, animated: true)
                }
                self.filterView.frame.size.height = self.filterShowing ? self.origFilterViewHeight : 1.0
                if self.filterShowing {
                    self.tableView.frame = self.origtableframe
                }else{
                    self.tableView.frame = newtbFrame
                }
                self.filterView.isHidden = !self.filterShowing
        })

    }
    @IBAction func quickEntry(_ sender: UIBarButtonItem) {
        backFromQuickEntry = true
        performSegue(withIdentifier: quickEntrySeg, sender: self)
    }
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        //2 If we have a delegate set, call the method userEnteredANewCityName
        
        if let agp = lastAgeGroupFilter {
            delegate?.updateDefaultFilters(team: lastTeamFilter!, ageGroup: agp)
        }else{
             delegate?.updateDefaultFilters(team: lastTeamFilter!, ageGroup: nil)
        }
        

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
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - my Data stuff
    func loadPresetEventMembers() {
        
        //wil use this list to validate how many ppl as agegroups are allowed in each time
        //a member is selected
        if usePreset {
            
                for er in selectedEvent.eventResults {
 
                    let pse = PresetEventMember()
                    let mem = er.myMember.first!
                    pse.memberid = mem.memberID
                    pse.ageAtEvent = myfunc.getAgeFromDate(fromDate: mem.dateOfBirth, toDate: selectedEvent.eventDate)
                    pse.gender = mem.gender
                    pse.clubID = (mem.myClub.first?.clubID)!
                    pse.relayLetter = ""
                    if selectedEvent.presetEvent?.eventAgeGroups.count != 0 {
                        pse.PresetAgeGroup = er.selectedAgeCatgeory.first!
                    }
                    memForEvent.append(pse)
                }
            
        }
        
    }
    
    func loadMembers() -> Bool{
        //Im trying to list Members that are NOT in this event
        
        
        var found : Bool = false
        
        //print(lastTeamFilter!.clubName)
        var membersNotInEvent : Results<Member> = realm.objects(Member.self).filter("ANY myClub.clubName = %@",lastTeamFilter!.clubName).sorted(byKeyPath: "memberName") //start wiht them all then filter if applicable
        
        //update the age list from the everyone list everyone
        
        memAges.removeAll()
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
        
        if memIdInEvent.count != 0 {
            membersNotInEvent = membersNotInEvent.filter("NOT (memberID IN %@)",memIdInEvent)
        }
        
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
               
            if memidsForAge.count != 0 {
                membersNotInEvent = membersNotInEvent.filter("memberID IN %@",memidsForAge)
            }
           
            
        }
        
        
        if (membersNotInEvent.count == 0) {
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
            tableView.backgroundView=nil
            //get all members not in event and create the age at event array to help the filter get people of the right ages
            //memAges.removeAll()
            
            membersList = membersNotInEvent
            found = true
        }
        return found
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return membersList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        
        var dtText = String(format:"Age: %d",myfunc.getAgeFromDate(fromDate:lh.dateOfBirth, toDate: selectedEvent.eventDate))
        
        
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
            let imageView = UIImageView(image: UIImage(named: "ticknew"))
            
            
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mem = membersList![indexPath.row + indexPath.section]
        do {
            try realm.write {
                mem.selectedForEvent = !mem.selectedForEvent
                
            }
        }catch{
            showError(errmsg: "Couldnt update item")
        }
        tableView.reloadData()
    }
    
  
    
    // MARK: - Navigation
    
    
    
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
        pickerTeamItems = Array(selectedEvent.selectedTeams)
        if pickerTeamItems.count == 1 {
            btnTeam.isHidden = true
        }
    }
    
    func loadPickerViewAgeGroups() {
        if usePreset  {
            if !(selectedEvent.presetEvent?.isRelay)! {
                pickerAgeGroupItems = Array(selectedEvent.presetEvent!.eventAgeGroups)
            }else{
                loadAllAgeGroups()
            }
            
        }else{
            loadAllAgeGroups()
        }
    }
    func loadAllAgeGroups() {
        pickerAgeGroupItems = Array(realm.objects(PresetEventAgeGroups.self).sorted(byKeyPath: "presetAgeGroupID"))
    }
    
    func configurePickerView(pckview:UIPickerView) {
        
        pckview.frame = pickerViewFrame
        pckview.backgroundColor = UIColor(hexString: "89D8FC")
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
            return pickerAgeGroupItems.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 1 {
            
            return pickerTeamItems[row].clubName
        }else{
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
            tableView.reloadData()
        }
        pickerView.isHidden = true
        //Im gonna remove the member from the list
        
    }

    

}
