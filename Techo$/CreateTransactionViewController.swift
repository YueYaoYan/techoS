//
//  CreateTransactionViewControl.swift
//  Techo$
//
//  Created by Yue Yan on 2/5/2022.
//

import UIKit

class CreateTransactionViewController: PhotoViewController, AddCategoryDelegate, AddAccountDelegate, AddLocationDelegate, AddEventDelegate, AddGoalDelegate {
    
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var transTypeSegment: UISegmentedControl!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var pageScrollView: UIScrollView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    var category: Category?
    var account: Account?
    var event: Event?
    var goal: Goal?
    var locationAnnotation: LocationAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.isHidden = true
        imageView = receiptImageView
        scrollView = pageScrollView
        amountField.addTarget(self, action: #selector(amountFieldDidChange(_:)), for: .editingChanged)
        
        // add tap gesture to image
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        receiptImageView.isUserInteractionEnabled = true
        receiptImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // force date picker to left
        datePicker.semanticContentAttribute = .forceRightToLeft
        datePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        takePhoto()
    }
    
    
    
    @IBAction func onAddTransactionClicked(_ sender: Any) {
        // check validity of data
        guard let amount = amountField.text else{
            return
        }
        
        if amount.isEmpty || account == nil || category == nil {
            var errorMsg = "Please ensure all fields are filled:\n"
            if amount.isEmpty {
                errorMsg += "- Must provide an amount\n" }
            if account == nil {
                errorMsg += "- Must select an account"
            }
            if category == nil {
                errorMsg += "- Must select a category"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }

        guard let amount = stripToDouble(text: amount) else {
            displayMessage(title: "Error", message: "Error in amount input!")
            return
        }
        
        
        let date = datePicker.date
        let isSpending = transTypeSegment.selectedSegmentIndex == 1
        let note = noteField.text ?? ""
        
        // check if amount is negative
        if goal != nil && isSpending{
            displayMessage(title: "Negative Transaction", message: "Cannot add negative transaction to saving goal!")
            return
        }
        
        // check if date is during event
        if event != nil{
            guard let eventStart = event?.startDate, let eventEnd = event?.endDate else{
                displayMessage(title: "Error", message: "Something went wrong in configuring event!")
                navigationController?.popToRootViewController(animated: true)
                return
            }
            if date < eventStart || date > eventEnd{
                displayMessage(title: "Incorrect Date", message: "The date you have entered is not during the event!")
                return
            }
        }
        
        // start indicator
        indicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        // create account and save image if image is not nil
        guard let transaction = databaseController?.addTransaction(amount: amount, date: date, isSpending: isSpending, note: note) else{
            self.view.isUserInteractionEnabled = true
            indicator.stopAnimating()
            displayMessage(title: "Error", message: "Error in creation!")
            return
        }
        databaseController?.addCategoryToTransaction(category: category!, transaction: transaction)
        
        if let locAnno = locationAnnotation {
            let location = (databaseController?.addLocation(name: locAnno.title!, address: locAnno.subtitle!, lat: Double(locAnno.coordinate.latitude), lon: Double(locAnno.coordinate.longitude)))!
            databaseController?.addLocationToTransaction(location: location, transaction: transaction)
        }
        
        // add image, account and goal/event if selected
        Task{
            if let image = await savePhoto() {
                databaseController?.addImageToTransaction(image: image, transaction: transaction)
            }
            
            await MainActor.run {
                databaseController?.addTransToAccount(transaction: transaction, account: account!)
            }
            
            await MainActor.run {
                if goal != nil{
                    _ = databaseController?.addTransToGoal(transaction: transaction, goal: goal!)
                } else if event != nil {
                    databaseController?.addTransToEvent(transaction: transaction, event: event!)
                }
                
            }
            await MainActor.run {
                self.view.isUserInteractionEnabled = true
                indicator.stopAnimating()
                navigationController?.popToRootViewController(animated: true)
            }
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        // if category, account, location is selected then set text
        if category != nil{
            categoryField.text = category!.name
        }
        if account != nil{
            if account!.name == ""{
                accountField.text = account!.number
            }else{
                accountField.text = account!.name ?? account!.number
            }
        }
        if locationAnnotation != nil{
            locationField.text = locationAnnotation!.title!
        }
    }
    
    
    // MARK: Functions to add properties to class
    func addCategory(category: Category) {
        self.category = category
    }
    
    func addAccount(account: Account) {
        self.account = account
    }
    
    func addEvent(event: Event) {
        self.event = event
    }
    
    func addGoal(goal: Goal) {
        self.goal = goal
    }
    
    func addLocation(location: LocationAnnotation) {
        self.locationAnnotation = location
    }

    // MARK: NAVIGATION
    //// In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "selectCategorySegue"{
            let destination = segue.destination as! AllCategoryTableViewController
            destination.addCategoryDelegate = self
            
        }else if segue.identifier == "selectAccountSegue"{
            let destination = segue.destination as! AllAccountsTableViewController
            destination.addAccountDelegate = self
            
        }else if segue.identifier == "selectLocationSegue"{
            let destination = segue.destination as! MapViewController
            destination.addLocationDelegate = self
        }
    }
    
    

}
