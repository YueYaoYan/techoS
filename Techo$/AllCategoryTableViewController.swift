//
//  AllCategoryTableViewController.swift
//  Techo$
//
//  Created by Yue Yan on 4/5/2022.
//

import UIKit

class AllCategoryTableViewController: UITableViewController, DatabaseListener {
    func onAllCategoriesChange(change: DatabaseChange, categories: [Category]) {
        allCategories = categories
        tableView.reloadData()
    }
    
    func onAllTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        
    }
    
    func onAllAccountsChange(change: DatabaseChange, accounts: [Account]) {
        
    }
    
    func onAllEventsChange(change: DatabaseChange, events: [Event]) {
        
    }
    
    func onAllGoalsChange(change: DatabaseChange, goals: [Goal]){
        
    }
    
    var listenerType = ListenerType.category
    weak var databaseController: DatabaseProtocol?
    
    var allCategories: [Category] = []
    let CELL_CATE = "categoryCell"
    let CELL_INFO = "infoCell"
    
    let SECTION_INFO = 0
    let SECTION_CATE = 1
    
    var addCategoryDelegate: AddCategoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialise datavase
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        setupNavigationBar()
        
        // set up tableView height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == SECTION_CATE){
            return allCategories.count
        }
        
        return 1
    }

    
    func getNullCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
        var content = cell.defaultContentConfiguration()
        if allCategories.count == 0{
            content.text = "Click \"+\" to add new category"
        }else{
            content.text = "There are currently \(allCategories.count) categories!"
        }
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_CATE{
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CATE, for: indexPath) as! CategoryTableViewCell
            let category = allCategories[indexPath.row]
            cell.categoryName.text = category.name
            guard let filename = category.image?.reference else{
                return cell
            }
            cell.categoryImage.image = loadImageData(filename: filename)
            cell.selectionStyle = .none
            return cell
        }
        return getNullCell(tableView, indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allCategories.count > 0{
            let category = allCategories[indexPath.row]
            
            // reassure with user if they would like to select this category
            let alert = UIAlertController(title: "Select Category", message: "Do you want to select \(String(describing: category.name!))", preferredStyle: UIAlertController.Style.alert)

            // if yes set add category to delegate
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.addCategoryDelegate?.addCategory(category: category)
                self.navigationController?.popViewController(animated: true)
            }))

            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                  return
            }))

            present(alert, animated: true, completion: nil)
        }
    }
}

class CategoryTableViewCell: UITableViewCell{
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    var category: Category?
}
