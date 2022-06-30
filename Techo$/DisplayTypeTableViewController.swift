//
//  AboutAccountTableViewController.swift
//  Techo$
//
//  Created by Yue Yan on 10/5/2022.
//

import UIKit

class DisplayTypeTableViewController: UITableViewController {
    func filterSegue() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        let viewController = main.instantiateViewController(withIdentifier: "filterViewController") as! FilterViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func searchClicked(_ sender: Any) {
        presentModal(nil)
    }
    
    @IBAction func moreActions(_ sender: Any) {
        let alert = UIAlertController(title: "Select Action", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default , handler:{ [self] (UIAlertAction) in
            
            if let account = self.databaseController?.selectedAccount{
                databaseController?.deleteAccount(account: account)
            }
            
            if let event = self.databaseController?.selectedEvent{
                databaseController?.deleteEvent(event: event)
            }
            if let goal = self.databaseController?.selectedGoal{
                databaseController?.deleteGoal(goal: goal)
            }
            navigationController?.popViewController(animated: true)
        }))
            
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))


        self.present(alert, animated: true, completion: nil)
    }
    
    let SECTION_ACCOUNT = 0
    let SECTION_TRANS = 1
    
    // identifiers for cells
    let CELL_ACCOUNT = "accountCell"
    let CELL_TRANSACTION = "transactionCell"
    
    var accountTransactions = [Transaction]()
    var transDictionary = [String: [Transaction]]()
    var filterDates = [String]()
    var filterTransactions = [[Transaction]]()
    
    weak var databaseController: DatabaseProtocol?
    
    @objc private func presentModal(_ sender: UISwipeGestureRecognizer?) {
        presentBottomSheet(withIdentifier: "searchTransactions")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialise database
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let transactions = databaseController?.getSelectedTypeTransaction() else{
            displayMessage(title: "Error", message: "Selection unavailable")
            navigationController?.popViewController(animated: true)
            return
        }
        
        let function = databaseController?.currentFilter ?? FilterGroup()
        transDictionary = function.group(transactions: transactions)
        let filterTuple = function.sort(transactions: transDictionary, decending: true)
        for i in 0..<filterTuple.count {
            filterDates.append( filterTuple[i].0)
            filterTransactions.append(filterTuple[i].1)
        }
        
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1 + filterDates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section >= SECTION_TRANS{
            return filterTransactions[section-1].count
        }
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_ACCOUNT{
            let account = self.databaseController?.selectedAccount
            if account != nil{
                return createAccountCell(account: account!)
            }
            let event = self.databaseController?.selectedEvent
            if event != nil{
                return createEventCell(event: event!)
            }
            let goal = self.databaseController?.selectedGoal
            return createGoalCell(goal: goal!)
            
        }
        let trans = filterTransactions[indexPath.section-1][indexPath.row]
        let cell = Bundle(for: TransactionCardTableViewCell.self).loadNibNamed("TransactionCardTableViewCell", owner: self, options: nil)?.first as! TransactionCardTableViewCell
        cell.setLayout(accountName: trans.account?.name, categoryName: trans.category?.name, amount: trans.amount, isSpending: trans.isSpending, imageData: trans.image)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section >= SECTION_TRANS{
            return filterDates[section-1]
        }
        return nil
    }
    
    func createAccountCell(account: Account) -> AccountCardTableViewCell{
        let cell = Bundle(for: AccountCardTableViewCell.self).loadNibNamed("AccountCardTableViewCell", owner: self, options: nil)?.first as! AccountCardTableViewCell
        cell.setLayout(name: account.name, number: account.number, availableAmount: account.availableCredit, totalAmount: account.totalSaving)

        return cell
    }
    
    func createEventCell(event: Event) -> EventCardTableViewCell{
        let cell = Bundle(for: EventCardTableViewCell.self).loadNibNamed("EventCardTableViewCell", owner: self, options: nil)?.first as! EventCardTableViewCell
        cell.setLayout(title: event.name, startDate: event.startDate, endDate: event.endDate, totalAmount:  event.totalSpending, imageData: event.image)

        return cell
    }
    
    func createGoalCell(goal: Goal) -> GoalCardTableViewCell{
        let cell = Bundle(for: GoalCardTableViewCell.self).loadNibNamed("GoalCardTableViewCell", owner: self, options: nil)?.first as! GoalCardTableViewCell
        cell.setLayout(title: goal.name!, date: goal.targetDate!, remainingAmount: goal.remainingAmount!, targetAmount: goal.targetAmount!, imageData: goal.image)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section >= SECTION_TRANS{
            let trans = filterTransactions[indexPath.section-1][indexPath.row]
            self.databaseController?.selectedTransaction = trans
            presentBottomSheet(withIdentifier: "displayTransactionView")
        }
    }
}
