//
//  ResultsViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 7/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift

class ResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let realm = try! Realm()
    //var isGrouped = false preset events wiht age groups are grouped by age group and gender. Exhibition event are grouped by gender.
    
    var usePreset = false
    var currentEvent = Event() //I wil always pass current event as last active event even if dual meet
    var selectedDualMeet = DualMeet()
    var selectedTeams : [SwimClub] = []
    let myfunc = appFunctions()
    let mydef = appUserDefaults()
    
    let grpfemale = " - Female"
    let grpmale = " - Male"
    var pickerEvent = UIPickerView()
    var pickerEventItems : [Event] = []
    
    var isDualMeet = false
    
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var lblPoints: UILabel!
    
    @IBOutlet weak var lblRacePoints: UILabel!
    
    @IBOutlet weak var lblEvent: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
  
    @IBOutlet weak var viewDual: UIView!
    
    var resultList : [EventResult] = [] //use if not in group Mode
    var groupDict : [String : [EventResult]] = [:]
    //var sectionGroups : [String] = []
    //one array for all members not in the event and their age at event time
    var sectionGroups = [(id: 0, groupTitle: "", grpGender: "")]
    
    var sectionGroupRelay = [(clubid: 0,relayNo: 0,relayLetter: "",clubname:"",groupTitle: "",totalTimeinseconds: 0,points: 0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       navigationItem.setHidesBackButton(true, animated: false)
       
        
        myTableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        
        if let pse = currentEvent.presetEvent {
            usePreset = pse.eventAgeGroups.count != 0
        }
        //tbTime.tintColor = UIColor.orange
        
        if selectedDualMeet.dualMeetID != 0 {
            isDualMeet = true
            selectedTeams = Array(selectedDualMeet.selectedTeams)
        }
        
        
        getData()
        
        showEventDetails()
        // Do any additional setup after loading the view.
    }
    
    func isRelay() -> Bool {
        var imarelay = false
        if let pse = currentEvent.presetEvent {
            imarelay = pse.isRelay
        }
        
        return imarelay
    }
    
    
    func showEventDetails() {
        var hdrText = ""
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = myfunc.getGlobalDateFormat()
//        if currentEvent.selectedTeams.count > 1 {
//            hdrText = "Dual Meet "
//        }
        hdrText += ("\(currentEvent.eventLocation)  \(currentEvent.eventDistance) meters ") + dateFormatter.string(from: currentEvent.eventDate)
        lblDistance.text = hdrText
        
        if isDualMeet && selectedTeams.count > 1 {
            //tally all the points
            var team1pts = 0
            var team2pts = 0
            let club1 = selectedTeams[0].clubName
            let club2 = selectedTeams[1].clubName
            for er in currentEvent.eventResults {
                if let mem = er.myMember.first {
                    if let sc = mem.myClub.first {
                        if sc.clubName == club1 {
                            team1pts += er.pointsEarned
                        }else{
                            team2pts += er.pointsEarned
                        }
                    }
                }
                
            }
            
            if isRelay() {
                for sr in sectionGroupRelay {
                    if sr.clubname == club1 {
                        team1pts += sr.points
                    }else{
                        team2pts += sr.points
                    }
                }
            }
            
            lblRacePoints.text = String(format:"%@ %d points - %@ %d points",club1,team1pts,club2,team2pts)
            
        }else{
            lblPoints.isHidden = true
        }
        
        if !isDualMeet {
            let newFrame = CGRect(x: myTableView.frame.origin.x, y: viewDual.frame.origin.y, width: myTableView.frame.size.width, height: myTableView.frame.size.height + viewDual.frame.size.height)
            myTableView.frame = newFrame
            viewDual.isHidden = true
            
        }
    }
    
    
    
    @IBAction func goHome(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

    
    
    
    //MARK: - TableView data
    
    func getData() {
        
        buildGroups()
        buildLists()
        sortListData()
        
    }
    
    func buildLists() {
        var erForGroup : [EventResult] = []
        resultList = Array(currentEvent.eventResults)
        
        if isRelay() {
            for grp in sectionGroupRelay {
                let myarr = resultList.filter({$0.getClubID() == grp.clubid && $0.relayNo == grp.relayNo})
                if myarr.count != 0 {
                    groupDict[grp.groupTitle] = myarr.sorted(by: {$0.relayOrder < $1.relayOrder})
                }
                
            }
        }else{
            for grp in sectionGroups {
                
                
                    for er in resultList {
                        
                       
                            if let mem = er.myMember.first {
                                if usePreset {
                                    if let agp = er.selectedAgeCategory.first {
                                        if grp.grpGender == mem.gender && grp.id == agp.presetAgeGroupID {
                                            
                                                    erForGroup.append(er)
                                        }
                                        
                                    }
                                    
                                }else{
                                    if mem.gender == grp.groupTitle {
                                        erForGroup.append(er)
                                    }
                                }
                            }
                       
                    }
                
                groupDict[grp.groupTitle] = erForGroup
                
                }
        }
    }
    
    func buildGroups() {
        //everything is gouped . For event where a preset with age groups wasnt used its grouped by gender.
        //for preset events where age groups are used its grouped by the age groups and genders
        //for relays group by Club - Team and relayorder and order the groups by the points
        
        
        sectionGroups.removeAll()
        sectionGroupRelay.removeAll()
        var evResults = Array(currentEvent.eventResults) //arrays are easier to work with
        
        if isRelay() {
            evResults = evResults.sorted(by: {$0.relayNo < $1.relayNo && $0.getClubID() < $1.getClubID()})
        }
            for er in evResults {
                if let mem = er.myMember.first {
                    if usePreset {
                        
                        if isRelay() {
                            //var sectionGroupRelay = [(clubid: 0,relayNo:0, relayLetter: "",groupTitle: "",totalTimeinseconds: 0,points: 0)]
                            if let thisclub = mem.myClub.first {
                                if sectionGroupRelay.index(where: {$0.clubid == thisclub.clubID && $0.relayNo == er.relayNo}) == nil {
                                    
                                    let mr = evResults.filter({$0.getClubID() == thisclub.clubID && $0.relayNo == er.relayNo})
                                    
                                    let totseconds = mr.reduce(0) { $0 + $1.resultSeconds }
                                    
                                    
                                    sectionGroupRelay.append((clubid: thisclub.clubID
                                        , relayNo: er.relayNo, relayLetter: er.getRelayLetter(),clubname:thisclub.clubName, groupTitle: "", totalTimeinseconds: totseconds, points: 0))
                                }
                            }
                        }else{
                            if let agp = er.selectedAgeCategory.first {
                                //prset dual meets where ther are age froups group by gender and age group
                                let gpfname = agp.presetAgeGroupName + grpfemale
                                let gpmname = agp.presetAgeGroupName + grpmale
                                
                                 if mem.gender == "Female" {
                                    if sectionGroups.index(where: { $0.groupTitle == gpfname }) == nil {
                                        sectionGroups.append((id: agp.presetAgeGroupID, groupTitle: gpfname, grpGender: mem.gender))
                                    }
                                 }else{
                                    if sectionGroups.index(where: { $0.groupTitle == gpmname }) == nil {
                                        sectionGroups.append((id: agp.presetAgeGroupID, groupTitle: gpmname, grpGender: mem.gender))
                                    }
                                }
                            }
                        }
                    
                    }else{
                        //exhibition events grouped by gender
                            if sectionGroups.index(where: { $0.groupTitle == mem.gender }) == nil {
                                sectionGroups.append((id: mem.gender == "Male" ? 0 : 1 , groupTitle: mem.gender,grpGender: mem.gender))
                            }
                       
                    }
                }
            
            }
        
        if isRelay() {
           calcRelayPoints()
        }
        //yes sections sort by group id not name
        //print(sectionGroups.count)
    }
    
    func calcRelayPoints() {
        sectionGroupRelay = sectionGroupRelay.sorted(by: {$0.relayNo < $1.relayNo && $0.clubid < $1.clubid && $0.totalTimeinseconds < $1.totalTimeinseconds})
        var Apoints = 25
        var Bpoints = 20
        var Cpoints = 15
        var Dpoints = 10
        var idx = 0
        var pointsassigned = 0
        for sr in sectionGroupRelay {
            pointsassigned = 0
            switch sr.relayNo {
            case 1 :
                pointsassigned = Apoints
                Apoints -= 5
                break
            case 2 :
                pointsassigned = Bpoints
                Bpoints -= 5
                break
            case 3 :
                pointsassigned = Cpoints
                Cpoints -= 5
                break
            case 4 :
                pointsassigned = Dpoints
                Dpoints -= 5
                break
            default :
                break
            }
            updateGroupRelayTitle(index: idx, points: pointsassigned)
            idx += 1
        }
    }
    
    func updateGroupRelayTitle(index:Int,points:Int) {
        let sr = sectionGroupRelay[index]
        sectionGroupRelay[index].points = points
        sectionGroupRelay[index].groupTitle = String(format:"%@ - Team %@ %@ (%d points)",sr.clubname,sr.relayLetter,myfunc.convertSecondsToTime(timeinseconds: sr.totalTimeinseconds) ,points)
        
    }
    
    
    func sortListData() {
        var sortedArray : [EventResult]
        
        if !isRelay() {
            for grp in sectionGroups {
                
                
                sortedArray = (groupDict[grp.groupTitle]?.sorted(by: { $0.resultSeconds < $1.resultSeconds}))!
               
                groupDict.updateValue(sortedArray, forKey: grp.groupTitle)
                
            }
        }
        
        
        //resultList = resultList.sorted(by: { $0.resultSeconds < $1.resultSeconds})
        myTableView.reloadData()
    }
    
    //MARK: - Tableview stuff

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionGroups.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let offset : CGFloat = 5.0
//        if isGrouped {
//            print("\(section)")
//        }
        //var headerView = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.frame.size.width - (offset * 2), height: 100))
        
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: myTableView.frame.size.width - (offset * 2.0), height: 100.0))
        
        
            headerView.backgroundColor = UIColor.black
            let label = UILabel(frame: CGRect(x: 0, y: -5, width: myTableView.frame.size.width, height: 30.0))
            label.clipsToBounds = true
            label.layer.cornerRadius = 5.0
            label.backgroundColor = UIColor.black
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont(name: "Helvetica", size: 25.0)
            label.text = sectionGroups[section].groupTitle
            //print(sectionGroups[section].groupName)
            headerView.addSubview(label)
            
        
        
        return headerView
}
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var noRows : Int = 1
        
        if let myArray = groupDict[sectionGroups[section].groupTitle] {
                noRows = myArray.count
        }
            
        
        
        return noRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        
        configureCell(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
//
     func configureCell(cell:ResultCell, atIndexPath indexPath:IndexPath) {
        var er = EventResult()
        var hdrText = ""
        
            if let myArray = groupDict[sectionGroups[indexPath.section].groupTitle] {
                er = myArray[indexPath.row]
            }
            
        
        
        if let mem = er.myMember.first {
            //print(mem.memberName)
            if let ev = er.myEvent.first {
                if ev.useRaceNos {
                    hdrText = String(format:"%d - ",er.raceNo)
                }
            }
            hdrText += mem.memberName
            if usePreset {
                hdrText += String(format: "  (%@)", (mem.myClub.first?.clubName)!)
            }
        }
        
        var pointsearned = 0
        switch indexPath.row {
        case  0:
            cell.imgMedal.image = UIImage(named: "gold7575")
            pointsearned = 4
            break
        case  1:
            cell.imgMedal.image = UIImage(named: "silver7575")
            pointsearned = 3
            break
        case  2:
            cell.imgMedal.image = UIImage(named: "bronze7575")
            pointsearned = 2
            break
        case 3:
            cell.imgMedal.image = nil
            pointsearned = 1
            break
        default:
            cell.imgMedal.image = nil
            break
        }
        
        
        
        if usePreset {
            
            cell.lblImprovement.text = String(format: "%d Points", pointsearned)
            cell.lblImprovement.backgroundColor = pointsearned > 0 ? UIColor.green : UIColor.flatPink
        }else{
            cell.lblImprovement.text = "Diff: " + myfunc.convertSecondsToTime(timeinseconds: er.diffSeconds)
            cell.lblImprovement.backgroundColor = er.diffSeconds < 0 ? UIColor.green : UIColor.red
        }
        
        cell.lblHeader.text = hdrText
        cell.lblEstimate.text = "Est: " + myfunc.convertSecondsToTime(timeinseconds: er.expectedSeconds)
        
        cell.lblResult.text = "Time: " + myfunc.convertSecondsToTime(timeinseconds: er.resultSeconds)
        
        
        
        
        /*Setthe medals and award points*/
       
        if pointsearned != 0 && usePreset {
            do {
                try realm.write {
                    er.pointsEarned = pointsearned
                }
            }catch{
                
            }
        }
    
        
     }
    
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
}
extension ResultsViewController : UIPickerViewDelegate,UIPickerViewDataSource {
    //Ive got two pickerviewws. One with Preset meet info and one with club info thats used in 2 places
    func loadPickerViews() {
        
        pickerEvent = myfunc.makePickerView()
        
        pickerEvent.delegate = self
        pickerEvent.dataSource = self
        
        view.addSubview(pickerEvent)
        
        loadPickViewPresetEvents()
        removePickerViews()
        
    }
    
    func removePickerViews() {
        
        pickerEvent.isHidden = true
    }
    
    
    
    
    
    func loadPickViewPresetEvents() {
        for event in selectedDualMeet.selectedEvents {
            if event.isFinished {
                pickerEventItems.append(event)
            }
        }
        //pickerEventItems = realm.objects(PresetEvent.self).sorted(byKeyPath: "presetEventID")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerEventItems.count
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        return pickerEventItems[row].presetEvent!.getPresetName()
        
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        currentEvent = pickerEventItems[row]
        
        getData()
        myTableView.reloadData()
        
        pickerView.isHidden = true
        //Im gonna remove the member from the list
        
    }
    
    
}
