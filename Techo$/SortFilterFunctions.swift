//
//  SortFilterFunctions.swift
//  Techo$
//
//  Created by Yue Yan on 10/5/2022.
//

import Foundation

class FilterGroup{
    var toDate: Date?
    var fromDate: Date?
    var toAmount: Double?
    var fromAmount: Double?
    var category: Category?
    var searchWord: String?
    
    let dateformatter = DateFormatter()
    
    init(category: Category? = nil, toDate: Date? = nil, fromDate: Date? = nil, toAmount: Double? = nil, fromAmount: Double? = nil){
        dateformatter.dateFormat = "MMM d, yyyy"
        self.toDate = toDate
        self.toAmount = toAmount
        self.fromDate = fromDate
        self.fromAmount = fromAmount
        self.category = category
    }
    
    func search(_ text: String, transactions: [Transaction]) -> [Transaction]{
        return transactions.filter({(trans: Transaction) -> Bool in
            return (trans.note?.lowercased().contains(text) ?? false) || (trans.category?.name?.lowercased().contains(text) ?? false) || (trans.location?.name?.lowercased().contains(text) ?? false) ||
                (String(describing: trans.amount!).contains(text))})
    }
    func group(transactions: [Transaction]) -> [String: [Transaction]]{
        var dictionary: [String: [Transaction]] = [:]
        
        for transaction in transactions {
            if filter(transaction: transaction){
                let date = String(describing: dateformatter.string(from: transaction.date!))
                if dictionary[date] == nil{
                    dictionary[date] = []
                }
                dictionary[date]!.append(transaction)
            }
        }
        return dictionary
    }
    
    func filter(transaction: Transaction) -> Bool{
        guard let amount = transaction.amount, let date = transaction.date else {return false}
        if toAmount != nil{
            if amount > toAmount!{
                return false
            }
        }
        if fromAmount != nil{
            if amount  < fromAmount!{
                return false
            }
        }
        if toDate != nil{
            // remove date after to date
            if date > toDate!{
                return false
            }
        }
        if fromDate != nil{
            // remove date before from date
            if date < fromDate!{
                return false
            }
        }
        return true
    }
    
    func sort(transactions: [String: [Transaction]], decending: Bool) -> [(String, [Transaction])]{
        var newArr = transactions.map{ $0 }
        
        if decending{
            newArr  = newArr.sorted {dateformatter.date(from: $0.0)! > dateformatter.date(from: $1.0)!}
        }else{
            newArr  = newArr.sorted {dateformatter.date(from: $0.0)! < dateformatter.date(from: $1.0)!}
        }
        return newArr
    }
}

