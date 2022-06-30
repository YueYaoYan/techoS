//
//  ReportGraphViewController.swift
//  Techo$
//
//  Created by Yue Yan on 25/5/2022.
//
/*
 These following tutorials and fourm discussion was accessed and assisted the completion of varies functions within this file:
 
    Code was used and moderate amount of modifications were done
    - https://medium.com/geekculture/swift-ios-charts-tutorial-highlight-selected-value-with-a-custom-marker-30ccbf92aa1b
    - https://www.appcoda.com/ios-charts-api-tutorial/
    - https://stackoverflow.com/questions/41197122/pie-chart-using-charts-library-with-swift
 */

import UIKit
import Charts

class ReportGraphViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, ChartViewDelegate, ChartDataDelegate, DatabaseListener {
    
    
    func onAllCategoriesChange(change: DatabaseChange, categories: [Category]) {
        
    }
    
    func onAllTransactionsChange(change: DatabaseChange, transactions: [Transaction]) {
        allTransaction = transactions
        transDictionary = [String: [Transaction]]()
        transDates = [String]()
        trans = [[Transaction]]()
        // sort transaction
        let function = databaseController?.currentFilter ?? FilterGroup()
        transDictionary = function.group(transactions: self.allTransaction)
        let filterTuple = function.sort(transactions: transDictionary, decending: false)
        for i in 0..<filterTuple.count {
            transDates.append( filterTuple[i].0)
            trans.append(filterTuple[i].1)
        }
        
        // set data
        self.setData(with: transDates, values: trans)
        
        // set up chart
        setupGraph(type: pickerView.selectedRow(inComponent: 0))
    }
    
    func onAllAccountsChange(change: DatabaseChange, accounts: [Account]) {
        
    }
    
    func onAllEventsChange(change: DatabaseChange, events: [Event]) {
        
    }
    
    func onAllGoalsChange(change: DatabaseChange, goals: [Goal]) {
        
    }
    
    func setData(with datas: [String], values: [[Transaction]]) {
        self.xData = datas
        self.yData = values
    }
    
    func lineChartSetUp() {
        chart?.removeFromSuperview()
        let chart = LineChart(frame:CGRect(x: 0.0, y: 0.0, width: chartHolder.frame.width, height: chartHolder.frame.height))
        chart.delegate = self
        chartHolder.addSubview(chart)
        self.chart = chart
    }
    
    func barChartSetUp(){
        chart?.removeFromSuperview()
        
        let chart = BarChart(frame:CGRect(x: 0.0, y: 0.0, width: chartHolder.frame.width, height: chartHolder.frame.height))
        chart.delegate = self
        chartHolder.addSubview(chart)
        self.chart = chart
    }
    
    func pieChartSetUp(isSpending: Bool){
        chart?.removeFromSuperview()
        let chart = PieChart(frame:CGRect(x: 0.0, y: 0.0, width: chartHolder.frame.width, height: chartHolder.frame.height))
        chart.setSpending(isSpending: isSpending)
        chart.delegate = self
        chartHolder.addSubview(chart)
        self.chart = chart
    }
    
    var chart: UIView?
    @IBOutlet weak var chartHolder: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerData = ["Income/Expense", "Transaction by date", "Income by Category", "Expense by Category"]
    let LINE = 0
    let BAR = 1
    let PIE_INCOME = 2
    let PIE_EXPENSE = 3
    
    var xData = [String]()
    var yData = [[Transaction]]()
    
    var listenerType = ListenerType.transaction
    var databaseController: DatabaseProtocol?
    
    var allTransaction = [Transaction]()
    var transDictionary = [String: [Transaction]]()
    var transDates = [String]()
    var trans = [[Transaction]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialise database
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Connect data:
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.tabBarController?.tabBar.isHidden = false
        
        // set data
        self.setData(with: transDates, values: trans)
        // set up chart
        setupGraph(type: pickerView.selectedRow(inComponent: 0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setupGraph(type: row)
    }
    
    func setupGraph(type: Int){
        switch(type){
        case LINE:
            lineChartSetUp()
        case BAR:
            barChartSetUp()
        case PIE_INCOME:
            pieChartSetUp(isSpending: false)
        case PIE_EXPENSE:
            pieChartSetUp(isSpending: true)
        default:
            print("error in picker selection")
        }
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
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
