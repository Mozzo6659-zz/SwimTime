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
    var membersList : List<Member>?
    var myfunc = appFunctions()
    var mydefs = appUserDefaults()
    var selectedEvent = Event()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        if loadMembers() {
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - IBActions
    
    
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        if membersList?.count != 0 {
        
            do {
                try realm.write {
                    for mem in membersList! {
                        mem.selectedForEvent = false
                        let er = EventResult()
                        if selectedEvent.useRaceNos {
                            er.raceNo = mydefs.getNextRaceNo()
                            
                        }
                        er.expectedSeconds = myfunc.adjustOnekSecondsForDistance(distance: selectedEvent.eventDistance , timeinSeconds: mem.onekSeconds)
                        realm.add(er)
                        mem.eventResults.append(er)
                        selectedEvent.eventResults.append(er)
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
        
        let membersNotInEvent : Results<Member> = realm.objects(Member.self)
        let memNotInEventArray = List<Member>()
        
        for m in membersNotInEvent {
            memNotInEventArray.append(m)
        }
        
        let resultsInEvent = selectedEvent.eventResults
        
        for rs in resultsInEvent {
            if let memberInEvent = rs.myMember.first {
                let mxm = memNotInEventArray.index(of: memberInEvent)
                memNotInEventArray.remove(at: mxm!)
            }
            
        }
        
        membersList = memNotInEventArray
        
        
        if (membersList?.count == 0) {
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
            tableView.backgroundView=nil;
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
        
        
        var dtText = String(format:"Age: %d",lh.age)
        
        
        if let grp = lh.myGroup.first {
            dtText = dtText + String(format:"   Group: %@",grp.groupName)
        }
        
        dtText = dtText + String(format:"   One K: %@",myfunc.convertSecondsToTime(timeinseconds: lh.onekSeconds))
        
        cell.detailTextLabel?.text = dtText
        cell.layer.cornerRadius = 8
        
        let imgFilePath = myfunc.getFullPhotoPath(memberid: lh.memberID)
        let imgMemberPhoto = UIImageView(image: UIImage(contentsOfFile: imgFilePath))
        
        
        cell.backgroundColor = UIColor(hexString: "BDC3C7") //hard setting ths doesnt seem to work as well
        if lh.selectedForEvent {
            let imageView = UIImageView(image: UIImage(named: "tickbig7575"))
            
            //[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tickbig7575.png"]];
            
            imageView.sizeToFit()
            cell.accessoryView = imageView
            
        }else {
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
