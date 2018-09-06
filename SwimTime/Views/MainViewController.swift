//
//  ViewController.swift
//  SwimTime
//
//  Created by Mick Mossman on 2/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit
import ChameleonFramework
class MainViewController: UIViewController {

    var showFinishedEvents = false //tells the eet seque
    let gotoEventsListSeg = "gotoEventsList"
    let gotoMembersListSeg = "gotoMembersList"
    @IBOutlet weak var btnMembers: UIButton!
    
    
    @IBOutlet weak var btnEvets: UIButton!
    
    @IBOutlet weak var btnResults: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMembers.layer.borderColor = UIColor.red.cgColor
        btnEvets.layer.borderColor = UIColor.red.cgColor
        
        btnResults.layer.borderColor = UIColor.red.cgColor
        self.navigationController?.setToolbarHidden(true, animated: false)
        //print("Flat Green " + FlatGreen().hexValue()) 2ECC70
       //self.view.backgroundColor = GradientColor(.leftToRight, frame: self.view.frame, colors: [FlatSkyBlue(),FlatSkyBlueDark()])
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Button functions
    
    @IBAction func mnubtnClicked(_ sender: UIButton) {
        var seg : String = ""
        showFinishedEvents = (sender.tag == 3)
        
        switch sender.tag {
        case 1:
            seg = gotoMembersListSeg
        case 2,3:
            
            seg = gotoEventsListSeg
            
        default:
            seg = ""
        }
        
        if seg != "" {
            performSegue(withIdentifier: seg, sender: self)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == gotoEventsListSeg {
            
            let vc = segue.destination as! EventsListViewController
            vc.showFinished = showFinishedEvents
        }
    }
    
}

