//
//  UIViewController.swift
//  Techo$
//
//  Created by Yue Yan on 27/4/2022.
//

import UIKit

extension UIViewController {
    /**
        Presents Bottom sheet with view controller with the given identifier.
        From: https://sarunw.com/posts/bottom-sheet-in-ios-15-with-uisheetpresentationcontroller/
     */
    func presentBottomSheet(withIdentifier viewControllerID: String){
        guard let storyboard = storyboard else {
            displayMessage(title: "Error", message: "Cannot navigate interface!")
            return
        }
        let controller = storyboard.instantiateViewController(withIdentifier: viewControllerID)
        let nav = UINavigationController(rootViewController: controller)
        
        nav.modalPresentationStyle = .pageSheet
        
        if let sheet = nav.sheetPresentationController {
            
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .large
            sheet.prefersGrabberVisible = true
        }
        
        present(nav, animated: true, completion: nil)
    }
    
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
    
    /**
        Allows text to be converted into double
        Inspired by: https://www.codegrepper.com/code-examples/swift/swift+convert+any+to+decimal
     */
    func stripToDouble(text: String) -> Double?{
        let savedValues = UserDefaults.standard
        
        let double = Set("0123456789.")
        let doubleString = String( text.filter{double.contains($0)} )

        savedValues.set(doubleString, forKey:"jitterClickCost")
        savedValues.synchronize()

        let value = savedValues.string(forKey: "jitterClickCost") ?? "0"
        
        return Double(value)
    }
    
    @objc func amountFieldDidChange(_ textField: UITextField) {

        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    func setupNavigationBar(){
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
}

extension NSObject{
    func loadImageData(filename: String?) -> UIImage? {
        guard filename != nil else {return nil}
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imageURL = documentsDirectory.appendingPathComponent(filename!)
        let image = UIImage(contentsOfFile: imageURL.path)
        
        return image
    }
}

extension String {
    /**
     Formatting text for currency textField
     From: https://stackoverflow.com/questions/29782982/how-to-input-currency-format-on-a-text-field-from-right-to-left-using-swift
     */
    func currencyInputFormatting() -> String {
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
    
        var amountWithPrefix = self
    
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
    
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
    
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
    
        return formatter.string(from: number)!
    }
}

extension Double{
    /**
        Formats double into currency string
        From: https://stackoverflow.com/questions/69926005/wrong-behaviour-on-formatting-decimal
     */
    func formatCurrency() -> String{
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.numberStyle = .currency
        if let formattedTipAmount = formatter.string(from: self as NSNumber) {
            return "\(formattedTipAmount)"
        }
        return "$0.00"
    }
}

extension UITableViewController {
    func displayAddMessage(_ type: String){
        displayMessage(title: "Hint", message: "Click + to add new  \(type)")
    }
    
    func getInfoCell(_ type: String) -> UITableViewCell{
        let cell = Bundle(for: InfoTableViewCell.self).loadNibNamed("InfoTableViewCell", owner: self, options: nil)?.first as! InfoTableViewCell
        cell.setLayout(type)

        return cell
    }
}
