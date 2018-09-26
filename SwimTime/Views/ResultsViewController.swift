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
    var currentEvent = Event()
    let myfunc = appFunctions()
    let mydef = appUserDefaults()
    
    let grpfemale = " - Female"
    let grpmale = " - Male"
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var lblPoints: UILabel!
    
    @IBOutlet weak var myToolbar: UIToolbar!
    @IBOutlet weak var myTableView: UITableView!
  
    
    @IBOutlet weak var tbTime: UIBarButtonItem!
    
    @IBOutlet weak var tbGroup: UIBarButtonItem!
    
    
    var resultList : [EventResult] = [] //use if not in group Mode
    var groupDict : [String : [EventResult]] = [:]
    //var sectionGroups : [String] = []
    //one array for all members not in the event and their age at event time
    var sectionGroups = [(id: 0, groupTitle: "", grpGender: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       navigationItem.setHidesBackButton(true, animated: false)
       
        
        myTableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        
        if let pse = currentEvent.presetEvent {
            usePreset = pse.eventAgeGroups.count != 0
        }
        //tbTime.tintColor = UIColor.orange
        getData()
        
        showEventDetails()
        // Do any additional setup after loading the view.
    }
    
    func showEventDetails() {
        var hdrText = ""
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = myfunc.getGlobalDateFormat()
        if currentEvent.selectedTeams.count > 1 {
            hdrText = "Dual Meet "
        }
        hdrText += ("\(currentEvent.eventLocation)  \(currentEvent.eventDistance) meters ") + dateFormatter.string(from: currentEvent.eventDate)
        lblDistance.text = hdrText
        
        if usePreset && currentEvent.selectedTeams.count > 1 {
            //tally all the points
            var team1pts = 0
            var team2pts = 0
            let club1 = currentEvent.selectedTeams[0].clubName
            let club2 = currentEvent.selectedTeams[1].clubName
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
            lblPoints.text = String(format:"%@ %d points - %@ %d points",club1,team1pts,club2,team2pts)
            
        }else{
            lblPoints.isHidden = true
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
        
        resultList = Array(currentEvent.eventResults)
        
        for grp in sectionGroups {
            var erForGroup : [EventResult] = []
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
    
    func buildGroups() {
        //everything is gouped . For event where a preset with age groups wasnt used its grouped by gender.
        //for preset events where age groups are used its grouped by the age groups
        
        
        sectionGroups.removeAll()
     
        
            for er in currentEvent.eventResults {
                if let mem = er.myMember.first {
                    if usePreset {
                        
                        if let agp = er.selectedAgeCategory.first {
                            
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
                    
                    }else{
                        
                            if sectionGroups.index(where: { $0.groupTitle == mem.gender }) == nil {
                                sectionGroups.append((id: mem.gender == "Male" ? 0 : 1 , groupTitle: mem.gender,grpGender: mem.gender))
                            }
                       
                    }
                }
            
            }
        
        
        //yes sections sort by group id not name
        //print(sectionGroups.count)
    }
    
    func sortListData() {
        var sortedArray : [EventResult]
        
      
            for grp in sectionGroups {
                
                
                sortedArray = (groupDict[grp.groupTitle]?.sorted(by: { $0.resultSeconds < $1.resultSeconds}))!
               
                groupDict.updateValue(sortedArray, forKey: grp.groupTitle)
                
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
    
    
}
