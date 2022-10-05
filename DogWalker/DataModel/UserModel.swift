//
//  UserWalkerModel.swift
//  JobKart


import Foundation


class UserWalkerModel {
    var docID: String
    var name: String
    var experience: String
    var hourlyRate: String
    var timing: String
    var from: String
    var to: String
    var password: String
    var description: String
    var email:String
    var userType: String
    var isEnable: Bool
    var reserved: Bool
    var lat: Double
    var lng: Double
    var profile: String
    var rating: Double
    var isFavourite: Bool
    
    init(docID: String,name: String,experience: String,email: String, password:String, hourlyRate: String,userType: String,timing: String,from: String,to: String,isEnable: Bool,description: String,lat:Double,lng:Double,profile:String,rating: Double,reserved: Bool,isFavourite: Bool){
        self.docID = docID
        self.name = name
        self.email = email
        self.experience = experience
        self.password = password
        self.hourlyRate = hourlyRate
        self.userType = userType
        self.isEnable = isEnable
        self.to = to
        self.from = from
        self.timing = timing
        self.description = description
        self.lat = lat
        self.lng = lng
        self.profile = profile
        self.rating = rating
        self.reserved = reserved
        self.isFavourite = isFavourite
    }
}


class UserOwnerModel {
    var docID: String
    var name: String
    var password: String
    var age: String
    var address: String
    var description: String
    var email:String
    var userType: String
    var isEnable: Bool
    var profile: String
    
    init(docID: String,name: String,email: String, password:String, userType: String,isEnable: Bool,description: String,profile:String,address:String, age:String){
        self.docID = docID
        self.name = name
        self.email = email
        self.password = password
        self.userType = userType
        self.isEnable = isEnable
        self.description = description
        self.profile = profile
        self.age = age
        self.address = address
    }
}
