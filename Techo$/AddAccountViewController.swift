//
//  AddAccountViewController.swift
//  Techo$
//
//  Created by Yue Yan on 3/5/2022.
//

import UIKit
import CoreData

class AddAccountViewController: PhotoViewController {
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var totalField: UITextField!
    
    @IBOutlet weak var accountNumberField: UITextField!
    @IBOutlet weak var accountNameField: UITextField!
    @IBOutlet weak var pageScrollView: UIScrollView!
    
    @IBAction func onAddAccountClicked(_ sender: Any) {
        guard let total = totalField.text, let accountNumber = accountNumberField.text, let accountName = accountNameField.text else{
            return
        }
        
        if total.isEmpty || (accountName.isEmpty && accountNumber.isEmpty) {
            var errorMsg = "Please ensure all fields are filled:\n"
            if total.isEmpty {
                errorMsg += "- Must provide a total\n" }
            if accountName.isEmpty && accountNumber.isEmpty {
                errorMsg += "- Must provide a name or a number"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }

        guard let totalDouble = stripToDouble(text:total) else {
            displayMessage(title: "Error", message: "Error in creation!")
            return
            
        }
        Task{
            // create account and save image if image is not nil
            guard let account = databaseController?.addAccount(name: accountName, totalSaving: totalDouble, number: accountNumber), let image = await savePhoto() else{
                navigationController?.popViewController(animated: true)
                return
            }
            
            databaseController?.addImageToAccount(image: image, account: account)
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
        
        imageView = cardImageView
        scrollView = pageScrollView
        totalField.addTarget(self, action: #selector(totalFieldDidChange(_:)), for: .editingChanged)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            
        cardImageView.isUserInteractionEnabled = true
        cardImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        takePhoto()
    }
    
    @objc func totalFieldDidChange(_ textField: UITextField) {

        if let totalString = totalField.text?.currencyInputFormatting() {
            totalField.text = totalString
        }
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
