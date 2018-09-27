//
//  DualMeetViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 27/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import RealmSwift
class DualMeetViewController: UIViewController {
    
    let myFunc = appFunctions()
    let myDefs = appUserDefaults()
    
    var currentMeet = DualMeet()
    
    var defSwimClub = SwimClub()
    private var datepicker : UIDatePicker?
    
    @IBOutlet weak var lblMeetDate: UILabel!
    
    @IBOutlet weak var lblEvent: UILabel!
    
    @IBOutlet weak var lblTeam1: UILabel!
    
    @IBOutlet weak var lblTeam2: UILabel!
    
    @IBOutlet weak var btnEventDate: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defSwimClub = myDefs.getDefSwimClub()
        
        if currentMeet.dualMeetID != 0 {
            
        }
    }
    
    
    func loadMeetDetails() {
    
    }
    
    func validateDetails() -> Bool {
        var errMsg = ""
        
        
        if !errMsg.isEmpty {
            showError(errmsg: errMsg)
        }
        
        return errMsg.isEmpty
    }
    
    
    //MARK: DatePicker
    
    func configureDatePicker() {
        datepicker = UIDatePicker()
        datepicker?.datePickerMode = .date
        btnEventDate.inputView = datepicker
        if currentMeet.dualMeetID == 0 {
            datepicker?.date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        }else{
            datepicker?.date = currentEvent.eventDate
        }
        
        datepicker?.addTarget(self, action: #selector(DualMeetViewController.dateChanged(datepicker:)), for: .valueChanged)
        
    }
    
    @objc func dateChanged(datepicker:UIDatePicker) {
        
        lblMeettDate.text = myFunc.formatDate(thedate: datepicker.date)
        
        //COME BACK - need to update photos and member names blah blah ??
        removeKeyBoard()
        
    }
    //MARK: IBActons
    
    @IBAction func addNewTeam(_ sender: UIButton) {
    }
    
    
    @IBAction func pickPresetEvent(_ sender: UIButton) {
    }
    
    
    @IBAction func pickTeam(_ sender: UIButton) {
    }
    //MARK: - Errors
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func removeKeyBoard() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
