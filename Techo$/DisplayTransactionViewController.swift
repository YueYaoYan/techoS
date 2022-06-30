//
//  DisplayTransactionViewController.swift
//  Techo$
//
//  Created by Yue Yan on 18/5/2022.
//

import UIKit

class DisplayTransactionViewController: UIViewController {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    var transaction : Transaction?
    
    var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // initialise transaction data
        guard let trans = databaseController!.selectedTransaction, let date = trans.date, let isSpending = trans.isSpending else {
            displayMessage(title: "Error", message: "Transaction does not exsist!")
            navigationController?.popViewController(animated: true)
            return
        }
        self.transaction = trans
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MMM d, yyyy"
        dateLabel.text = "\(dateformatter.string(from: date))"
        var sign = "-"
        if !isSpending{
            sign = ""
        }
        amountLabel.text = "\(sign)$\(String(describing: trans.amount ?? 0.00))"
        categoryLabel.text = trans.category?.name ?? "None"
        accountLabel.text = trans.account?.name ?? trans.account?.number
        notesLabel.text = trans.note ?? ""
        imageView.image = loadImageData(filename: trans.image?.reference) ?? UIImage(named: "Image")
        
        
        
        
        setupNavigationBar()
    }
    
    @IBAction func deleteTransaction(_ sender: Any) {
        guard let trans = transaction else{
            displayMessage(title: "Error", message: "Transaction does not exsist")
            navigationController?.popViewController(animated: true)
            return
        }
        databaseController?.deleteTransaction(transaction: trans)
    }
    
}
