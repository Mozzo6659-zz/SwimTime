//
//  MembersViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 3/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import ChameleonFramework
import RealmSwift

class MembersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtOnekHrs: UITextField!
    @IBOutlet weak var txtOnekMinutes: UITextField!
    @IBOutlet weak var txtDOBDay: UITextField!
    @IBOutlet weak var txtDOBMonth: UITextField!
    @IBOutlet weak var txtDOBYear: UITextField!
    @IBOutlet weak var lblGroup: UILabel!
    @IBOutlet weak var txtOnekSeconds: UITextField!
    
    @IBOutlet weak var btnMale: UIButton!
    
    @IBOutlet weak var btnFemale: UIButton!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    let realm = try! Realm()
    var myfunc = appFunctions()
    var myDefs = appUserDefaults()
    
    var pickerItems : Results<Group>?
    
    var selectedMember = Member()
    var selectedGroup = Group()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //flat colours look shit
        //self.view.backgroundColor = GradientColor(.leftToRight, frame: self.view.frame, colors: [FlatSkyBlue(),FlatSkyBlueDark()])
        
        navigationItem.setHidesBackButton(true, animated: false)
        //pickerView.isHidden = true
        configureView()
        
        if (selectedMember.memberID == 0 ) {
            //selectedGroup = pickerItems![0]
            startNewMember()
            //[btnSave setHidden:quickEntry];
        }else{
            //NSLog(@"onek=%d",selectedMember.onekseconds);
            showSelectedMember()
            //[btnSave setHidden:YES];
        }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
    
        txtName.becomeFirstResponder()
    
    //[vwExtraDetails setHidden:quickEntry];
    
        loadPickerData()
        pickerView.delegate = self
        pickerView.dataSource = self
    
        pickerView.isHidden = true
    
        self.view.bringSubview(toFront: pickerView)
        
    }

    //MARK: - Picker data stuff
    
    func loadPickerData() {
        pickerItems = realm.objects(Group.self)
        
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems!.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerItems![row].groupName
        
    
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lblGroup.text = pickerItems![row].groupName
        selectedGroup = pickerItems![row]
        pickerView.isHidden = true
        
        //Im gonna remove the member from the list
        if selectedMember.memberID != 0 {
            if selectedMember.myGroup.count != 0 {
                let memberGroup = selectedMember.myGroup.first!
                var index : Int = 0
                
                if  memberGroup.members.count != 0 {
                    for mem in memberGroup.members {
                        if mem.memberID == selectedMember.memberID {
                            do {
                                try realm.write {
                                    memberGroup.members.remove(at: index)
                                }
                            }catch{
                                
                            }
                            continue
                        }else{
                            index += 1
                        }
                        
                    }
                }
            }
            
            
        }
        
        
    }
    
    //MARK: - Button functions
    @IBAction func groupBtnClicked(_ sender: UIButton) {
        removeKeyBoard()
        var pnt : CGPoint = lblGroup.center
        pnt.x = pnt.x - 60.0
        pnt.y = pnt.y + 60.0
        pickerView.center = pnt
        pickerView.isHidden = false
    }
    
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnGenderClicked(_ sender: UIButton) {
        
        if sender.tag == 1 {
            btnMale.setImage(getTickedImage(), for: .normal)
            
            btnFemale.setImage(getUnTickedImage(), for: .normal)
            
            selectedMember.gender = "Male"
        }else{
            btnMale.setImage(getUnTickedImage(), for: .normal)
            
            btnFemale.setImage(getTickedImage(), for: .normal)
            selectedMember.gender = "Female"
        }
    }
    
    func getTickedImage() -> UIImage {
        return UIImage(named: "tickbox")!
    }
    func getUnTickedImage() -> UIImage {
        return UIImage(named: "openbox")!
    }
    func removeKeyBoard() {
        self.view.endEditing(true)
    }
    
    @IBAction func saveBtnClicked(_ sender: UIButton) {
        
        if validateEventDetails() {
            let thetime = String(format:"%02d:%02d:%02d",getIntValueFromTextField(txt: txtOnekHrs),
                                 getIntValueFromTextField(txt: txtOnekMinutes),getIntValueFromTextField(txt: txtOnekSeconds))
            
           let DOB = String(format:"%02d/%02d/%04d",getIntValueFromTextField(txt: txtDOBDay), getIntValueFromTextField(txt: txtDOBMonth), getIntValueFromTextField(txt: txtDOBYear))
            
            //NSLog(@"%@",DOB);
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
        
            
            do {
                try realm.write {
                    if selectedMember.memberID == 0 {
                        selectedMember.memberID = myDefs.getNextMemberId()
                        selectedGroup.members.append(selectedMember)
                    }
                    
                    selectedMember.emailAddress = txtEmail.text!
                    selectedMember.memberName = txtName.text!
                    selectedMember.onekSeconds = myfunc.convertTimeToSeconds(thetimeClock: thetime)
                    selectedMember.dateOfBirth = dateFormatter.date(from: DOB)!
                    
                }
                
                
            }catch{
                //come back here
                print("Couldnt save data")
            }
        }
    }
    
    func getIntValueFromTextField(txt: UITextField) -> Int {
        var retVal : Int = 0
        
        if let thetxtval = txt.text {
            if thetxtval != "" {
                retVal = Int(thetxtval)!
            }
        }
        
        return retVal
    }
    
    
    //MARK: - Selected member manipulation
    func showSelectedMember() {
        txtName.text = selectedMember.memberName
        txtEmail.text = selectedMember.emailAddress
        
        if selectedMember.gender == "Male" {
            btnMale.setImage(getTickedImage(), for: .normal)
            btnFemale.setImage(getUnTickedImage(), for: .normal)
   
        }else{
            btnMale.setImage(getUnTickedImage(), for: .normal)
            btnFemale.setImage(getTickedImage(), for: .normal)
    
        }
    
        let onektime = myfunc.convertSecondsToTime(timeinseconds: selectedMember.onekSeconds)
    
        let thetime = onektime.components(separatedBy:":")
        
        txtOnekHrs.text = thetime[0]
        txtOnekMinutes.text = thetime[1]
        txtOnekSeconds.text = thetime[2];
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
    
    
        let birthday = dateFormatter.string(from: selectedMember.dateOfBirth)
        let thedatesplit = birthday.components(separatedBy:"-")
    
        txtDOBYear.text = thedatesplit[0]
        txtDOBMonth.text = thedatesplit[1]
        txtDOBDay.text = thedatesplit[2]
    
        
        lblGroup.text = selectedMember.myGroup.first?.groupName
    
        //NSString *photoname = [mysettings makePhotoName:selectedMember.memberid];
        if selectedMember.memberID != 0 {
            let imgFilePath = myfunc.getFullPhotoPath(memberid: selectedMember.memberID)
    
            imgPhoto.image = UIImage(contentsOfFile:imgFilePath)
    
        }
    }
    
    func startNewMember() {
    
        txtName.text = ""
        txtOnekHrs.text = "00"
        txtOnekMinutes.text = "20"
        txtOnekSeconds.text = "00"
    
        txtEmail.text = ""
        txtDOBDay.text = ""
        txtDOBMonth.text = ""
        txtDOBYear.text = ""
    
  
        imgPhoto.image = nil
        
        txtName.becomeFirstResponder()
    
        selectedGroup = realm.objects(Group.self).first!
        lblGroup.text = selectedGroup.groupName
    }

    //MARK: Erors
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: "errmsg", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func validateEventDetails() -> Bool {
        
        var errmsg = ""
        
        let hrTime = getIntValueFromTextField(txt: txtOnekHrs)
        
       let minTime = getIntValueFromTextField(txt:txtOnekMinutes)
        let secTime = getIntValueFromTextField(txt:txtOnekSeconds)
        
        
        
        if let memname = txtName.text {
            if memname == "" {
                errmsg = "Name is required"
            }
        }else {
            errmsg = "Name is required"
        }
    
        
        if (hrTime==0 && minTime==0 && secTime==0) {
            errmsg = "One K time is invalid";
            
        }
        
        if (errmsg=="") {
            
            errmsg = myfunc.validateMinutesSeconds(howmany: minTime)
            
            if (errmsg=="") {
                errmsg = myfunc.validateMinutesSeconds(howmany: secTime)
            }
        }
        
        if (errmsg=="") {
            //check the birthdate is ok
            let DOBDay = getIntValueFromTextField(txt: txtDOBDay)
            let DOBMonth = getIntValueFromTextField(txt: txtDOBMonth)
            let DOBYear = getIntValueFromTextField(txt: txtDOBYear)
            
            if (DOBDay < 1 || DOBDay > 31) {
                errmsg = "Invalid DOB"
            }
            if (DOBMonth < 1 || DOBMonth > 12) {
                errmsg = "Invalid DOB"
            }
            if (DOBYear < 1940 || DOBYear > 2100) {
                errmsg = "Please enter a four digit year "
            }
            if (errmsg=="") {
                if !myfunc.isValidDate(theday:DOBDay, themonth:DOBMonth, theyear:DOBYear) {
                    errmsg = "Invalid DOB"
                }
            }
            
        }
        if (errmsg != "") {
            showError(errmsg: errmsg)
        }
        
        return (errmsg=="");
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
