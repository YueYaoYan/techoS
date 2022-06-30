//
//  EventCardTableViewCell.swift
//  Techo$
//
//  Created by Yue Yan on 5/5/2022.
//

import UIKit

class GoalCardTableViewCell: UITableViewCell {
    @IBOutlet weak var outterBox: UIView!
    @IBOutlet weak var innerBox: UIView!
    @IBOutlet weak var imageViewHolder: UIView!
    @IBOutlet weak var goalImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var targetDateLabel: UILabel!
    @IBOutlet weak var remainingAmountLabel: UILabel!
    @IBOutlet weak var targetAmountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // customise display
        outterBox.layer.cornerRadius = 15
        innerBox.layer.cornerRadius = 10
        imageViewHolder.layer.cornerRadius = 10
        goalImageView.layer.cornerRadius = 10
        
        self.selectionStyle = .none
    }
    
    func setLayout(title: String?, date: Date?, remainingAmount: Double?, targetAmount: Double?, imageData: ImageMetaData?){
        guard let date = date else {return}
        titleLabel.text = title ?? ""
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMM d, yyyy HH:mm"
        targetDateLabel.text = dateformatter.string(from: date)
        remainingAmountLabel.text = remainingAmount?.formatCurrency() ?? ""
        targetAmountLabel.text = targetAmount?.formatCurrency() ?? ""
        if imageData != nil{
            goalImageView.image = loadImageData(filename: imageData?.reference)
        }else{
            goalImageView.image = UIImage(named: "Image")
        }
    }
}
