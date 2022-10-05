//
//  NearByWalker.swift
//  DogWalker
//
//  Created by 2021M05 on 01/08/22.
//

import Foundation

class NearByWalkerModel {
    var latitude: Double?
    var longitude: Double?
    var name: String
    
    init(latitude: Double, longitude: Double, name: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
    }
}
