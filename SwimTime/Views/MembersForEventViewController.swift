//
//  MembersForEventViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift

class MembersForEventViewController: UITableViewController {

    let realm = try! Realm()
    var membersList : Results<Member>?
    var myfunc = appFunctions()
    var mydefs = appUserDefaults()
    var selectedEvent = Event()
    var filterShowing : Bool = true
    var usePreset : Bool = false
    var origtableframe  : CGRect = CGRect(x: 1.0, y: 1.0, width: 1.0, height: 1.0)
    
    let quickEntrySeg = "quickEntry"
    var origFilterViewHeight : CGFloat = 0
    var backFromQuickEntry = false
    
    var presetEventExtension : PresetEventExtension?
    
    @IBOutlet weak var filterView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //adjuts the height
        origtableframe = tableView.frame
        origFilterViewHeight = filterView.frame.size.height
        //print("orig height \(origFilterViewHeight)")
        
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        //filterView.frame.size.height = 1.0
        //filterView.isHidden = true
        
        //hideShowFilter(self)
        
        if let _  = presetEventExtension {
            usePreset = true
        }
        
        navigationItem.setHidesBackButton(true, animated: false)
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
    
    
    @IBAction func hideShowFilter(_ sender: Any) {
        filterShowing = !filterShowing
        if filterShowing {
            print("Im gonna show it")
        }else{
            print("Im swithcin it off")
        }
        //let tbheight = tableView.frame.size.height
        //print("tb height: \(tbheight)")
        let newtbFrame = CGRect(x: origtableframe.origin.x, y: origtableframe.origin.y - origFilterViewHeight, width: origtableframe.width, height: origtableframe.size.height + origFilterViewHeight)
        UIView.animate(withDuration: 1
            , animations: {
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
    func loadMembers() -> Bool{
        //Im trying to list Members that are NOT in this event
        //Couldnt fuck around finding a better way to do this. Im sure there is.
        
        var found : Bool = false
        
        
        var membersNotInEvent : Results<Member> = realm.objects(Member.self).sorted(byKeyPath: "memberName") //start wiht them all then filter if applicable
        
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
        let lh = membersList![indexPath.row + indexPath.section]
        do {
            try realm.write {
                lh.selectedForEvent = !lh.selectedForEvent
                
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
