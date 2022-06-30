//
//  FilterViewController.swift
//  Techo$
//
//  Created by Yue Yan on 17/5/2022.
//

import UIKit

class FilterViewController: UIViewController, AddCategoryDelegate {
    func addCategory(category: Category) {
        self.category = category
    }
    
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    @IBOutlet weak var fromAmountField: UITextField!
    @IBOutlet weak var toAmountField: UITextField!
    
    var category: Category?
    var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add listener to amount fields
        toAmountField.addTarget(self, action: #selector(amountFieldDidChange(_:)), for: .editingChanged)
        fromAmountField.addTarget(self, action: #selector(amountFieldDidChange(_:)), for: .editingChanged)
        
        // initiate database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // force data picker to be on the left
        fromDatePicker.semanticContentAttribute = .forceRightToLeft
        fromDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        toDatePicker.semanticContentAttribute = .forceRightToLeft
        toDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft        
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        if category != nil{
            categoryField.text = category!.name
        }
    }
    
    @IBAction func removeFilter(_ sender: Any) {
        databaseController!.currentFilter = FilterGroup()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterTransaction(_ sender: Any) {
        let toDate = toDatePicker.date
        let fromDate = fromDatePicker.date
        var toAmount: Double? = nil
        if ((toAmountField.text?.isEmpty) != nil) {
            toAmount = stripToDouble(text: toAmountField.text!)
        }
        
        var fromAmount: Double? = nil
        if ((fromAmountField.text?.isEmpty) != nil) {
            fromAmount = stripToDouble(text: fromAmountField.text!)
        }
        let filter = FilterGroup(category: category, toDate: toDate, fromDate: fromDate, toAmount: toAmount, fromAmount: fromAmount)
        databaseController!.currentFilter = filter
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         if segue.identifier == "selectCategorySegue"{
             let destination = segue.destination as! AllCategoryTableViewController
             destination.addCategoryDelegate = self
         }
     }

}
