//
//  MembersListViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 2/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
class MembersListViewController: UITableViewController {
    
    let realm = try! Realm()
    var membersList : Results<Member>?
    var myfunc = appFunctions()
    var backFromMember : Bool = false
    var selectedMember = Member()
    let memberseg = "memberListToMember"
    
//    @IBOutlet weak var btnNewmember: UIBarButtonItem!
//
//    @IBOutlet weak var btnHome: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        if loadMembers() {
            //tableView.rowHeight = 80.0
            //tableView.separatorStyle = .none
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if backFromMember {
            if loadMembers() {
                tableView.reloadData()
            }
            
            selectedMember = Member() //reset this or ot stays for th secnd time
            
            backFromMember = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - IBActions
    @IBAction func newMemberClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: memberseg, sender: self)
    }
    
    @IBAction func homeClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - my Data stuff
    func loadMembers() -> Bool{
        var found : Bool = false
        membersList = realm.objects(Member.self)

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath)

        configureCell(cell: cell, atIndexPath: indexPath)

        return cell
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:IndexPath) {
    
        
        let lh = membersList![indexPath.row + indexPath.section]
        
        //print(lh.memberName + " at \(indexPath.row) gender \(lh.gender) id=\(lh.memberID)")
        
        //cell.backgroundColor = UIColor.white
        //cell.tintColor = UIColor.white
        
        
        cell.textLabel?.font = UIFont(name:"Helvetica", size:40.0)
     
    cell.textLabel?.text = lh.memberName
    
    cell.detailTextLabel?.font = UIFont(name:"Helvetica", size:20.0);
    
    cell.detailTextLabel?.textColor = UIColor.red

    
        var dtText = String(format:"Age: %d",lh.age())
        
        
        if let grp = lh.myGroup.first {
            dtText = dtText + String(format:"   Group: %@",grp.groupName)
        }
       
        dtText = dtText + String(format:"   One K: %@",myfunc.convertSecondsToTime(timeinseconds: lh.onekSeconds))
    
        cell.detailTextLabel?.text = dtText
        cell.layer.cornerRadius = 8
    
        let imgFilePath = myfunc.getFullPhotoPath(memberid: lh.memberID)
    
        let imgMemberPhoto = UIImageView(image: UIImage(contentsOfFile: imgFilePath))
        cell.backgroundColor = UIColor(hexString: "89D8FC") //light blue.-- hard setting ths doesnt seem to work as well
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
            //[imgMemberPhoto sizeToFit];
        
   
        
    
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
        selectedMember = membersList![indexPath.row + indexPath.section]
        performSegue(withIdentifier: memberseg, sender: self)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //need t tsake member out of th club and any event results
            let mem = membersList![indexPath.row + indexPath.section]
            let memClub = mem.myClub.first
            
            let evResults = mem.eventResults
            
            do {
                try realm.write {
                    
                    //remove from the club
                    if let mxm = memClub?.members.index(where: {$0.memberID == mem.memberID}) {
                         memClub?.members.remove(at: mxm)
                    }
                    
                    //delete the event results
                    if evResults.count != 0 {
                        realm.delete(evResults)
                    }
                    //delete the member
                    realm.delete(mem)
                }
            } catch {
                self.showError(errmsg: "Cant delete member")
            }
            
            if loadMembers() {
                tableView.reloadData()
            }
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == memberseg {
            backFromMember = true
            let vc = segue.destination as! MembersViewController
            vc.selectedMember = selectedMember
        }
    }
    
    //MARK: - Errors
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
}
