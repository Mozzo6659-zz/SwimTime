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

class MembersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtOnekHrs: UITextField!
    @IBOutlet weak var txtOnekMinutes: UITextField!
    @IBOutlet weak var txtDOBDay: UITextField!
    @IBOutlet weak var txtDOBMonth: UITextField!
    @IBOutlet weak var txtDOBYear: UITextField!
    @IBOutlet weak var txtOnekSeconds: UITextField!
    @IBOutlet weak var lblGroup: UILabel!
    
    
    @IBOutlet weak var btnMale: UIButton!
    
    @IBOutlet weak var btnFemale: UIButton!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    let realm = try! Realm()
    var myfunc = appFunctions()
    var myDefs = appUserDefaults()
    var selectedGender = 1
    var pickerItems : Results<SwimClub>?
    var photoUpdated = false
    var selectedMember = Member()
    //var selectedGroup = Group()
    var selectedClub = SwimClub()
    var defSwimClub = SwimClub()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defSwimClub = myDefs.getDefSwimClub()
        navigationItem.setHidesBackButton(true, animated: false)

        configureView()
        
        if (selectedMember.memberID == 0 ) {
            
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
        
        //uncommet when runnign on simulator or it blows up
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true

        loadPickerData()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true        
        
        self.view.bringSubviewToFront(pickerView)
        
    }

    
    
    //MARK: - Picker data stuff
    
    func loadPickerData() {
        pickerItems = realm.objects(SwimClub.self)
        
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems!.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerItems![row].clubName
        
    
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lblGroup.text = pickerItems![row].clubName
        selectedClub = pickerItems![row]
        defSwimClub = selectedClub
        pickerView.isHidden = true
        //Im gonna remove the member from the list
        
    }
    
    //MARK: - Button functions
    @IBAction func groupBtnClicked(_ sender: UIButton) {
        removeKeyBoard()
        
        if sender.tag == 1 {
            if pickerItems?.count != 0 {
                var pnt : CGPoint = lblGroup.center
                pnt.x = pnt.x - 60.0
                pnt.y = pnt.y + 60.0
                
                pickerView.center = pnt
                pickerView.isHidden = false
            }
        }else{
            addNewTeam()
        }
    }
    
    func addNewTeam() {
        var userTextField = UITextField() //module lel textfile used in the closure
        userTextField.autocapitalizationType = .words
        
        let alert = UIAlertController(title: "Add New Team", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add Team", style: .default) {
            (action) in
            
            //var item = Item(thetitle: userTextField.text!)
            let newName = userTextField.text!
            if !newName.isEmpty {
                bContinue = !self.myFunc.isDuplicateClub(newClubname: newName)
            }
            
            if !newName.isEmpty {
                do {
                    try self.realm.write {
                        let newClub = SwimClub()
                        newClub.clubID = self.myDefs.getNextClubId()
                        newClub.clubName = newName
                        newClub.isDefault = false
                        self.realm.add(newClub)
                        self.loadPickerData()
                        self.pickerView.reloadAllComponents()
                        self.defSwimClub = newClub
                        self.selectedClub = newClub
                        self.lblGroup.text = newClub.clubName
                    }
                } catch {
                    print("Error saving items: \(error)")
                }
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Team"
            userTextField = alertTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (action) in
            self.removeKeyBoard()
        }
        alert.addAction(alertAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
                //self.saveData(item: item)
        

    }
    
    @IBAction func takePhoto(_ sender: Any) {
        
        present(imagePicker, animated: true, completion: nil)

    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        //let myList = realm.objects(Member.self)
        
//        for mem in myList {
//            print(mem.memberName)
//        }
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnGenderClicked(_ sender: UIButton) {
        
        sender.isSelected = false
        
        if sender.tag == 1 {
            btnMale.setImage(getTickedImage(), for: .normal)

            btnFemale.setImage(getUnTickedImage(), for: .normal)
            
        }else{
            
            btnMale.setImage(getUnTickedImage(), for: .normal)

            btnFemale.setImage(getTickedImage(), for: .normal)
            
        }
       
        selectedGender = sender.tag
        
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
                    
                    //var newMember = Member()
                    
                    selectedMember.gender = selectedGender == 1 ? "Male":"Female"
                    //print(newMember.gender)
                    
                    selectedMember.emailAddress = txtEmail.text!
                    selectedMember.memberName = txtName.text!
                    //print(selectedMember.memberName)
                    selectedMember.onekSeconds = myfunc.convertTimeToSeconds(thetimeClock: thetime)
                    //print("\(selectedMember.onekSeconds)")
                    
                    selectedMember.dateOfBirth = dateFormatter.date(from: DOB)!
                    
                    //we dont use Groups any ore but im leavin it
                        if selectedMember.myClub.count != 0 {
                            let memberClub = selectedMember.myClub.first!

                            if selectedClub.clubName != memberClub.clubName {
                                if  memberClub.members.count != 0 {
                                    let mxm = memberClub.members.index(where: {$0.memberID == selectedMember.memberID})
                                    memberClub.members.remove(at: mxm!)
                                }
                            }
                        }



                    selectedClub.members.append(selectedMember)
                    
                    if selectedMember.memberID == 0 {
                        selectedMember.memberID = myDefs.getNextMemberId()
                        realm.add(selectedMember)
                    }
                }
                
                
                if photoUpdated && imgPhoto.image != nil {
                    
                    myfunc.writePhoto(memberid: selectedMember.memberID, img: imgPhoto.image!)
                    
                }
                
            }catch{
                //come back here
                showError(errmsg: "Couldnt save data")
            }
            
            startNewMember()
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
    
        
        lblGroup.text = selectedMember.myClub.first?.clubName
    
        if selectedMember.myClub.count != 0 {
            selectedClub = selectedMember.myClub.first!
        }
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
        photoUpdated = false
        
        txtName.becomeFirstResponder()
        selectedGender = 1
        
        btnMale.setImage(getTickedImage(), for: .normal)
        btnFemale.setImage(getUnTickedImage(), for: .normal)
        
        if selectedClub.clubID == 0 {
            selectedClub = defSwimClub
        }
        
        
        lblGroup.text = selectedClub.clubName
        selectedMember = Member()
    }

    //MARK: Erors
    
    
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

    //MARK: - Photo stuff
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let imagePicked = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            
            //imageView.image = imagePicked
            
            //guard let ciImagePicked = CIImage(image: imagePicked) else {fatalError("Bad image")}
            
            imgPhoto.image = imagePicked
            photoUpdated = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        
        
    }
    
    func showError(errmsg:String) {
        let alert = UIAlertController(title: "Error", message: errmsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
