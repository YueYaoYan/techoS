//
//  EventCardTableViewCell.swift
//  Techo$
//
//  Created by Yue Yan on 7/5/2022.
//

import UIKit

class EventCardTableViewCell: UITableViewCell {
    @IBOutlet weak var outterBox: UIView!
    @IBOutlet weak var innerBox: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var labelBox: UIView!
    @IBOutlet weak var imageHolderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outterBox.layer.cornerRadius = 15
        innerBox.layer.cornerRadius = 10
        imageHolderView.layer.cornerRadius = 10
        eventImageView.layer.cornerRadius = 10
        eventImageView.clipsToBounds = true
        labelBox.layer.cornerRadius = 10
        labelBox.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        self.selectionStyle = .none
        
    }
    
    func setLayout(title: String?, startDate: Date?, endDate: Date?, totalAmount: Double?, imageData: ImageMetaData?){
        guard let endDate = endDate, let startDate = startDate else {
            return
        }

        titleLabel.text = title ?? ""
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = "\(dateformatter.string(from: startDate)) ~ \(dateformatter.string(from: endDate))"
        amountLabel.text = totalAmount?.formatCurrency() ?? ""
        if imageData != nil{
            eventImageView.image = loadImageData(filename: imageData?.reference)
        } else {
            eventImageView.image = UIImage(named: "Image")
        }
    }
}
