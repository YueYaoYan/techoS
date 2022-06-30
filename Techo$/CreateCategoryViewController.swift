//
//  CreateCategoryViewController.swift
//  Techo$
//
//  Created by Yue Yan on 4/5/2022.
//

import UIKit

class CreateCategoryViewController: PhotoViewController {
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var pageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        imageView = categoryImageView
        scrollView = pageScrollView
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            
        categoryImageView.isUserInteractionEnabled = true
            
        categoryImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        takePhoto()
        
    }
    
    @IBAction func onAddCategoryClicked(_ sender: Any) {
        // check validity of fields
        guard let name = nameField.text, !name.isEmpty else{
            displayMessage(title: "Error", message: "Add a name to category!")
            return
        }
        
        indicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        Task{
            // add category and image to database
            guard let category = databaseController?.addCategory(name: name) else{
                self.view.isUserInteractionEnabled = true
                indicator.stopAnimating()
                displayMessage(title: "Error", message: "Category cannot be added!")
                return
            }
            if let image = await savePhoto() {
                databaseController?.addImageToCategory(image: image, category: category)
            }
            
            self.view.isUserInteractionEnabled = true
            indicator.stopAnimating()
            // pop navigation
            navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
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
