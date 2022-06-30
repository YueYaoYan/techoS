//
//  SearchTransactionTableViewController.swift
//  Techo$
//
//  Created by Yue Yan on 25/5/2022.
//

import UIKit

class SearchTransactionTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    @IBAction func filterAction(_ sender: Any) {
        let viewController = storyboard!.instantiateViewController(withIdentifier: "filterViewController") as! FilterViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else{
            return
        }
        let function = databaseController?.currentFilter ?? FilterGroup()
        transDictionary = function.group(transactions: self.allTransaction)
        
        if searchText.count > 0{
            let searchResult = function.search(searchText, transactions: self.allTransaction)
            filterDictionary = function.group(transactions: searchResult)
            transDates = Array(filterDictionary.keys)
            trans = Array(filterDictionary.values)
        }else{
            filterDictionary = transDictionary
            transDates = Array(filterDictionary.keys)
            trans = Array(filterDictionary.values)
        }
        tableView.reloadData()
    }
    
    func onAllCategoriesChange(change: DatabaseChange, categories: [Category]) {
        
    }
    
    func onAllTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        allTransaction = transactions
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func onAllAccountsChange(change: DatabaseChange, accounts: [Account]) {
        
    }
    
    func onAllEventsChange(change: DatabaseChange, events: [Event]) {
        
    }
    
    func onAllGoalsChange(change: DatabaseChange, goals: [Goal]){
        
    }
    
    var listenerType = ListenerType.transaction
    weak var databaseController: DatabaseProtocol?
    
    let SECTION_TRANS = 0
    
    let CELL_TRANSACTION = "transactionCell"
    
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
        
        let label = UILabel()
        label.textColor = UIColor(named: "Color")
        label.text = "Search Transaction"
        label.font = UIFont(name: "Futura-CondensedExtraBold", size: 20)
        let button =  UIBarButtonItem.init(customView: label)
        self.navigationItem.leftBarButtonItem = button
        
        // initiate search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Transactions"
        navigationItem.searchController = searchController
        searchController.showsSearchResultsController = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false

        setupNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return filterDictionary.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return trans[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return transDates[section]
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trans = filterTrans[indexPath.section][indexPath.row]
        let cell = Bundle(for: TransactionCardTableViewCell.self).loadNibNamed("TransactionCardTableViewCell", owner: self, options: nil)?.first as! TransactionCardTableViewCell
        cell.setLayout(accountName: trans.account!.name!, categoryName: trans.category!.name!, amount: trans.amount!, isSpending: trans.isSpending!, imageData: trans.image)

        return cell
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trans = filterTrans[indexPath.section][indexPath.row]
        self.databaseController?.selectedTransaction = trans
        let main = UIStoryboard(name: "Main", bundle: nil)
        let viewController = main.instantiateViewController(withIdentifier: "displayTransactionView") as! DisplayTransactionViewController
        navigationController?.pushViewController(viewController, animated: true)
    
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
