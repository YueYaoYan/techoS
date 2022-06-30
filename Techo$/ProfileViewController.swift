//
//  ProfileViewController.swift
//  Techo$
//
//  Created by Yue Yan on 17/5/2022.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, AuthListener {
    func onAuthenticationChange(change: DatabaseChange, user: FirebaseAuth.User?) {
        if change == .success{
            let username = authController?.currentUser?.displayName
            usernameField.placeholder = username
            usernameField.text = username
            let email = authController?.currentUser?.email
            emailField.placeholder = email
            emailField.text = email
        }
    }
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var authController: AuthenticationController?
    var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        authController = appDelegate?.authController
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authController?.removeListener(listener: self)
    }
    
    @IBAction func updateInfo(_ sender: Any) {
        if emailField.text != emailField.placeholder || usernameField.text != usernameField.placeholder || passwordField.text != ""{
            Task {
                var successMsg = ""
                var errorMsg = ""
                
                // attempts to update details, get error message if unsuccessful
                if emailField.text != emailField.placeholder{
                let error = await authController!.updateEmail(email: emailField.text!)
                    if error == ""{
                        successMsg += "Email is successfully updated"
                        emailField.placeholder = emailField.text
                        
                    }else{
                        errorMsg += error
                        
                    }
                }
                if usernameField.text != usernameField.placeholder{
                    let error = await authController!.updateUsername(username: usernameField.text!)
                    if error == ""{
                        successMsg += "\nUsername is successfully updated"
                        usernameField.placeholder = usernameField.text
                    }else{
                        errorMsg += error
                    }
                    
                }
                if passwordField.text != ""{
                    let error = await authController!.updatePassword(newPassword: passwordField.text!)
                    if error == ""{
                        successMsg += "\nPassword is successfully updated"
                        passwordField.text = ""
                    }else{
                        errorMsg += error
                    }
                }
                displayMessage(title: "Updates", message: successMsg+"\n"+errorMsg)
            }
        }
        
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            // log out user
            Task{
                
                self.databaseController?.logout()
                let error = await self.authController?.signoutUser()
                if error != ""{
                    self.displayMessage(title: "Error", message: error!)
                }
                
            }
            // return to login view
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
            UIApplication.shared.windows.first?.rootViewController = viewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()            
        }))

        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
              return
        }))

        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This is a permanent action and cannot be reverted!", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            // log out user
            Task{
                self.databaseController?.deleteUser()
                
                let error = await self.authController?.deleteUser()
                if error != ""{
                    self.displayMessage(title: "Error", message: error!)
                    let signoutError = await self.authController?.signoutUser()
                    if signoutError != ""{
                        self.displayMessage(title: "Error", message: error!)
                        return
                    }
                }
                
                // return to login view
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "login") as! LoginViewController
                UIApplication.shared.windows.first?.rootViewController = viewController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }))

        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
              return
        }))

        present(alert, animated: true, completion: nil)
    }
}
