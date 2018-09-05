//
//  EventViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 5/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit

class EventViewController: UIViewController,
UITableViewDelegate {

    let eventToMemberseg = "eventToMembers"
    
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtDistance: UITextField!
    
    
    @IBOutlet weak var btnReset: UIButton!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    
    
    @IBOutlet weak var lblFilter: UILabel!
    @IBOutlet weak var lblTimeDisplay: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions

    @IBAction func useRaceNosChanged(_ sender: UISwitch) {
    }
    
    @IBAction func btnResetClicked(_ sender: UIButton) {
    }
    
    
    @IBAction func btnStartClicked(_ sender: UIButton) {
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == eventToMemberseg {
            
        }
    }
    

}
