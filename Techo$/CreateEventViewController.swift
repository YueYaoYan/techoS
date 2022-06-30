//
//  CreateEventViewController.swift
//  Techo$
//
//  Created by Yue Yan on 7/5/2022.
//

import UIKit

class CreateEventViewController: PhotoViewController {
    @IBOutlet weak var eventImageView: UIImageView!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var pageScrollView: UIScrollView!
    
    @IBAction func onCreateClicked(_ sender: Any) {
        indicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        // check vality of fields
        guard let name = nameField.text else{
            return
        }
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
    
        
        if name.isEmpty {
            self.view.isUserInteractionEnabled = true
            indicator.stopAnimating()
            displayMessage(title: "Not all fields filled", message: "Please provide a name for this event!")
            return
        }
                
        // create account and save image if image is not nil
        Task{
            guard let event = databaseController?.addEvent(endDate: endDate, startDate: startDate, name: name) else{
                self.view.isUserInteractionEnabled = true
                indicator.stopAnimating()
                displayMessage(title: "Error", message: "Event cannot be created!")
                return
            }
            if let image = await savePhoto() {
                databaseController?.addImageToEvent(image: image, event: event)
            }
            
            await MainActor.run {
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

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        imageView = eventImageView
        scrollView = pageScrollView
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            
        eventImageView.isUserInteractionEnabled = true
        eventImageView.addGestureRecognizer(tapGestureRecognizer)
        
        startDatePicker.semanticContentAttribute = .forceRightToLeft
        startDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
        endDatePicker.semanticContentAttribute = .forceRightToLeft
        endDatePicker.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        takePhoto()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
