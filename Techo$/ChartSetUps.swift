//
//  LineChart.swift
//  Techo$
//
//  Created by Yue Yan on 2/6/2022.
//

import UIKit
import Charts

class ReportChartView: UIView {
    
    func chartConstraintSetup(chartView: ChartViewBase){
        // set constraints
        self.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        chartView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        chartView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        chartView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
}

class LineChart: ReportChartView, ChartViewDelegate {
    
    var xData = [String]()
    var yData = [[Transaction]]()
    let chartView = LineChartView()
    let markerView = ReportMarkerView()
    var values = [[Double]]()
    let chartData = LineChartData()
    
    var delegate: ChartDataDelegate!{
        didSet{
            populateData()
            chartSetup()
            setupMarker()
        }
    }
    
    func populateData(){
        self.xData = delegate.xData
        self.yData = delegate.yData
    }
    
    func setupMarker(){
        markerView.chartView = chartView
        chartView.marker = markerView
    }
    
    
    func chartSetup(){
        // set constraints
        chartConstraintSetup(chartView: chartView)
        chartView.delegate = self
        
        // line chart animation
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInCubic)
        
        // line chart population
        values = sortData(datas: yData)
        setLineChart(datas: xData, values: values)
    }
    
    func sortData(datas: [[Transaction]]) -> [[Double]]{
        var sortData: [[Double]] = []
        for i in 0..<datas.count{
            var pos = 0.0
            var neg = 0.0
            for tran in datas[i]{
                if tran.isSpending!{
                    neg += tran.amount!
                }else{
                    pos += tran.amount!
                }
            }
            sortData.append([])
            sortData[i].append(pos)
            sortData[i].append(neg)
        }
        return sortData
    }
    
    func setChartDataSet(lineDataEntry: [ChartDataEntry], entryType: String){
        let chartDataSet = LineChartDataSet(entries: lineDataEntry, label: entryType)
        chartDataSet.highlightColor = UIColor.clear
        chartDataSet.colors = [UIColor(named: entryType+"Color")!]
        chartDataSet.circleRadius = 0.0
        // gradient
        let gradientColors = [UIColor(named: entryType+"Color")!.cgColor, UIColor.clear.cgColor] as CFArray
        let colorLocations: [CGFloat] = [1.0, 0.0]
        guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        else{
            print("gradient error")
            return
        }
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        chartDataSet.drawFilledEnabled = true
        chartDataSet.lineDashLengths = [3, 5]
        chartData.addDataSet(chartDataSet)
    }
    
    func finaliseChartSetup(chartData: ChartData) {
        chartData.setDrawValues(false)
        chartView.xAxis.drawLabelsEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.legend.textColor = UIColor(named: "Color")!
        
        // add data to chart
        chartView.data = chartData
    }
    
    func setLineChart(datas: [String], values: [[Double]]){
        var incomeEntries : [ChartDataEntry] = []
        var expenseEntries : [ChartDataEntry] = []
        
        // set up datas
        for i in 0..<values.count{
            let data1 = ChartDataEntry(x: Double(i), y: values[i][0], icon: UIImage(systemName: "plus")?.withTintColor(UIColor(named: "IncomeColor")!))
            let data2 = ChartDataEntry(x: Double(i), y: values[i][1], icon: UIImage(systemName: "minus")?.withTintColor(UIColor(named: "ExpenseColor")!))
            incomeEntries.append(data1)
            expenseEntries.append(data2)
        }
        
        setChartDataSet(lineDataEntry: incomeEntries, entryType: "Income")
        setChartDataSet(lineDataEntry: expenseEntries, entryType: "Expense")
        
        finaliseChartSetup(chartData: chartData)
    }
    
    // MARK: - Chart Methods
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] else { return }
        let dataIndex = highlight.dataSetIndex
        let entryIndex = dataSet.entryIndex(entry: entry)
        if entryIndex < dataSet.entryCount/2 {
            markerView.setData(amount: values[entryIndex][dataIndex], date: xData[entryIndex], type:  0)
        }else{
            markerView.setData(amount: values[entryIndex][dataIndex], date: xData[entryIndex], type: 2)
        }

    }

}

class BarChart: ReportChartView, ChartViewDelegate {
    var xData = [String]()
    var yData = [[Transaction]]()
    let chartView = BarChartView()
    let markerView = ReportMarkerView()
    var dataEntry : [BarChartDataEntry] = []
    var values = [Double]()
    
    var delegate: ChartDataDelegate!{
        didSet{
            populateData()
            chartSetUp()
        }
    }
    
    func populateData(){
        self.xData = delegate.xData
        self.yData = delegate.yData
    }
    
    func chartSetUp(){
        // set constraints
        chartConstraintSetup(chartView: chartView)
        chartView.delegate = self
        
        // chart animation
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
        // chart population
        values = sortData(datas: yData)
        setChart(datas: xData, values: values)
        setupMarker()
    }
    
    func setupMarker(){
        markerView.chartView = chartView
        chartView.marker = markerView
    }
    
