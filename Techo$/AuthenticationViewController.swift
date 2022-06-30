//
//  AuthenticationViewController.swift
//  FIT3178-W02-Lab
//
//  Created by Yue Yan on 9/4/2022.
//

import UIKit

class AuthenticationViewController: UIViewController, DatabaseListener  {
    var listenerType = ListenerType.auth
    
    func onTeamChange(change: DatabaseChange, teamHeroes: [Superhero]) {
        // do nothing
    }
    
    func onAllHeroesChange(change: DatabaseChange, heroes: [Superhero]) {
        // do nothing
    }
    
    func onAuthenticationChange(change: DatabaseChange) {
        if change == .success{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let home  = storyBoard.instantiateViewController(withIdentifier: "CurrentPartyTableViewController") as! CurrentPartyTableViewController
            self.navigationController?.pushViewController(home, animated: true)
        }else if change == .fail{
            displayMessage(title: "Error", message: "Your username or password is incorrect!")
        }
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    @IBAction func signUpUser(_ sender: Any) {
        if validFields(){
            let email = emailTextField.text!
            let password = passwordTextField.text!
            databaseController?.signupUser(email: email, password: password)
        }
    }
    @IBAction func loginUser(_ sender: Any) {
        if validFields(){
            let email = emailTextField.text!
            let password = passwordTextField.text!
            databaseController?.loginUser(email: email, password: password)
        }
    }
    
    func validFields() -> Bool{
        let email = emailTextField.text!
        if !fieldNotEmpty(emailTextField) || !validEmail(email) || !fieldNotEmpty(passwordTextField){
            var msg = "Please check the followings:"
            
            if !fieldNotEmpty(emailTextField){
                msg += "\n-Please enter your email address!"
            }else if !validEmail(email){
                msg += "\n-Please check if you have entered a valid email!"
            }
            
            if !fieldNotEmpty(passwordTextField){
                msg += "\n-Please enter your password!"
            }
            
            displayMessage(title: "Invalid signup", message: msg)
            return false
        }
        return true
    }
    
    func fieldNotEmpty(_ textfield: UITextField) -> Bool{
        return textfield.text! != ""
    }
    
    func validEmail(_ email: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
}
