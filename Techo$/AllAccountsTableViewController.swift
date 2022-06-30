//
//  AllAccountsTableViewController.swift
//  Techo$
//
//  Created by Yue Yan on 3/5/2022.
//

import UIKit

class AllAccountsTableViewController: UITableViewController,  DatabaseListener {
    func onAllCategoriesChange(change: DatabaseChange, categories: [Category]) {
        
    }
    
    func onAllTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        
    }
    
    func onAllAccountsChange(change: DatabaseChange, accounts: [Account]) {
        allAccounts = accounts
        tableView.reloadData()
    }
    
    func onAllEventsChange(change: DatabaseChange, events: [Event]) {
        
    }
    
    func onAllGoalsChange(change: DatabaseChange, goals: [Goal]){
        
    }
    
    var listenerType = ListenerType.account
    weak var databaseController: DatabaseProtocol?
    
    var allAccounts: [Account] = []
    let CELL_ACCOUNT = "accountCell"
    
    var addAccountDelegate: AddAccountDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up database
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        if addAccountDelegate == nil{
            self.tabBarController?.tabBar.isHidden = false
        }
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
        return allAccounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account = allAccounts[indexPath.row]
        let cell = Bundle(for: AccountCardTableViewCell.self).loadNibNamed("AccountCardTableViewCell", owner: self, options: nil)?.first as! AccountCardTableViewCell
        cell.setLayout(name: account.name, number: account.number, availableAmount: account.availableCredit, totalAmount: account.totalSaving)

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard allAccounts.count >= indexPath.row + 1 else {return}
        let account = allAccounts[indexPath.row]
        if addAccountDelegate == nil{
            databaseController?.selectedEvent = nil
            databaseController?.selectedGoal = nil
            self.databaseController?.selectedAccount = account
            let main = UIStoryboard(name: "Main", bundle: nil)
            let viewController = main.instantiateViewController(withIdentifier: "displayTypeView") as! DisplayTypeTableViewController
            navigationController?.pushViewController(viewController, animated: true)
        }else{
            addAccountDelegate?.addAccount(account: account)
            navigationController?.popViewController(animated: true)
        }
    }
}


