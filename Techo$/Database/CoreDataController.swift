//
//  CoreDataController.swift
//  Techo$
//
//  Created by Yue Yan on 27/4/2022.
//

import Foundation
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    func getSelectedTypeTransaction() -> [Transaction]? {
        if selectedGoal != nil{
            return selectedGoal!.transactions?.allObjects as? [Transaction]
        }else if selectedAccount != nil{
            return selectedAccount!.transactions?.allObjects as? [Transaction]
        }else if selectedEvent != nil{
            return selectedEvent!.transactions?.allObjects as? [Transaction]
        }
        return nil
    }
    
    var persistentContainer: NSPersistentContainer
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var allTransactionsFetchedResultsController: NSFetchedResultsController<Transaction>?
    var allAccountsFetchedResultsController: NSFetchedResultsController<Account>?
    var allCategoriesFetchedResultsController: NSFetchedResultsController<Category>?
    var allGoalsFetchedResultsController: NSFetchedResultsController<SavingGoal>?
    var allEventsFetchedResultsController: NSFetchedResultsController<Event>?
    
    var selectedTransaction: Transaction?
    var selectedAccount: Account?
    var selectedEvent: Event?
    var selectedGoal: SavingGoal?
    var currentFilter: FilterGroup?
    
    var firebaseController: AuthenticationController?
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges{
            do{
                try persistentContainer.viewContext.save()
            }catch{
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .category || listener.listenerType == .all {
            listener.onAllCategoriesChange(change: .update, categories: fetchAllCategory())
        }

        if listener.listenerType == .transaction || listener.listenerType == .all {
            listener.onAllTransactionsChange(change: .update, transactions: fetchAllTransactions())
        }
    
        if listener.listenerType == .account || listener.listenerType == .all {
            listener.onAllAccountsChange(change: .update, accounts: fetchAllAccounts())
        }
        
        if listener.listenerType == .savingGoal || listener.listenerType == .all {
            listener.onAllGoalsChange(change: .update, goals: fetchAllGoals())
        }
        
        if listener.listenerType == .event || listener.listenerType == .all {
            listener.onAllEventsChange(change: .update, events: fetchAllEvents())
        }
    
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allCategoriesFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .category || listener.listenerType == .all {
                    listener.onAllCategoriesChange(change: .update, categories: fetchAllCategory())
                }
            }
        } else if controller == allTransactionsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .transaction || listener.listenerType == .all {
                    listener.onAllTransactionsChange(change: .update, transactions: fetchAllTransactions())
                }
            }
        }else if controller == allAccountsFetchedResultsController{
            listeners.invoke { (listener) in
                if listener.listenerType == .account || listener.listenerType == .all {
                    listener.onAllAccountsChange(change: .update, accounts: fetchAllAccounts())
                }
            }
        }else if controller == allGoalsFetchedResultsController{
            listeners.invoke{ (listener) in
                if listener.listenerType == .savingGoal || listener.listenerType == .all {
                    listener.onAllGoalsChange(change: .update, goals: fetchAllGoals())
                }
            }
        }else if controller == allEventsFetchedResultsController{
            listeners.invoke{ (listener) in
                if listener.listenerType == .event || listener.listenerType == .all {
                    listener.onAllEventsChange(change: .update, events: fetchAllEvents())
                }
            }
        }
    }
    
    override init(){
        // init container
        persistentContainer = NSPersistentContainer(name: "DataModel")
        // provide closure for error handling
        persistentContainer.loadPersistentStores(){ (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
                
        super.init()
    }
    
    func fetchAllTransactions() -> [Transaction]{
        if allTransactionsFetchedResultsController == nil {
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allTransactionsFetchedResultsController = NSFetchedResultsController<Transaction>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            allTransactionsFetchedResultsController?.delegate = self
            
            // start fetch request and listener
            do {
                try allTransactionsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let transactions = allTransactionsFetchedResultsController?.fetchedObjects {
            return transactions
        }
        return [Transaction]()
    }
    
    func fetchAllAccounts() -> [Account]{
        if allAccountsFetchedResultsController == nil {
            let request: NSFetchRequest<Account> = Account.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allAccountsFetchedResultsController = NSFetchedResultsController<Account>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            allAccountsFetchedResultsController?.delegate = self
            
            // start fetch request and listener
            do {
                try allAccountsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let accounts = allAccountsFetchedResultsController?.fetchedObjects {
            return accounts
        }
        return [Account]()
    }
    
    func fetchAllCategory() -> [Category]{
        if allCategoriesFetchedResultsController == nil {
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allCategoriesFetchedResultsController = NSFetchedResultsController<Category>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            allCategoriesFetchedResultsController?.delegate = self
            
            // start fetch request and listener
            do {
                try allCategoriesFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let categories = allCategoriesFetchedResultsController?.fetchedObjects {
            return categories
        }
        return [Category]()
    }
    
    func fetchAllGoals() -> [SavingGoal]{
        if allGoalsFetchedResultsController == nil {
            let request: NSFetchRequest<SavingGoal> = SavingGoal.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allGoalsFetchedResultsController = NSFetchedResultsController<SavingGoal>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            allGoalsFetchedResultsController?.delegate = self
            
            // start fetch request and listener
            do {
                try allGoalsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let goals = allGoalsFetchedResultsController?.fetchedObjects {
            return goals
        }
        return [SavingGoal]()
    }
    
    func fetchAllEvents() -> [Event]{
        if allEventsFetchedResultsController == nil {
            let request: NSFetchRequest<Event> = Event.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // Initialise Fetched Results Controller
            allEventsFetchedResultsController = NSFetchedResultsController<Event>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Set this class to be the results delegate
            allEventsFetchedResultsController?.delegate = self
            
            // start fetch request and listener
            do {
                try allEventsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        if let events = allEventsFetchedResultsController?.fetchedObjects {
            return events
        }
        return [Event]()
    }
    
    func addAccount(name: String?, totalSaving: Double, number: String?) -> Account {
        let account = NSEntityDescription.insertNewObject(forEntityName:"Account", into: persistentContainer.viewContext) as! Account
        account.name = name
        account.number = number
        account.totalSaving = NSNumber(value: totalSaving)
        account.availableCredit = NSNumber(value: totalSaving)
        
        return account
    }
    
    func deleteAccount(account: Account) {
        persistentContainer.viewContext.delete(account)
    }
    
    func addEvent(endDate: Date, startDate: Date, name: String) -> Event{
        let event = NSEntityDescription.insertNewObject(forEntityName: "Event", into: persistentContainer.viewContext) as! Event
        event.endDate = endDate
        event.startDate = startDate
        event.name = name
        event.totalSpending = 0
        
        return event
    }
    
    func deleteEvent(event: Event){
        persistentContainer.viewContext.delete(event)
    }
    
    func addGoal(name: String, targetDate: Date?, targetAmount: Double, regularity: Int32) -> SavingGoal{
        let goal = NSEntityDescription.insertNewObject(forEntityName: "SavingGoal", into: persistentContainer.viewContext) as! SavingGoal
        goal.name = name
        goal.targetDate = targetDate
        goal.remainingAmount = NSNumber(value: targetAmount)
        goal.targetAmount = NSNumber(value: targetAmount)
        goal.regularity = regularity
        
        return goal
    }
    
    func deleteGoal(goal: SavingGoal){
        persistentContainer.viewContext.delete(goal)
    }
    
    func addLocation(name: String, address: String, lat: Double, lon: Double) -> Location{
        let location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: persistentContainer.viewContext) as! Location
        location.name = name
        location.address = address
        location.lat = NSNumber(value: lat)
        location.lon = NSNumber(value: lon)
        
        return location
    }
    
    func deleteLocation(location: Location){
        persistentContainer.viewContext.delete(location)
    }
    
    func addLocationToTransaction(location: Location, transaction: Transaction){
        transaction.location = location
    }
    
    func addCategory(name: String) -> Category{
        let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: persistentContainer.viewContext) as! Category
        category.name = name
        
        return category
    }
    
    func deleteCategory(category: Category){
        persistentContainer.viewContext.delete(category)
    }
    
    func addCategoryToTransaction(category: Category, transaction: Transaction){
        transaction.category = category
    }
    
    func addImage(imgReference: String) -> ImageMetaData{
        let image = NSEntityDescription.insertNewObject(forEntityName: "ImageMetaData", into: persistentContainer.viewContext) as! ImageMetaData
        image.imgReference = imgReference
        
        return image
    }
    
    func deleteImage(image: ImageMetaData){
        persistentContainer.viewContext.delete(image)
    }
    
    func addImageToCategory(image: ImageMetaData, category: Category){
        category.image = image
    }
    
    func addImageToAccount(image: ImageMetaData, account: Account){
        account.image = image
    }
    
    func addImageToEvent(image: ImageMetaData, event: Event){
        event.image = image
    }
    
    func addImageToGoal(image: ImageMetaData, goal: SavingGoal){
        goal.image = image
    }
    
    func addImageToTransaction(image: ImageMetaData, transaction: Transaction){
        transaction.image = image
    }
    
    func addTransaction(amount: Double, date: Date, isSpending: Bool, note: String) -> Transaction {
        let transaction = NSEntityDescription.insertNewObject(forEntityName: "Transaction", into: persistentContainer.viewContext) as! Transaction
        transaction.amount = NSNumber(value: amount)
        transaction.date = date
        transaction.isSpending = isSpending
        transaction.note = note
        
        return transaction
    }
    
    func deleteTransaction(transaction: Transaction) {
        persistentContainer.viewContext.delete(transaction)
    }
    
    func addTransToAccount(transaction: Transaction, account: Account) {
        account.addToTransactions(transaction)
        transaction.account = account
        if transaction.isSpending{
            account.availableCredit = NSNumber(value: Double(truncating: account.availableCredit!) - Double(truncating: transaction.amount!))
            account.totalSaving = NSNumber(value: Double(truncating: account.totalSaving!) - Double(truncating: transaction.amount!))
        }else{
            account.availableCredit = NSNumber(value: Double(truncating: account.availableCredit!) + Double(truncating: transaction.amount!))
            account.totalSaving = NSNumber(value: Double(truncating: account.totalSaving!) + Double(truncating: transaction.amount!))
        }
    }
    
    func addTransToEvent(transaction: Transaction, event: Event){
        event.addToTransactions(transaction)
        if transaction.isSpending{
            event.totalSpending = NSNumber(value: Double(truncating: event.totalSpending!) - Double(truncating: transaction.amount!))
        }else{
            event.totalSpending = NSNumber(value: Double(truncating: event.totalSpending!) + Double(truncating: transaction.amount!))
        }
    }
    
    func addTransToGoal(transaction: Transaction, goal: SavingGoal) -> Bool{
        if(transaction.isSpending){
            return false
        }
        goal.addToTransactions(transaction)
        goal.remainingAmount = NSNumber(value: Double(truncating: goal.remainingAmount!) - Double(truncating: transaction.amount!))
        return true
    }

}
