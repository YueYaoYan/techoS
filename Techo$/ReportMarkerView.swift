//
//  ReportMarkerView.swift
//  Techo$
//
//  Created by Yue Yan on 6/6/2022.
//

import UIKit
import Charts

public class ReportMarkerView: MarkerView{
    @IBOutlet weak var markerBoard: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var type: Int?
    
    let LINE = 0
    let BAR = 1
    let LINE_END = 2
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    func initUI() {
        Bundle.main.loadNibNamed("ReportMarkerView", owner: self, options: nil)
        
        addSubview(contentView)
        markerBoard.layer.cornerRadius = 10
        
        self.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        contentView.backgroundColor = UIColor.clear
    }
    
    func setData(amount: Double, date: String, type: Int){
        if type == LINE{
            self.offset = CGPoint(x: (self.frame.width/2), y: -self.frame.height)
        }else if type == BAR{
            self.offset = CGPoint(x: -self.frame.width*1.45, y: -self.frame.height)
        }else if type == LINE_END{
            self.offset = CGPoint(x: -(self.frame.width*3.45), y: -self.frame.height)
        }
        if amount != 0{
            amountLabel.text = amount.formatCurrency()
        }else{
            amountLabel.text = "$0.00"
        }
        dateLabel.text = date
    }
}
