//
//  TransactionCardTableViewCell.swift
//  Techo$
//
//  Created by Yue Yan on 10/5/2022.
//

import UIKit

class TransactionCardTableViewCell: UITableViewCell {
    @IBOutlet weak var outterBox: UIView!
    @IBOutlet weak var imageViewHolder: UIView!
    @IBOutlet weak var transImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outterBox.layer.borderWidth = 1
        outterBox.layer.borderColor = UIColor(named: "boarderColor")?.cgColor
        
        self.selectionStyle = .none
    }
    
    func setLayout(accountName: String?, categoryName: String?, amount: Double?, isSpending: Bool?, imageData: ImageMetaData?){
        guard isSpending != nil, amount != nil else {return}
        accountLabel.text = accountName ?? ""
        categoryLabel.text = categoryName ?? ""
        var sign = "-"
        if !isSpending!{
            sign = ""
        }
        amountLabel.text = "\(sign)" + amount!.formatCurrency()
        if imageData != nil{
            transImageView.image = loadImageData(filename: imageData?.reference)
        } else {
            transImageView.image = UIImage(named: "Image")
        }
    }
}
