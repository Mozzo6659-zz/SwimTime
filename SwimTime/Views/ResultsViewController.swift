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
    var isGrouped = false
    
    
    var currentEvent = Event()
    let myfunc = appFunctions()
    let mydef = appUserDefaults()
    
    @IBOutlet weak var lblDistance: UILabel!
    
    
    @IBOutlet weak var myToolbar: UIToolbar!
    @IBOutlet weak var myTableView: UITableView!
  
    
    @IBOutlet weak var tbTime: UIBarButtonItem!
    
    @IBOutlet weak var tbGroup: UIBarButtonItem!
    
    
    var resultList : [EventResult] = [] //use if not in group Mode
    var groupDict : [String : [EventResult]] = [:]
    var sectionGroups : [PresetEventAgeGroups] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       navigationItem.setHidesBackButton(true, animated: false)
       
        if let pse = currentEvent.presetEvent {
            if pse.eventAgeGroups.count != 0 {
                isGrouped = true
            }
        }
        myTableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        
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
        hdrText += ("\(currentEvent.eventLocation)  \(currentEvent.eventDistance) meters") + dateFormatter.string(from: currentEvent.eventDate)
        lblDistance.text = hdrText
    }
    
    
    @IBAction func goHome(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

    
    
    
    //MARK: - TableView data
    
    func getData() {
        //BUILD EVERYTHING ANYWAY TH JUTS CHANGE THE SORT ON A BUTTN PRESS
        //first lets get all the groups in the evet reuslts
        //these will be our sections
        buildGroups()
        buildLists()
        sortListData()
        
    }
    
    func buildLists() {
        
        resultList = Array(currentEvent.eventResults)
        
        for grp in sectionGroups {
            var erForGroup : [EventResult] = []
            for er in resultList {
                if let agp = er.selectedAgeCategory.first {
                    
                        if agp.presetAgeGroupName == grp.presetAgeGroupName {
                            erForGroup.append(er)
                        }
                    
                }
            }
            groupDict[grp.presetAgeGroupName] = erForGroup
            //print(groupDict.count)
        }
    }
    
    func buildGroups() {
        var tempGroups : [PresetEventAgeGroups] = []
        for er in currentEvent.eventResults {
            if let agp = er.selectedAgeCategory.first {
                if tempGroups.count == 0 {
                    tempGroups.append(agp)
                }else{
                    if tempGroups.index(where: { $0.presetAgeGroupName == agp.presetAgeGroupName }) == nil {
                        tempGroups.append(agp)
                    }
                    
                }
            }
           
        }
        
        //yes sections sort by group id not name
        sectionGroups = tempGroups.sorted(by: {$0.presetAgeGroupID < $1.presetAgeGroupID})
        //print(sectionGroups.count)
    }
    
    func sortListData() {
        var sortedArray : [EventResult]
        
      
            for grp in sectionGroups {
                
                
                sortedArray = (groupDict[grp.presetAgeGroupName]?.sorted(by: { $0.resultSeconds < $1.resultSeconds}))!
               
                groupDict.updateValue(sortedArray, forKey: grp.presetAgeGroupName)
                
            }
        
        
        
        resultList = resultList.sorted(by: { $0.resultSeconds < $1.resultSeconds})
        myTableView.reloadData()
    }
    
    //MARK: - Tableview stuff

    func numberOfSections(in tableView: UITableView) -> Int {
        var intSections = 1
        if isGrouped {
            intSections = sectionGroups.count
            //print("\(intSections)")
        }
        
        return intSections
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
        
        if isGrouped {
            headerView.backgroundColor = UIColor.black
            let label = UILabel(frame: CGRect(x: 0, y: -5, width: myTableView.frame.size.width, height: 30.0))
            label.clipsToBounds = true
            label.layer.cornerRadius = 5.0
            label.backgroundColor = UIColor.black
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont(name: "Helvetica", size: 25.0)
            label.text = sectionGroups[section].presetAgeGroupName
            //print(sectionGroups[section].groupName)
            headerView.addSubview(label)
            
        }else{
            headerView.backgroundColor = UIColor.clear
        }
        
        return headerView
}
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var noRows : Int = 1
        if isGrouped {
            if let myArray = groupDict[sectionGroups[section].presetAgeGroupName] {
                noRows = myArray.count
            }
            
        }else{
            noRows = resultList.count
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
        if isGrouped {
            if let myArray = groupDict[sectionGroups[indexPath.section].presetAgeGroupName] {
                er = myArray[indexPath.row]
            }
            
        }else{
            er = resultList[indexPath.row]
        }
        
        if let mem = er.myMember.first {
            //print(mem.memberName)
            hdrText = mem.memberName
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
        
        
        
        if isGrouped {
            cell.lblImprovement.text = String(format: "%d Points", pointsearned)
            cell.lblImprovement.backgroundColor = pointsearned > 0 ? UIColor.green : UIColor.flatPink
        }else{
            cell.lblImprovement.text = "Diff: " + myfunc.convertSecondsToTime(timeinseconds: er.diffSeconds)
            cell.lblImprovement.backgroundColor = er.diffSeconds < 0 ? UIColor.green : UIColor.red
        }
        
        cell.lblHeader.text = hdrText
        cell.lblEstimate.text = "Est: " + myfunc.convertSecondsToTime(timeinseconds: er.expectedSeconds)
        
        cell.lblResult.text = "Result: " + myfunc.convertSecondsToTime(timeinseconds: er.resultSeconds)
        
        
        
        
        /*Setthe medals and award points*/
       
        if pointsearned != 0 && isGrouped {
            do {
                try realm.write {
                    er.pointsEarned = pointsearned
                }
            }catch{
                
            }
        }
    
        
     }
    
    
}
