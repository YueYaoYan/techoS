//
//  CardTableViewCell.swift
//  Techo$
//
//  Created by Yue Yan on 5/5/2022.
//

import UIKit

class AccountCardTableViewCell: UITableViewCell {
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var outterBox: UIView!
    @IBOutlet weak var innerBox: UIView!
    @IBOutlet weak var colourBar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outterBox.layer.cornerRadius = 15
        innerBox.layer.cornerRadius = 10
        colourBar.layer.cornerRadius = 5
        
        self.selectionStyle = .none
    }
    
    func setLayout(name: String?, number: String?, availableAmount: Double?, totalAmount: Double?){
        accountNameLabel.text = name ?? "Account"
        numberLabel.text = number ?? ""
        availableAmountLabel.text = availableAmount?.formatCurrency()
        totalAmountLabel.text = totalAmount?.formatCurrency()
    }
    
}
