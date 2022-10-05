//
//  OrderModel.swift
//  DogWalker


import Foundation

class OrderModel {
    var docID: String
    var name: String
    var age: String
    var address: String
    var arrivalTime: String
    var arrivalDate: String
    var cost:String
    var hrs: String
    var status: String
    var profile: String
    var walkerID: String
    var userID: String
    var paymentStatus: String
    
    init() {
        self.docID = ""
        self.name = ""
        self.arrivalTime = ""
        self.arrivalDate = ""
        self.cost = ""
        self.hrs = ""
        self.status = ""
        self.profile = ""
        self.age = ""
        self.address = ""
        self.walkerID = ""
        self.userID = ""
        self.paymentStatus = ""
    }
    
    
}

class RequestModel {
    var docID: String
    var availablity: String
    var user_name: String
    var price: String
    var hrs: String
    var exp: String
    
    
    init(docID: String, availablity: String,user_name: String,price: String,hrs: String,exp: String) {
        self.docID = docID
        self.availablity = availablity
        self.price = price
        self.hrs = hrs
        self.exp = exp
        self.user_name = user_name
    }
    
    
}
