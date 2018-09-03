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
    
    @IBOutlet weak var btnNewmember: UIBarButtonItem!
    
    @IBOutlet weak var btnHome: UIBarButtonItem!
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
    
    
        let lh = membersList![indexPath.row]
    
        cell.backgroundColor = FlatGray()
        
        cell.textLabel?.font = UIFont(name:"Helvetica", size:40.0)
     
    cell.textLabel?.text = lh.memberName
    
    cell.detailTextLabel?.font = UIFont(name:"Helvetica", size:20.0);
    
    cell.detailTextLabel?.textColor = FlatRed()
    
    //timeFunctions *f = [[timeFunctions alloc] init];
    
        var dtText = String(format:"Age: %d",lh.age)
        
        //let items = realm.objects(Group.self).filter("groupName = 'List 2' ").first?.itemList
        
        if let grp = lh.myGroup.first {
            dtText = dtText + String(format:"   Group: %@",grp.groupName)
        }
       
        dtText = dtText + String(format:"   One K: %@",myfunc.convertSecondsToTime(timeinseconds: lh.onekSeconds))
    
        cell.detailTextLabel?.text = dtText
        cell.layer.cornerRadius = 8
    
        let imgFilePath = myfunc.getFullPhotoPath(memberid: lh.memberID)
    
        let imgMemberPhoto = UIImageView(image: UIImage(contentsOfFile: imgFilePath))
        
        if imgMemberPhoto.image != nil {
        
            if var frame = cell.accessoryView?.frame {
                    frame.size.width = 80.0
                    frame.size.height = 90.0
                    imgMemberPhoto.frame = frame
                    imgMemberPhoto.layer.masksToBounds = true
                    imgMemberPhoto.layer.cornerRadius = 20.0
                    cell.accessoryView = imgMemberPhoto
                    cell.accessoryView?.isHidden = false
            }else{
                cell.accessoryView?.isHidden = true
            }
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
        selectedMember = membersList![indexPath.row]
        performSegue(withIdentifier: memberseg, sender: self)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    
    
}
