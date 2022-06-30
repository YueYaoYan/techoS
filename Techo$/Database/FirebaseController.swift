//
//  FirebaseController.swift
//  Techo$
//
//  Created by Yue Yan on 7/6/2022.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorageSwift
import SwiftUI
 
class FirebaseController: NSObject, DatabaseProtocol{
    func authorizedUserLogin(user: FirebaseAuth.User?) {
        self.currentUser = user
        self.setupUserListener()
    }
    
    func logout() {
        self.transactionRef = nil
        self.accountRef = nil
        self.categoryRef = nil
        self.locationRef = nil
        self.eventRef = nil
        self.goalRef = nil
        self.imageRef = nil
        self.userRef = nil
        self.userDoc = nil
     
        self.allCategory = [Category]()
        self.allTransaction = [Transaction]()
        self.allAccount = [Account]()
        self.allEvent = [Event]()
        self.allGoal = [Goal]()
        self.allImage = [ImageMetaData]()
        self.allUIImage = [UIImage]()
        self.allImageRef = [String]()
        self.allLocation = [Location]()
        self.user = nil
    }
    
    var database: Firestore
    var listeners = MulticastDelegate<DatabaseListener>()
 
    // MARK: Firebase references
    var transactionRef: CollectionReference?
    var accountRef: CollectionReference?
    var categoryRef: CollectionReference?
    var locationRef: CollectionReference?
    var eventRef: CollectionReference?
    var goalRef: CollectionReference?
    var imageRef: CollectionReference?
    var userRef: CollectionReference?
    var userDoc: DocumentReference?
 
    var allCategory = [Category]()
    var allTransaction = [Transaction]()
    var allAccount = [Account]()
    var allEvent = [Event]()
    var allGoal = [Goal]()
    var allImage = [ImageMetaData]()
    var allUIImage = [UIImage]()
    var allImageRef = [String]()
    var allLocation = [Location]()
    var user: User?
 
    var currentUser: FirebaseAuth.User?
    var storageReference = Storage.storage().reference()
 
    var selectedTransaction: Transaction?
    var selectedAccount: Account?
    var selectedEvent: Event?
    var selectedGoal: Goal?
    var currentFilter: FilterGroup?
 
    override init(){
        database = Firestore.firestore()
 
        super.init()
    }
 
    func cleanup() {
 
    }
 
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
 
        if listener.listenerType == .category || listener.listenerType == .all {
            listener.onAllCategoriesChange(change: .update, categories: allCategory)
        }
 
        if listener.listenerType == .transaction || listener.listenerType == .all {
            listener.onAllTransactionsChange(change: .update, transactions: allTransaction)
        }
 
        if listener.listenerType == .account || listener.listenerType == .all {
            listener.onAllAccountsChange(change: .update, accounts: allAccount)
        }
 
        if listener.listenerType == .savingGoal || listener.listenerType == .all {
            listener.onAllGoalsChange(change: .update, goals: allGoal)
        }
 
