//
//  ResultCell.swift
//  SwimTime
//
//  Created by Mick Mossman on 9/9/18.
//  Copyright © 2018 Mick Mossman. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var lblHeader: UILabel!
    
    @IBOutlet weak var lblEstimate: UILabel!
    
    @IBOutlet weak var lblImprovement: UILabel!
    
    
    @IBOutlet weak var lblPoints: UILabel!
    
    
    @IBOutlet weak var lblResult: UILabel!
    
    @IBOutlet weak var imgMedal: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
