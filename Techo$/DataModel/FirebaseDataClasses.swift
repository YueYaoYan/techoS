//
//  FirebaseDataClasses.swift
//  Techo$
//
//  Created by Yue Yan on 7/6/2022.
//
/*
    Some classes are defined to structures due to they do not need references to other classes.
    While some classes are defined to inherit NSObject due to maintainance of reference to other classes
 */
import Foundation
import Firebase
import FirebaseFirestoreSwift

enum CodingKeys: String, CodingKey{
    case id
    case reference
    case name
    case lat
    case lon
    case address
    case amount
    case date
    case isSpending
    case note
    case number
    case availableCredit
    case remainingCredit
    case totalSaving
    case remainingAmount
    case targetAmount
    case targetDate
    case endDate
    case startDate
    case totalSpending
}

struct ImageMetaData: Codable{
    @DocumentID var id: String?
    var reference: String?
    var url: String?
}

struct Location: Codable{
    @DocumentID var id: String?
    var name: String?
    var lat: Double?
    var lon: Double?
    var address: String?
}

struct Category: Codable{
    @DocumentID var id: String?
    var name: String?
    var image: ImageMetaData?
}

class Transaction: NSObject, Codable{
    @DocumentID var id: String?
    var amount: Double?
    @ServerTimestamp var date: Date?
    var isSpending: Bool?
    var note: String?
    var category: Category?
    var location: Location?
    var image: ImageMetaData?
    var account: Account?
}

class Account: NSObject, Codable{
    @DocumentID var id: String?
    var name: String?
    var number: String?
    var availableCredit: Double?
    var totalSaving: Double?
    var image: ImageMetaData?
    var transactions = [Transaction]()
}

class Goal: NSObject, Codable{
    @DocumentID var id: String?
    var name: String?
    var remainingAmount: Double?
    var targetAmount: Double?
    @ServerTimestamp var targetDate: Date?
    var image: ImageMetaData?
    var transactions = [Transaction]()
}

class Event: NSObject, Codable{
    @DocumentID var id: String?
    var name: String?
    @ServerTimestamp var endDate: Date?
    @ServerTimestamp var startDate: Date?
    var totalSpending: Double?
    var image: ImageMetaData?
    var transactions = [Transaction]()
}

struct User: Codable{
    @DocumentID var id: String?
    var uid: String?
}
