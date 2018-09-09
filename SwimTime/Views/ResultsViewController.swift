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
    
    var sortByTime = true
    var isGrouped = false
    
    var currentEvent = Event()
    let myfunc = appFunctions()
    
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var btnSortByImprovement: UIButton!
    @IBOutlet weak var btnSortByTime: UIButton!
    
   
    var resultList : [EventResult] = [] //use if not in group Mode
    var groupDict : [String : [EventResult]] = [:]
    var sectionGroups : [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        changeBtnColour()
        showEventDetails()
        // Do any additional setup after loading the view.
    }
    
    func showEventDetails() {
        lblDistance.text = ("\(currentEvent.eventDistance) meters")
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        lblDate.text = dateFormatter.string(from: currentEvent.eventDate)
        
    }
    
    @IBAction func sortBtnClicked(_ sender: UIButton) {
        sortByTime = sender.tag == 1
        changeBtnColour()
    }
    
    
    
    func changeBtnColour() {
        //FFC1DF - pale pink
        //8EFF25 - brigt green
        let pinkHex = "FFC1DF"
        let greenHex = "8EFF25"
        let onColor : UIColor = UIColor(hexString: pinkHex)!
        let offColor : UIColor = UIColor(hexString: greenHex)!
        var onButton : UIButton
        var offButton : UIButton
        
        let onBWidth : CGFloat = 2
        let offBWidth : CGFloat = 0
        if sortByTime {
            onButton = btnSortByTime
            offButton = btnSortByImprovement
        }else{
            offButton = btnSortByTime
            onButton = btnSortByImprovement
        }
        
        offButton.layer.borderWidth = offBWidth
        offButton.backgroundColor = offColor
        onButton.layer.borderWidth = onBWidth
        onButton.backgroundColor = onColor
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
                if let mem = er.myMember.first {
                    if let memgrp = mem.myGroup.first {
                        if memgrp.groupName == grp.groupName {
                            erForGroup.append(er)
                        }
                    }
                }
            }
            groupDict[grp.groupName] = erForGroup
        }
    }
    
    func buildGroups() {
        var tempGroups : [Group] = []
        for er in currentEvent.eventResults {
            let mem = er.myMember.first
            if let grp = mem?.myGroup.first {
                if tempGroups.count == 0 {
                    tempGroups.append(grp)
                }else{
                    if tempGroups.index(of: grp) == nil {
                        tempGroups.append(grp)
                    }
                    
                }
            }
        }
        
        //yes sections sort by group id not name
        sectionGroups = tempGroups.sorted(by: { $0.groupID < $1.groupID})
    }
    
    func sortListData() {
        var sortedArray : [EventResult]
        
        for grp in sectionGroups {
            
            if sortByTime {
                sortedArray = (groupDict[grp.groupName]?.sorted(by: { $0.resultSeconds < $1.resultSeconds}))!
            } else {
                sortedArray = (groupDict[grp.groupName]?.sorted(by: { $0.diffSeconds < $1.diffSeconds}))!
            }
            groupDict.updateValue(sortedArray, forKey: grp.groupName)
            
        }
        
        
        
        if sortByTime {
            sortedArray = resultList.sorted(by: { $0.resultSeconds < $1.resultSeconds})
        }else{
            sortedArray = resultList.sorted(by: { $0.diffSeconds < $1.diffSeconds})
        }
        
        resultList = sortedArray
    }
    
    //MARK: - Tableview stuff

    func numberOfSections(in tableView: UITableView) -> Int {
        var intSections = 1
        if isGrouped {
            intSections = sectionGroups.count
        }
        
        return intSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var noRows : Int = 1
        if isGrouped {
            if let myArray = groupDict[sectionGroups[section].groupName] {
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
        
        if isGrouped {
            if let myArray = groupDict[sectionGroups[indexPath.section].groupName] {
                er = myArray[indexPath.row]
            }
            
        }else{
            er = resultList[indexPath.row]
        }
        
        if let mem = er.myMember.first {
            cell.lblHeader.text = mem.memberName
        }
        
        cell.lblEstimate.text = myfunc.convertSecondsToTime(timeinseconds: er.expectedSeconds)
        cell.lblImprovement.text = myfunc.convertSecondsToTime(timeinseconds: er.diffSeconds)
        cell.lblResult.text = myfunc.convertSecondsToTime(timeinseconds: er.resultSeconds)
        
        cell.lblImprovement.backgroundColor = er.diffSeconds < 0 ? UIColor.green : UIColor.red
        
        
        /*Setthe medals*/
       
            switch indexPath.row {
                case  0:
                    cell.imgMedal.image = UIImage(named: "gold7575")
                    break
                case  1:
                    cell.imgMedal.image = UIImage(named: "silver7575")
                    break
                case  2:
                    cell.imgMedal.image = UIImage(named: "bronze7575")
                    break
                default:
                    cell.imgMedal.image = nil
                    break
            }
            
        if currentEvent.usePoints {
            cell.lblPoints.text = String(format:"Points: %d", er.pointsEarned)
        }else{
            cell.lblPoints.text = ""
        }
        
     }

    

    

    
}
