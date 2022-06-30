//
//  HomeViewController.swift
//  Techo$
//
//  Created by Yue Yan on 7/5/2022.
//

import UIKit
import SwiftUI
import Floaty

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener, TransactionFunctionDelegate, ChartDataDelegate {
    func lineChartSetUp() {
        
    }
    
    func filterSegue() {
        guard let storyboard = storyboard else {
            displayMessage(title: "Error", message: "Cannot navigate interface!")
            return
        }
        let viewController = storyboard.instantiateViewController(withIdentifier: "filterViewController") as! FilterViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func onAllCategoriesChange(change: DatabaseChange, categories: [Category]) {
        
    }
    
    func onAllTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        allTransaction = transactions
        transDictionary = [String: [Transaction]]()
        transDates = [String]()
        trans = [[Transaction]]()
        // sort transaction
        let function = databaseController?.currentFilter ?? FilterGroup()
        transDictionary = function.group(transactions: allTransaction)
        let filterTuple = function.sort(transactions: transDictionary, decending: false)
        for i in 0..<filterTuple.count {
            transDates.append( filterTuple[i].0)
            trans.append( filterTuple[i].1)
        }
        
        // set data
        self.setData(with: transDates, values: trans)
        tableView.reloadData()
    }
    
    func onAllAccountsChange(change: DatabaseChange, accounts: [Account]) {
        
    }
    
    func onAllEventsChange(change: DatabaseChange, events: [Event]) {
        
    }
    
    func onAllGoalsChange(change: DatabaseChange, goals: [Goal]){
        
    }
    func setData(with datas: [String], values: [[Transaction]]) {
        self.xData = datas
        self.yData = values
        
    }
    
    var chart: UIView?
    var listenerType = ListenerType.transaction
    weak var databaseController: DatabaseProtocol?
    
    let SECTION_REPORT = 0
    let SECTION_INFO = 1
    
    // identifiers for cells
    let CELL_REPORT = "reportCell"
    let CELL_INFO = "infoCell"
    
    var xData = [String]()
    var yData = [[Transaction]]()
    
    var allTransaction = [Transaction]()
    var transDictionary = [String: [Transaction]]()
    var transDates = [String]()
    var trans = [[Transaction]]()
    let floaty = Floaty()
    @IBOutlet weak var tableView: UITableView!
    
    @objc private func presentModal(_ sender: UISwipeGestureRecognizer?) {
        presentBottomSheet(withIdentifier: "transactionTableView")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initiate databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // initiate tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // initiate bottom sheet
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(presentModal(_:)))
        swipeGestureRecognizer.direction = .up
        
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = true
        tableView.addGestureRecognizer(swipeGestureRecognizer)
        
        loadFloaty()
        
    }
    
    func loadFloaty(){
        guard let storyboard = storyboard else {
            displayMessage(title: "Error", message: "Error in loading float button!")
            return
        }
        // initiate floaty
        floaty.addItem("Add Transaction", icon: UIImage(systemName: "creditcard"), handler: { [self] item in
            let viewController = storyboard.instantiateViewController(withIdentifier: "addTransactionView") as! CreateTransactionViewController
            navigationController?.pushViewController(viewController, animated: true)
            
            floaty.close()
        })
        floaty.addItem("Add to Goal", icon: UIImage(systemName: "flag"), handler: { [self] item in
            let viewController = storyboard.instantiateViewController(withIdentifier: "allGoals") as! AllGoalsTableViewController
            viewController.selectMode = true
            navigationController?.pushViewController(viewController, animated: true)
            floaty.close()
        })
        floaty.addItem("Add to Event", icon: UIImage(systemName: "heart"), handler: { [self] item in
            let viewController = storyboard.instantiateViewController(withIdentifier: "allEvents") as! AllEventsTableViewController
            viewController.selectMode = true
            navigationController?.pushViewController(viewController, animated: true)
            floaty.close()
        })
        
        floaty.paddingX = 10
        floaty.paddingY = 200
        floaty.buttonColor = UIColor(named: "Color") ?? UIColor.blue
        floaty.plusColor = UIColor(named: "colour2") ?? UIColor.white
        
        self.tableView.addSubview(floaty)
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

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_REPORT{
            let reportCell = tableView.dequeueReusableCell(withIdentifier: CELL_REPORT, for: indexPath) as! ReportTableViewCell
                            
            guard let chartHolder = reportCell.reportImageView else{
                displayMessage(title: "Error", message: "Error in loading Report!")
                fatalError()
            }
            self.chart?.removeFromSuperview()
            let chart = LineChart(frame:CGRect(x: 0.0, y: 0.0, width: chartHolder.frame.width, height: chartHolder.frame.height))
            chart.delegate = self
            chartHolder.addSubview(chart)
            self.chart = chart
            
            return reportCell
        }
        return tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
    }
}

class ReportTableViewCell: UITableViewCell{
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var TimeFrameButton: UIButton!
    @IBOutlet weak var reportImageView: UIImageView!
}

class TotalTableViewCell: UITableViewCell{
    @IBOutlet weak var totalSavingLabel: UILabel!
    @IBOutlet weak var totalField: UITextField!
}
