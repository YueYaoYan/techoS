//
//  InfoTableViewCell.swift
//  Techo$
//
//  Created by Yue Yan on 11/6/2022.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setLayout(_ type: String){
        infoLabel.text = "Click + to add new \(type)"
    }
}
