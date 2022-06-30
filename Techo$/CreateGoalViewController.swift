//
//  CreateGoalViewController.swift
//  Techo$
//
//  Created by Yue Yan on 7/5/2022.
//

import UIKit
import UserNotifications

class CreateGoalViewController: PhotoViewController {
    @IBOutlet weak var goalImageView: UIImageView!
    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var reminderTimePicker: UIDatePicker!
    @IBOutlet weak var targetDatePicker: UIDatePicker!
    @IBOutlet weak var regularitySegment: UISegmentedControl!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var pageScrollView: UIScrollView!
    
    var appDelegate: AppDelegate?
    
    let NONE = 0
    let DAILY = 1
    let WEEKLY = 2
    
    @IBAction func onCreateClicked(_ sender: Any) {
        indicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        // check for validity of inputs
        guard let amount = amountField.text, let name = nameField.text else{
            return
        }
        
        let targetDate = targetDatePicker.date
        
        if amount.isEmpty || name.isEmpty || targetDate > Date() {
            var errorMsg = "Please ensure all fields are filled:"
            if amount.isEmpty {
                errorMsg += "\n- Must provide a target amount" }
            if name.isEmpty {
                errorMsg += "\n- Must provide a name"
            }
            if targetDate > Date() {
                errorMsg += "\n- Date must be after present time!"
            }
            self.view.isUserInteractionEnabled = true
            indicator.stopAnimating()
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }

        guard let amountDouble = stripToDouble(text:amount) else {self.view.isUserInteractionEnabled = true
            indicator.stopAnimating()
            displayMessage(title: "Error", message: "Error in creation!")
            return
            
        }
        
        Task{
            // create account and save image if image is not nil
            guard let goal = databaseController?.addGoal(name: name, targetDate: targetDate, targetAmount: amountDouble, regularity: 1), let image = await savePhoto() else{
                self.view.isUserInteractionEnabled = true
                indicator.stopAnimating()
                navigationController?.popViewController(animated: true)
                return
            }
            await MainActor.run {
                databaseController?.addImageToGoal(image: image, goal: goal)
                
                // create notification for goal
                createNotification(goal: goal)
                
                self.view.isUserInteractionEnabled = true
                indicator.stopAnimating()
            }
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up database
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // set up components
        imageView = goalImageView
        scrollView = pageScrollView
        amountField.addTarget(self, action: #selector(totalFieldDidChange(_:)), for: .editingChanged)
        
        // add tap gesture to image view, enable photo taking
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        goalImageView.isUserInteractionEnabled = true
        goalImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // force date picker to left
        targetDatePicker.semanticContentAttribute = .forceRightToLeft
        targetDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        reminderTimePicker.semanticContentAttribute = .forceRightToLeft
        reminderTimePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        takePhoto()
    }
    
    @objc func totalFieldDidChange(_ textField: UITextField) {
        if let totalString = amountField.text?.currencyInputFormatting() {
            amountField.text = totalString
        }
    }
    
    /**
            Create Notification for event if needed
        From: https://stackoverflow.com/questions/44313883/how-to-repeat-a-unusernotification-every-day
     */
    func createNotification(goal: Goal) {
        if  regularitySegment.selectedSegmentIndex == NONE{
            return
        }
        
        guard appDelegate!.notificationsEnabled == true else {
            displayMessage(title: "Notification disabled", message: "Notifications are disabled")
            return
        }
        guard let goalID = goal.id else{
            displayMessage(title: "Notification Error", message: "Goal cannot register notification!")
            return
        }
        
        // Configure notification content
        let content = UNMutableNotificationContent()
        
        let regularity = regularitySegment.selectedSegmentIndex == DAILY ? 1 : 7
        let id = AppDelegate.CATEGORY_IDENTIFIER + "GOALS." + goalID
        
        content.title = "Time to add towards your goal!"
        content.body = "Tap to open Techo$..."
        content.userInfo = [ "id": goal.id ?? "",
                             "regularity" : regularity]
        content.categoryIdentifier = id
        
        // Configure the recurring date.
        var dateComponents = DateComponents()
        let calender = Calendar.current
        let date = reminderTimePicker.date
        
        // set hour and minute
        dateComponents.hour = calender.component(.hour, from: date)
        dateComponents.minute = calender.component(.minute, from: date)
        
        // set day if its weekly
        dateComponents.calendar = calender
        if regularitySegment.selectedSegmentIndex == WEEKLY{
            dateComponents.day = calender.component(.day, from: date)
        }
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
