//
//  AllTransactionTableViewControl.swift
//  Techo$
//
//  Created by Yue Yan on 24/5/2022.
//

import UIKit

class AllTransactionTableViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {
    
    // MARK: Properties
    let SECTION_TOTAL = 0
    let SECTION_TRANS = 1
    let SEC_OTHER = 1
    let CELL_TOTAL = "totalCell"
    let CELL_TRANSACTION = "transactionCell"
    
    // MARK: Properties for databse
    var listenerType = ListenerType.transaction
    weak var databaseController: DatabaseProtocol?
    
    // MARK: Properties for filter/search
    var allTransaction = [Transaction]()
    var transDictionary = [String: [Transaction]]()
    var filterDates = [String]()
    var filterTrans = [[Transaction]]()
    var filterDictionary = [String: [Transaction]]()
    var transDates = [String]()
    var trans = [[Transaction]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // customise navigation title
        let label = UILabel()
        label.textColor = UIColor(named: "Color")
        label.highlightedTextColor = UIColor(named: "Color")
        label.text = "Transactions"
        label.font = UIFont(name: "Futura-CondensedExtraBold", size: 24)
        let button =  UIBarButtonItem.init(customView: label)
        self.navigationItem.leftBarButtonItem = button
        
        // set up search bar
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Transactions"
        navigationItem.searchController = searchController
        
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
    
    // MARK: Database functions
    func onAllCategoriesChange(change: DatabaseChange, categories: [Category]) {
        
    }
    
    func onAllTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        allTransaction = transactions
        transDictionary = [String: [Transaction]]()
        filterDates = [String]()
        filterTrans = [[Transaction]]()
        filterDictionary = [String: [Transaction]]()
        transDates = [String]()
        trans = [[Transaction]]()
        guard let searcher = navigationItem.searchController else {
            displayMessage(title: "Error", message: "Cannot display search")
            return
        }
        updateSearchResults(for: searcher)
    }
    
    func onAllAccountsChange(change: DatabaseChange, accounts: [Account]) {
        
    }
    
    func onAllEventsChange(change: DatabaseChange, events: [Event]) {
        
    }
    
    func onAllGoalsChange(change: DatabaseChange, goals: [Goal]){
        
    }
    
    // MARK: Search result update
    func updateSearchResults(for searchController: UISearchController) {
        Task{
            await MainActor.run{
                guard let searchText = searchController.searchBar.text?.lowercased() else{
                    return
                }
                let function = databaseController?.currentFilter ?? FilterGroup()
                transDictionary = function.group(transactions: self.allTransaction)
                filterDictionary = transDictionary
                if searchText.count > 0{
                    let searchResult = function.search(searchText, transactions: self.allTransaction)
                    filterDictionary = function.group(transactions: searchResult)
                    
                }
                
                let filterTuple = function.sort(transactions: filterDictionary, decending: true)
                for i in 0..<filterTuple.count {
                    transDates.append( filterTuple[i].0)
                    trans.append(filterTuple[i].1)
                }
                tableView.reloadData()
            }
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return SEC_OTHER + filterDictionary.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section >= SECTION_TRANS{
            return trans[section-SEC_OTHER].count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section >= SECTION_TRANS{
            return transDates[section-SEC_OTHER]
        }
        return ""
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_TOTAL{
            let totalCell = tableView.dequeueReusableCell(withIdentifier: CELL_TOTAL, for: indexPath) as! TotalTableViewCell
            if trans.count > 0 {
                var sum = 0.00
                for trans in trans{
                    for tran in trans{
                        guard let val = tran.amount, let isSpending = tran.isSpending else {break}
                        if !isSpending{
                            sum += val
                        }else{
                            sum -= val
                        }
                    }
                }
                var sign = ""
                if sum < 0 {
                    sign = "-"
                }
                totalCell.totalField.text = "\(sign)$\(abs(round(sum*100)/100.0))"
            }else{
                totalCell.totalField.text = "$0.00"
            }
            totalCell.totalField.isUserInteractionEnabled = false
            
            
            return totalCell
        }else{
            let tran = trans[indexPath.section-SEC_OTHER][indexPath.row]
            let cell = Bundle(for: TransactionCardTableViewCell.self).loadNibNamed("TransactionCardTableViewCell", owner: self, options: nil)?.first as! TransactionCardTableViewCell
            cell.setLayout(accountName: tran.account?.name, categoryName: tran.category?.name, amount: tran.amount, isSpending: tran.isSpending, imageData: tran.image)

            return cell
        }
        
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section >= SECTION_TRANS{
            let trans = trans[indexPath.section-SEC_OTHER][indexPath.row]
            self.databaseController?.selectedTransaction = trans
            let main = UIStoryboard(name: "Main", bundle: nil)
            let viewController = main.instantiateViewController(withIdentifier: "displayTransactionView") as! DisplayTransactionViewController
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func filterAction(_ sender: Any) {
        guard let storyboard = storyboard else {
            displayMessage(title: "Error", message: "Cannot navigate interface!")
            return
        }
        let viewController = storyboard.instantiateViewController(withIdentifier: "filterViewController") as! FilterViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
}
    
