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

    
    @IBOutlet weak var btnMembers: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func memberClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "gotoMembersList", sender: self)
        
    }
    
    
}