    func sortData(datas: [[Transaction]]) -> [Double]{
        var wa: [Double] = []
        for i in 0..<datas.count{
            var pos = 0.0
            var neg = 0.0
            for tran in datas[i]{
                if tran.isSpending!{
                    neg += tran.amount!
                }else{
                    pos += tran.amount!
                }
            }
            wa.append(pos-neg)
        }
        return wa
    }
    
    func finaliseChartSetup(chartData: BarChartData) {
        chartData.setDrawValues(false)
        chartView.xAxis.drawLabelsEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.legend.textColor = UIColor(named: "Color")!
        
        // add data to chart
        chartView.data = chartData
        chartView.legend.enabled = false
    }
    
    func setChart(datas: [String], values: [Double]){
        // set up data points
        for i in 0..<values.count{
            let data = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntry.append(data)
        }
        
        // add dataset and customise
        let chartDataSet = BarChartDataSet(entries: dataEntry, label: nil)
        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        chartDataSet.colors = [UIColor(named: "Color")!]
        
        // set up axes
        finaliseChartSetup(chartData: chartData)
    }
    
    // MARK: - Chart Methods
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] else { return }
        let entryIndex = dataSet.entryIndex(entry: entry)
        
        markerView.setData(amount: values[entryIndex], date: xData[entryIndex], type: 1)

    }
}

class PieChart: ReportChartView {
    class ChartValueFormatter: NSObject, IValueFormatter {
        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            let formatter = NumberFormatter()
            formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
            formatter.numberStyle = .currency
            
            return formatter.string(for: value) ?? "$0.00"
        }
    }
    
    var xData = [String]()
    var yData = [[Transaction]]()
    let chartView = PieChartView()
    var dataEntry : [PieChartDataEntry] = []
    var categories = [String]()
    var dataIsSpending = true
    var total : Double = 0.0
    
    var delegate: ChartDataDelegate!{
        didSet{
            populateData()
            chartSetUp()
        }
    }
    
    func setSpending(isSpending: Bool){
        self.dataIsSpending = isSpending
    }
    
    func populateData(){
        self.xData = delegate.xData
        self.yData = delegate.yData
    }
    
    func chartSetUp(){
        // set constraints
        chartConstraintSetup(chartView: chartView)
        // and property
        chartView.holeColor = UIColor.clear
        chartView.highlightPerTapEnabled = false
        
        // chart animation
        chartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
        // chart population
        let values = sortData(datas: yData)
        setChart(values: values)
    }
    
    func sortData(datas: [[Transaction]]) -> [Double] {
        var dictionary: [String: Double] = [:]
        
        for i in 0..<datas.count{
            for tran in datas[i]{
                let cate = tran.category!.name!
                if tran.isSpending == self.dataIsSpending{
                    guard let amount = tran.amount else{break}
                    total += amount
                    if dictionary[cate] == nil{
                        dictionary[cate] = amount
                    }
                    dictionary[cate] = dictionary[cate]! + amount
                }
            }
        }
        categories = Array(dictionary.keys)
        return Array(dictionary.values)
    }
    
    func setChart(values: [Double]){
        // set up data points
        //// set random colour for chart
        var colors: [UIColor] = []
        
        for i in 0..<categories.count{
            let color = getRandomColor()
            colors.append(color)
            let data = PieChartDataEntry(value: values[i], label: categories[i], data: categories[i])
            dataEntry.append(data)
        }
        
        let chartDataSet = PieChartDataSet(entries: dataEntry, label: nil)
        let chartData = PieChartData()
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(true)
        chartDataSet.colors = colors
        chartDataSet.sliceSpace = 2
        chartDataSet.yValuePosition = .outsideSlice
        chartDataSet.xValuePosition = .outsideSlice
        chartDataSet.valueLineColor = UIColor(named: "Color") ?? UIColor.white
        chartDataSet.valueTextColor = UIColor(named: "Color") ?? UIColor.white
        chartDataSet.valueFormatter = ChartValueFormatter()
        
        // set legend
        let legend = chartView.legend
        legend.verticalAlignment = .top
        legend.horizontalAlignment = .right
        legend.orientation = .vertical
        legend.textColor = UIColor(named: "Color") ?? UIColor.white
        legend.yOffset = 20
        
        // Set center text
        var centerText = AttributedString("Total: \(total.formatCurrency())")
        centerText.font = UIFont(name: "Futura-CondensedExtraBold", size: 16)
        centerText.foregroundColor = UIColor(named: "Color") ?? UIColor.white
        chartView.centerAttributedText = NSAttributedString(centerText)
        
        chartView.data = chartData
    }
    
    func getRandomColor() -> UIColor{
        let red = Double(arc4random_uniform(256))
        let green = Double(arc4random_uniform(256))
        let blue = Double(arc4random_uniform(256))

        return UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
    }

}

protocol ChartDataDelegate{
    var xData: [String] {get set}
    var yData: [[Transaction]] {get set}
    
    func setData(with datas: [String], values: [[Transaction]])
    func lineChartSetUp()
}