        if listener.listenerType == .event || listener.listenerType == .all {
            listener.onAllEventsChange(change: .update, events: allEvent)
        }
    }
 
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
 
 
    func setupImageListener(){
        guard let userDoc = self.userDoc else {return}
        
        imageRef = userDoc.collection("images")
        imageRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseImageSnapshot(snapshot: querySnapshot)
            if self.locationRef == nil{
                self.setupLocationListener()
            }
       }
    }
 
    func parseImageSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            let imageName = change.document.documentID
            guard let imageURL = change.document.data()["url"] as? String, let reference = change.document.data()["reference"] as? String else {return}
            var img = ImageMetaData()
            img.id = imageName
            img.reference = reference
            img.url = imageURL
            if change.type == .added {
                if !self.allImageRef.contains(reference) {
                    if loadImageData(filename: reference) != nil {
                        self.allImageRef.append(reference)
                        self.allImage.append(img)
                    } else {
                        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                        let documentsDirectory = paths[0]
                        let fileURL = documentsDirectory.appendingPathComponent(reference)
                        let downloadTask = storageReference.storage.reference(forURL: imageURL).write(toFile:fileURL)
                        downloadTask.observe(.success) { snapshot in
                            self.allImageRef.append(reference)
                            self.allImage.append(img)
                        }
                        downloadTask.observe(.failure){
                            snapshot in print("\(String(describing: snapshot.error))")
                        }
                    }
                }
            }
        }
    }
    
    func uploadImages(filename: String) async -> ImageMetaData?{
        guard let userID = user?.id, let userRef = self.userRef, let image = loadImageData(filename: filename) else {return nil}
        let timestamp = "\(Date().timeIntervalSince1970)".replacingOccurrences(of: ".", with: "")
        let imageRef = storageReference.child("\(userID)/images/\(timestamp)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        var imageMetaData: ImageMetaData? = ImageMetaData()
        do{
            _ = try await imageRef.putDataAsync(data, metadata: metadata)
            imageMetaData?.id = timestamp
            imageMetaData?.reference = "\(filename)"
            imageMetaData?.url = "\(imageRef)"
            try await userRef.document("\(userID)").collection("images").document(timestamp).setData([
                "reference" : "\(filename)",
                "url" : "\(imageRef)"])
        }catch{
            print("error: \(error)")
            imageMetaData = nil
        }
    
        return imageMetaData
    }
    
    func setupUserListener(){
        guard currentUser != nil else {return}
 
        userRef = database.collection("users")
        userRef?.whereField("uid", isEqualTo: currentUser!.uid as Any).addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot, let userSnapshot = querySnapshot.documents.first else {
                print("Error fetching user: \(String(describing: error))")
                return
            }
            self.userDoc = userSnapshot.reference
            self.parseUserSnapshot(snapshot: userSnapshot)
            if self.imageRef == nil{
                self.setupImageListener()
            }
        }
    }
    
    func parseUserSnapshot(snapshot: QueryDocumentSnapshot){
        var user = User()
        user.uid = snapshot.data()["uid"] as? String
        user.id = snapshot.documentID
        self.user = user
    }
    
    func setupTransactionListener(){
        guard let userDoc = self.userDoc else {return}
        
        transactionRef = userDoc.collection("transactions")
        transactionRef?.addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
 
                print("Error fetching transaction: \(error!)")
                return
            }
            self.parseTransactionSnapshot(snapshot: querySnapshot)
            if self.accountRef == nil{
                self.setupAccountListener()
            }
        }
    }
    
    func parseTransactionSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var parsedTransaction: Transaction?
            
            parsedTransaction = Transaction()
            
            let data = change.document.data()
            parsedTransaction?.id = change.document.documentID
            parsedTransaction?.date = (data["date"] as? Timestamp)?.dateValue()
            parsedTransaction?.isSpending = data["isSpending"] as? Bool
            parsedTransaction?.amount = data["amount"] as? Double
            parsedTransaction?.note = data["note"] as? String
            if let imageRef = data["image"] as? DocumentReference{
                parsedTransaction?.image = self.fetchImageByID(imageRef.documentID)
            }
            if let locRef = data["location"] as? DocumentReference{
                parsedTransaction?.location = self.fetchLocationByID(locRef.documentID)
            }
            if let categoryRef = data["category"] as? DocumentReference {
                parsedTransaction?.category = self.fetchCategoryByID(categoryRef.documentID)
            }
            
            guard let transaction = parsedTransaction else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                allTransaction.insert(transaction, at: Int(change.newIndex))
            }
            
            else if change.type == .modified {
                allTransaction[Int(change.oldIndex)] = transaction
            }
            else if change.type == .removed {
                allTransaction.remove(at: Int(change.oldIndex))
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.transaction ||
                    listener.listenerType == ListenerType.all {
                    listener.onAllTransactionsChange(change: .update, transactions: allTransaction)
                }
            }
        }
    }
    
    func setupAccountListener(){
        guard let userDoc = self.userDoc else {return}
 
        accountRef = userDoc.collection("accounts")
        accountRef?.addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
 
                print("Error fetching account: \(error!)")
                return
            }
            self.parseAccountSnapshot(snapshot: querySnapshot)
            if self.eventRef == nil{
                self.setupEventListener()
            }
            if self.goalRef == nil{
                self.setupGoalListener()
            }
        }
    }
    
    func parseAccount(_ parsedAccount: inout Account?, _ change: DocumentChange) {
        // parse Account
        parsedAccount = Account()
        parsedAccount?.id = change.document.documentID
        let data = change.document.data()
        parsedAccount?.name = data["name"] as? String
        parsedAccount?.number = data["number"] as? String
        parsedAccount?.availableCredit = data["availableCredit"] as? Double
        parsedAccount?.totalSaving = data["totalSaving"] as? Double
        if let imageRef = data["image"] as? DocumentReference{
            parsedAccount?.image = self.fetchImageByID(imageRef.documentID)
        }
        if let transactionRef = data["transactions"] as? [DocumentReference] {
            for reference in transactionRef {
                if let transaction = fetchTransactionByID(reference.documentID) {
                    transaction.account = parsedAccount
                    parsedAccount?.transactions.append(transaction)
                    
                }
            }
        }
    }
    
    func parseAccountSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var parsedAccount: Account?
            
            parseAccount(&parsedAccount, change)
            
            guard let account = parsedAccount else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                allAccount.insert(account, at: Int(change.newIndex))
            }
            
            else if change.type == .modified {
                allAccount[Int(change.oldIndex)] = account
            }
            else if change.type == .removed {
                allAccount.remove(at: Int(change.oldIndex))
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.account ||
                    listener.listenerType == ListenerType.all {
                    listener.onAllAccountsChange(change: .update, accounts: allAccount)
                }
            }
        }
    }
    
    func setupEventListener(){
        guard let userDoc = self.userDoc else {return}
 
        eventRef = userDoc.collection("events")
        eventRef?.addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
 
                print("Error fetching account: \(error!)")
                return
            }
            self.parseEventSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseEvent(_ parsedEvent: inout Event?, _ change: DocumentChange) {
        //                parsedEvent = try change.document.data(as: Event.self)
        parsedEvent = Event()
        parsedEvent?.id = change.document.documentID
        let data = change.document.data()
        parsedEvent?.name = data["name"] as? String
        parsedEvent?.totalSpending = data["totalSpending"] as? Double
        parsedEvent?.startDate = (data["startDate"] as? Timestamp)?.dateValue()
        parsedEvent?.endDate = (data["endDate"] as? Timestamp)?.dateValue()
        if let imageRef = data["image"] as? DocumentReference{
            parsedEvent?.image = self.fetchImageByID(imageRef.documentID)
        }
        
        if let transactionRef = data["transactions"] as? [DocumentReference] {
            for reference in transactionRef {
                if let transaction = fetchTransactionByID(reference.documentID) {
                    parsedEvent?.transactions.append(transaction)
                }
            }
        }
    }
    
    func parseEventSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var parsedEvent: Event?
            parseEvent(&parsedEvent, change)
            guard let event = parsedEvent else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                allEvent.insert(event, at: Int(change.newIndex))
            }
            
            else if change.type == .modified {
                allEvent[Int(change.oldIndex)] = event
            }
            else if change.type == .removed {
                allEvent.remove(at: Int(change.oldIndex))
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.event ||
                    listener.listenerType == ListenerType.all {
                    listener.onAllEventsChange(change: .update, events: allEvent)
                }
            }
        }
    }
    
    
    func setupGoalListener(){
        guard let userDoc = self.userDoc else {return}
 
        goalRef = userDoc.collection("goals")
        goalRef?.addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
 
                print("Error fetching account: \(error!)")
                return
            }
            self.parseGoalSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseGoal(_ change: DocumentChange, _ parsedGoal: inout Goal?) {
        //                parsedGoal = try change.document.data(as: Goal.self)
        let data = change.document.data()
        parsedGoal = Goal()
        parsedGoal?.id = change.document.documentID
        parsedGoal?.name = data["name"] as? String
        parsedGoal?.remainingAmount = data["remainingAmount"] as? Double
        parsedGoal?.targetAmount = data["targetAmount"] as? Double
        parsedGoal?.targetDate = (data["targetDate"] as? Timestamp)?.dateValue()
        if let imageRef = data["image"] as? DocumentReference{
            parsedGoal?.image = self.fetchImageByID(imageRef.documentID)
        }
        if let transactionRef = data["transactions"] as? [DocumentReference] {
            for reference in transactionRef {
                if let transaction = fetchTransactionByID(reference.documentID) {
                    parsedGoal?.transactions.append(transaction)
                }
            }
        }
    }
    
    func parseGoalSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var parsedGoal: Goal?
            parseGoal(change, &parsedGoal)
            guard let goal = parsedGoal else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                allGoal.insert(goal, at: Int(change.newIndex))
            }
            
            else if change.type == .modified {
                allGoal[Int(change.oldIndex)] = goal
            }
            else if change.type == .removed {
                allGoal.remove(at: Int(change.oldIndex))
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.savingGoal ||
                    listener.listenerType == ListenerType.all {
                    listener.onAllGoalsChange(change: .update, goals: allGoal)
                }
            }
        }
    }
    
    func setupCategoryListener(){
        guard let userDoc = self.userDoc else {return}
 
        categoryRef = userDoc.collection("categories")
        categoryRef?.addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
 
                print("Error fetching account: \(error!)")
                return
            }
            self.parseCategorySnapshot(snapshot: querySnapshot)
            if self.transactionRef == nil {
                self.setupTransactionListener()
            }
        }
    }
    
    func parseCategorySnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var parsedCategory: Category? = Category()
            let data = change.document.data()
            if let imgRef = data["image"] as? DocumentReference{
                parsedCategory?.image = self.fetchImageByID(imgRef.documentID)
            }
            parsedCategory?.name = data["name"] as? String
            parsedCategory?.id = change.document.documentID
            
            guard let category = parsedCategory else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                allCategory.insert(category, at: Int(change.newIndex))
            }
            
            else if change.type == .modified {
                allCategory[Int(change.oldIndex)] = category
            }
            else if change.type == .removed {
                allCategory.remove(at: Int(change.oldIndex))
            }
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.category ||
                    listener.listenerType == ListenerType.all {
                    listener.onAllCategoriesChange(change: .update, categories: allCategory)
                }
            }
        }
    }
    
    func setupLocationListener(){
        guard let userDoc = self.userDoc else {return}
 
        locationRef = userDoc.collection("locations")
        locationRef?.addSnapshotListener {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
 
                print("Error fetching account: \(error!)")
                return
            }
            self.parseLocationSnapshot(snapshot: querySnapshot)
            if self.categoryRef == nil{
                self.setupCategoryListener()
            }
        }
    }
    
    func parseLocationSnapshot(snapshot: QuerySnapshot){
        snapshot.documentChanges.forEach { (change) in
            var parsedLocation: Location?
            do {
                parsedLocation = try change.document.data(as: Location.self)
            } catch {
                print("Unable to decode Location.")
                return
            }
            guard let location = parsedLocation else {
                print("Document doesn't exist")
                return
            }
            if change.type == .added {
                allLocation.insert(location, at: Int(change.newIndex))
            }
            
            else if change.type == .modified {
                allLocation[Int(change.oldIndex)] = location
            }
            else if change.type == .removed {
                allLocation.remove(at: Int(change.oldIndex))
            }
        }
    }
    
    
    func fetchImageByID(_ id: String) -> ImageMetaData?{
        for image in allImage {
            if image.id == id {
                return image
            }
        }
        return nil
    }
    
    func fetchCategoryByID(_ id: String) -> Category?{
        for category in allCategory {
            if category.id == id {
                return category
            }
        }
        return nil
    }
    
    func fetchLocationByID(_ id: String) -> Location?{
        for location in allLocation {
            if location.id == id {
                return location
            }
        }
        return nil
    }
    
    func fetchTransactionByID(_ id: String) -> Transaction?{
        for transaction in allTransaction {
            if transaction.id == id {
                return transaction
            }
        }
        return nil
    }
    
    func fetchAccountByID(_ id: String) -> Account?{
        for account in allAccount {
            if account.id == id {
                return account
            }
        }
        return nil
    }
    
    func fetchEventByID(_ id: String) -> Event?{
        for event in allEvent {
            if event.id == id {
                return event
            }
        }
        return nil
    }
    
    func fetchGoalByID(_ id: String) -> Goal?{
        for goal in allGoal {
            if goal.id == id {
                return goal
            }
        }
        return nil
    }
 
    func addAccount(name: String?, totalSaving: Double, number: String?) -> Account {
        let account = Account()
        account.name = name
        account.number = number
        account.totalSaving = totalSaving
        account.availableCredit = totalSaving
 
        do {
            if let accountRef = try accountRef?.addDocument(from: account) {
                account.id = accountRef.documentID
            }
        } catch {
            print("Failed to serialize account")
        }
        return account
    }
 
    func deleteAccount(account: Account) {
        if let accountID = account.id {
            for tran in account.transactions{
                deleteTransaction(transaction: tran)
            }
            accountRef?.document(accountID).delete()
        }
    }
 
    func addEvent(endDate: Date, startDate: Date, name: String) -> Event{
        let event = Event()
        event.endDate = endDate
        event.startDate = startDate
        event.name = name
        event.totalSpending = 0
        do {
            if let eventRef = try eventRef?.addDocument(from: event) {
                event.id = eventRef.documentID
            }
        } catch {
            print("Failed to serialize event")
        }
        return event
    }
 
    func deleteEvent(event: Event){
        if let eventID = event.id {
            for tran in event.transactions{
                deleteTransaction(transaction: tran)
            }
            eventRef?.document(eventID).delete()
        }
    }
 
    func addGoal(name: String, targetDate: Date?, targetAmount: Double, regularity: Int32) -> Goal{
        let goal = Goal()
        goal.name = name
        goal.targetDate = targetDate
        goal.remainingAmount = targetAmount
        goal.targetAmount = targetAmount
        do {
            if let goalRef = try goalRef?.addDocument(from: goal) {
                goal.id = goalRef.documentID
            }
        } catch {
            print("Failed to serialize goal")
        }
        return goal
    }
 
    func deleteGoal(goal: Goal){
        if let goalID = goal.id {
            for tran in goal.transactions{
                deleteTransaction(transaction: tran)
            }
            goalRef?.document(goalID).delete()
        }
    }
 
    func addLocation(name: String, address: String, lat: Double, lon: Double) -> Location{
        var location = Location()
        location.name = name
        location.address = address
        location.lat = lat
        location.lon = lon
        do {
            if let locRef = try locationRef?.addDocument(from: location) {
                location.id = locRef.documentID
            }
        } catch {
            print("Failed to serialize location")
        }
        return location
    }
 
    func deleteLocation(location: Location){
        if let locationID = location.id {
            locationRef?.document(locationID).delete()
        }
    }
 
    func addLocationToTransaction(location: Location, transaction: Transaction) -> Bool{
        guard let locationID = location.id, let transactionID = transaction.id else {
            return false
       }
        if let newLocRef = locationRef?.document(locationID) {
            transactionRef?.document(transactionID).updateData(
                ["location" : newLocRef ]
            )
        }
        return true
    }
 
    func addCategory(name: String) -> Category{
        var category = Category()
        category.name = name
        do {
            if let categoryRef = try categoryRef?.addDocument(from: category) {
                category.id = categoryRef.documentID
            }
        } catch {
            print("Failed to serialize category")
        }
        return category
    }
 
    func addCategoryToTransaction(category: Category, transaction: Transaction){
        guard let categoryID = category.id, let transactionID = transaction.id else {
            return
       }
        if let categoryRef = categoryRef?.document(categoryID) {
            transactionRef?.document(transactionID).updateData(
                ["category" : categoryRef]
            )
        }
    }
 
    func addImage(imgReference: String, url: String) -> ImageMetaData{
        var image = ImageMetaData()
        image.reference = imgReference
        image.url = url
 
        do {
            if let imageRef = try imageRef?.addDocument(from: image) {
                image.id = imageRef.documentID
            }
        } catch {
            print("Failed to serialize image")
        }
        return image
    }
 
    func deleteImage(image: ImageMetaData){
        if let imageID = image.id {
            imageRef?.document(imageID).delete()
        }
    }
 
    func addImageToCategory(image: ImageMetaData, category: Category){
        guard let imageID = image.id, let categoryID = category.id else {
            return
       }
        if let imageRef = imageRef?.document(imageID) {
            categoryRef?.document(categoryID).updateData(
                ["image" : imageRef]
            )
        }
    }
 
    func addImageToAccount(image: ImageMetaData, account: Account){
        guard let imageID = image.id, let accountID = account.id else {
            return
       }
        if let imageRef = imageRef?.document(imageID) {
            accountRef?.document(accountID).updateData(
                ["image" : imageRef]
            )
        }
    }
 
    func addImageToEvent(image: ImageMetaData, event: Event){
        guard let imageID = image.id, let eventID = event.id else {
            return
       }
        if let imageRef = imageRef?.document(imageID) {
            eventRef?.document(eventID).updateData(
                ["image" : imageRef]
            )
        }
    }
 
    func addImageToGoal(image: ImageMetaData, goal: Goal){
        guard let imageID = image.id, let goalID = goal.id else {
            return
       }
        if let imageRef = imageRef?.document(imageID) {
            goalRef?.document(goalID).updateData(
                ["image" : imageRef]
            )
        }
    }
 
    func addImageToTransaction(image: ImageMetaData, transaction: Transaction){
        guard let imageID = image.id, let transactionID = transaction.id else {
            return
       }
        if let imageRef = imageRef?.document(imageID) {
            transactionRef?.document(transactionID).updateData(
                ["image" : imageRef]
            )
        }
    }
    
    func getSelectedTypeTransaction() -> [Transaction]? {
        if selectedGoal != nil{
            return selectedGoal!.transactions
            
        }else if selectedAccount != nil{
            return selectedAccount!.transactions
            
        }else if selectedEvent != nil{
            return selectedEvent!.transactions
            
        }
        return nil
    }
    
    func addLocationToTransaction(location: Location, transaction: Transaction) {
        guard let locationID = location.id, let transactionID = transaction.id else {
            return
       }
        if let locationRef = locationRef?.document(locationID) {
            transactionRef?.document(transactionID).updateData(
                ["location" : locationRef]
            )
        }
    }
 
    func addTransaction(amount: Double, date: Date, isSpending: Bool, note: String) -> Transaction {
        let transaction = Transaction()
        transaction.amount = amount
        transaction.date = date
        transaction.isSpending = isSpending
        transaction.note = note
 
        do {
            if let transactionRef = try transactionRef?.addDocument(from: transaction) {
                transaction.id = transactionRef.documentID
            }
        } catch {
            print("Failed to serialize transaction")
        }
        return transaction
    }
 
    func deleteTransaction(transaction: Transaction) {
        if let transactionID = transaction.id, let transRef = transactionRef?.document(transactionID) {
            if let account = transaction.account, let accountID = account.id{
                accountRef?.document(accountID).updateData([
                    "transactions": FieldValue.arrayRemove([transRef])
                ])
            }
            transactionRef?.document(transactionID).delete()
        }
    }
    
    func addTransToAccount(transaction: Transaction, account: Account) {
        // check if needed values are all not nil
        guard let transactionID = transaction.id, let accountID = account.id, let available = account.availableCredit, let total = account.totalSaving, let amount = transaction.amount, let isSpending = transaction.isSpending else {
            print("Error in adding transaction to account")
            return
       }
        var newAvailable = available + amount
        var newTotal = total + amount
        if isSpending{
            newAvailable = available - amount
            newTotal = total - amount
        }
        
        // update data
        if let transRef = transactionRef?.document(transactionID), let newAccountRef = accountRef?.document(accountID) {
            transRef.updateData(["account" : newAccountRef])
            newAccountRef.updateData(
                ["transactions" : FieldValue.arrayUnion([transRef]),
                 "availableCredit" : newAvailable,
                 "totalSaving" : newTotal]
            )
        }
    }
    
    func addTransToEvent(transaction: Transaction, event: Event){
        // check if needed values are all not nil
        guard let transactionID = transaction.id, let eventID = event.id, let totalAmount = event.totalSpending, let transAmount = transaction.amount, let isSpending = transaction.isSpending else {
            print("Error in adding transaction to event")
            return
       }
        var totalSpending = totalAmount + transAmount
        if isSpending{
            totalSpending = totalAmount - transAmount
        }
        
        // update data
        if let transRef = transactionRef?.document(transactionID) {
            eventRef?.document(eventID).updateData(
                ["transactions" : FieldValue.arrayUnion([transRef]),
                 "totalSpending" : totalSpending]
            )
        }
    }
    
    func addTransToGoal(transaction: Transaction, goal: Goal) -> Bool{
        // check if needed values are all not nil
        guard let transactionID = transaction.id, let goalID = goal.id, let remainAmount = goal.remainingAmount, let completedAmount = transaction.amount, let isSpending = transaction.isSpending else {
            print("Error in adding transaction to goal!")
            return false
       }
        // return false if transaction is for spending
        if(isSpending){
            return false
        }
        
        // update data
        let newAmount = remainAmount - completedAmount
        
        if let transRef = transactionRef?.document(transactionID) {
            goalRef?.document(goalID).updateData(
                ["transactions" : FieldValue.arrayUnion([transRef]),
                 "remainingAmount" : newAmount]
            )
        }
        return true
    }
    
    func addUser(uid: String) -> User {
        var user = User()
        user.uid = uid
 
        do {
            if let userRef = try userRef?.addDocument(from: user) {
                user.id = userRef.documentID
                
            }
        } catch {
            print("Failed to serialize user")
        }
        return user
    }
    
    func deleteUser() {
        guard let user = user, let userID = user.id  else {return}
        userRef?.document(userID).delete()
        logout()
        
    }
 
}



