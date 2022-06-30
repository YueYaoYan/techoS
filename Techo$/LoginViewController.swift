//
//  LoginViewController.swift
//  Techo$
//
//  Created by Yue Yan on 27/4/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, AuthListener {
    func onAuthenticationChange(change: DatabaseChange, user: FirebaseAuth.User?){
        if change == .success{
            // navigate to tab bar
            databaseController?.authorizedUserLogin(user: user)
            // (Note other rootViewController methods are modification or reuse of this one) Reference code was used from: https://stackoverflow.com/questions/33374272/how-to-set-a-new-root-view-controller
            guard let storyboard = storyboard else {
                displayMessage(title: "Error", message: "Cannot navigate to main interface!")
                return
            }
            let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarcontroller") as! UITabBarController
            UIApplication.shared.windows.first?.rootViewController = viewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
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
        emailField.text = ""
        passwordField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        authController?.removeListener(listener: self)
    }
    
    @IBAction func onLoginClicked(_ sender: Any) {
        if validFields(){
            let email = emailField.text!
            let password = passwordField.text!
            Task{
                let error = await authController?.loginUser(email: email, password: password)
                if error != ""{
                    displayMessage(title: "Error", message: error!)
                }
            }
        }
    }
    
    @IBAction func onSignupClicked(_ sender: Any) {
        if validFields(){
            guard let email = emailField.text, let password = passwordField.text else {
                displayMessage(title: "Error", message: "Invalid input!")
                return
                
            }
            Task{
                let error = await authController?.signupUser(email: email, password: password)
                if error != nil && error != ""{
                    displayMessage(title: "Error", message: error!)
                }else{
                    guard let user = authController?.currentUser else{
                        return
                    }
                    let _ = databaseController?.addUser(uid: user.uid)
                }
            }
            
        }
    }
    
    func validFields() -> Bool{
        if !fieldNotEmpty(emailField) || !fieldNotEmpty(passwordField){
            var msg = "Please check the followings:"
            
            if !fieldNotEmpty(emailField){
                msg += "\n-Please enter your email address!"
            }
            
            if !fieldNotEmpty(passwordField){
                msg += "\n-Please enter your password!"
            }
            
            displayMessage(title: "Invalid signup", message: msg)
            return false
        }
        return true
    }
    
    func fieldNotEmpty(_ textfield: UITextField) -> Bool{
        return textfield.text != nil && textfield.text != ""
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
