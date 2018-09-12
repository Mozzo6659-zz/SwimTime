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
    
    
    @IBOutlet weak var myToolbar: UIToolbar!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var btnSortByImprovement: UIButton!
    @IBOutlet weak var btnSortByTime: UIButton!
    
    @IBOutlet weak var tbTime: UIBarButtonItem!
    
    @IBOutlet weak var tbGroup: UIBarButtonItem!
    
    
    var resultList : [EventResult] = [] //use if not in group Mode
    var groupDict : [String : [EventResult]] = [:]
    var sectionGroups : [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       navigationItem.setHidesBackButton(true, animated: false)
        //register the custom cell
        myTableView.register(UINib(nibName: "ResultCell", bundle: nil), forCellReuseIdentifier: "ResultCell")
        
        tbTime.tintColor = UIColor.orange
        getData()
        changeBtnColour()
        showEventDetails()
        // Do any additional setup after loading the view.
    }
    
    func showEventDetails() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        lblDistance.text = ("\(currentEvent.eventLocation)  \(currentEvent.eventDistance) meters") + dateFormatter.string(from: currentEvent.eventDate)
        
        
        
    }
    
    @IBAction func sortBtnClicked(_ sender: UIButton) {
        sortByTime = sender.tag == 1
        //isGrouped = sender.tag == 2
        changeBtnColour()
        sortListData()
        
        
    }
    
    @IBAction func goHome(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    @IBAction func groupBy(_ sender: UIBarButtonItem) {
        
        tbTime.tintColor = myToolbar.tintColor
        tbGroup.tintColor = myToolbar.tintColor
        
        isGrouped = sender.tag == 2
        
        sender.tintColor = UIColor.orange
       sortListData()
    
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
            //print(groupDict.count)
        }
    }
    
    func buildGroups() {
        var tempGroups : [Group] = []
        for er in currentEvent.eventResults {
            let mem = er.myMember.first
            if let grp = mem?.myGroup.first {
                //print(grp.groupName)
                if tempGroups.count == 0 {
                    tempGroups.append(grp)
                }else{
                    if tempGroups.index(where: { $0.groupName == grp.groupName }) == nil {
                        tempGroups.append(grp)
                    }
                    
                }
            }
        }
        
        //yes sections sort by group id not name
        sectionGroups = tempGroups.sorted(by: { $0.groupID < $1.groupID})
        //print(sectionGroups.count)
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
            label.text = sectionGroups[section].groupName
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
        var hdrText = ""
        if isGrouped {
            if let myArray = groupDict[sectionGroups[indexPath.section].groupName] {
                er = myArray[indexPath.row]
            }
            
        }else{
            er = resultList[indexPath.row]
        }
        
        if let mem = er.myMember.first {
            //print(mem.memberName)
            hdrText = mem.memberName
        }
        
        if currentEvent.usePoints {
            hdrText += (" \(er.pointsEarned) points")
        }
        
        cell.lblHeader.text = hdrText
        cell.lblEstimate.text = "Est: " + myfunc.convertSecondsToTime(timeinseconds: er.expectedSeconds)
        cell.lblImprovement.text = "Diff: " + myfunc.convertSecondsToTime(timeinseconds: er.diffSeconds)
        cell.lblResult.text = "Result: " + myfunc.convertSecondsToTime(timeinseconds: er.resultSeconds)
        
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
            
    
        
     }
    
    
}
