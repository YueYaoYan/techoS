//
//  DatabaseProtocol.swift
//  Techo$
//
//  Created by Yue Yan on 27/4/2022.
//

import Foundation
import FirebaseAuth

enum DatabaseChange {
    case add
    case remove
    case update
    case success
    case fail
}

enum ListenerType{
    case category
    case transaction
    case account
    case event
    case savingGoal
    case auth
    case location
    case all
}

protocol AuthListener: AnyObject{
    func onAuthenticationChange(change: DatabaseChange, user: FirebaseAuth.User?)
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType{get set}
    
    func onAllCategoriesChange(change: DatabaseChange, categories: [Category])
    func onAllTransactionsChange(change: DatabaseChange, transactions: [Transaction])
    func onAllAccountsChange(change: DatabaseChange, accounts: [Account])
    func onAllEventsChange(change: DatabaseChange, events: [Event])
    func onAllGoalsChange(change: DatabaseChange, goals: [Goal])
}

protocol DatabaseProtocol: AnyObject {
    var selectedTransaction: Transaction? {get set}
    var selectedAccount: Account? {get set}
    var selectedEvent: Event? {get set}
    var selectedGoal: Goal? {get set}
    var currentFilter: FilterGroup? {get set}
    
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func getSelectedTypeTransaction() -> [Transaction]?
    
    
    func addUser(uid: String) -> User
    func deleteUser()
    func logout()
    func authorizedUserLogin(user: FirebaseAuth.User?)
    
    func addAccount(name: String?, totalSaving: Double, number: String?) -> Account
    func deleteAccount(account: Account)
    
    func addEvent(endDate: Date, startDate: Date, name: String) -> Event
    func deleteEvent(event: Event)
    
    func addGoal(name: String, targetDate: Date?, targetAmount: Double, regularity: Int32) -> Goal
    func deleteGoal(goal: Goal)
    func fetchGoalByID(_ id: String) -> Goal?
    
    func addLocation(name: String, address: String, lat: Double, lon: Double) -> Location
    func addLocationToTransaction(location: Location, transaction: Transaction)
    
    func addCategory(name: String) -> Category
    func addCategoryToTransaction(category: Category, transaction: Transaction)
    
    func uploadImages(filename: String) async -> ImageMetaData?
    func addImage(imgReference: String, url: String) -> ImageMetaData
    func deleteImage(image: ImageMetaData)
    func addImageToCategory(image: ImageMetaData, category: Category)
    func addImageToAccount(image: ImageMetaData, account: Account)
    func addImageToEvent(image: ImageMetaData, event: Event)
    func addImageToGoal(image: ImageMetaData, goal: Goal)
    func addImageToTransaction(image: ImageMetaData, transaction: Transaction)
    
    func addTransaction(amount: Double, date: Date, isSpending: Bool, note: String) -> Transaction
    func deleteTransaction(transaction: Transaction)
    func addTransToAccount(transaction: Transaction, account: Account)
    func addTransToEvent(transaction: Transaction, event: Event)
    func addTransToGoal(transaction: Transaction, goal: Goal) -> Bool
}
