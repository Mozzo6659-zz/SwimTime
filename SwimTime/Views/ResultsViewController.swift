//
//  ResultsViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 7/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    
    var sortByTime = true
    
    var currentEvent = Event()
    
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var btnSortByImprovement: UIButton!
    
    @IBOutlet weak var btnSortByTime: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//

    

    

    
}
