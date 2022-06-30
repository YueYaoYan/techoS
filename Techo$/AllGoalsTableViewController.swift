//
//  AllGoalsTableViewController.swift
//  Techo$
//
//  Created by Yue Yan on 3/5/2022.
//

import UIKit

class AllGoalsTableViewController: UITableViewController,  DatabaseListener {
    func onAllCategoriesChange(change: DatabaseChange, categories: [Category]) {
        
    }
    
    func onAllTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        
    }
    
    func onAllAccountsChange(change: DatabaseChange, accounts: [Account]) {
        
    }
    
    func onAllEventsChange(change: DatabaseChange, events: [Event]) {
        
    }
    
    func onAllGoalsChange(change: DatabaseChange, goals: [Goal]){
        allGoals = goals
        tableView.reloadData()
    }
    
    var listenerType = ListenerType.savingGoal
    weak var databaseController: DatabaseProtocol?
    
    var allGoals: [Goal] = []
    var addGoalDelegate: AddGoalDelegate?
    var selectMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allGoals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let goal = allGoals[indexPath.row]
        let cell = Bundle(for: GoalCardTableViewCell.self).loadNibNamed("GoalCardTableViewCell", owner: self, options: nil)?.first as! GoalCardTableViewCell
        cell.setLayout(title: goal.name, date: goal.targetDate, remainingAmount: goal.remainingAmount, targetAmount: goal.targetAmount, imageData: goal.image)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goal = allGoals[indexPath.row]
        if !selectMode{
            databaseController?.selectedEvent = nil
            databaseController?.selectedAccount = nil
            self.databaseController?.selectedGoal = goal
            let main = UIStoryboard(name: "Main", bundle: nil)
            let viewController = main.instantiateViewController(withIdentifier: "displayTypeView") as! DisplayTypeTableViewController
            navigationController?.pushViewController(viewController, animated: true)
            
        }else if selectMode{
                let alert = UIAlertController(title: "Select Goal", message: "Do you want to select \(String(describing: goal.name!))", preferredStyle: UIAlertController.Style.alert)

                // if yes set add category to delegate
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action: UIAlertAction!) in
                    let viewController = storyboard!.instantiateViewController(withIdentifier: "addTransactionView") as! CreateTransactionViewController
                    viewController.goal = goal
                    navigationController?.pushViewController(viewController, animated: true)
                }))

                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                      return
                }))
            
            present(alert, animated: true, completion: nil)
        }
        else{
            addGoalDelegate?.addGoal(goal: goal)
            navigationController?.popViewController(animated: true)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
