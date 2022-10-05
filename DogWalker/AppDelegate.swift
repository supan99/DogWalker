//
//  AppDelegate.swift
//  DogWalker
//
//  Created by 2021M05 on 13/07/22.
//

import UIKit
@_exported import Firebase
@_exported import FirebaseCore
@_exported import Photos
@_exported import OpalImagePicker
@_exported import GoogleMaps
@_exported import GooglePlaces
@_exported import Razorpay


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var database : Firestore!
    static let shared : AppDelegate = UIApplication.shared.delegate as! AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        database = Firestore.firestore()
        let settings = database.settings
        database.settings = settings
        GMSServices.provideAPIKey("AIzaSyAtE3XUkS_CIw8lTVu-8bZXi_LtsvmO4jc")
        return true
    }
    
    
    func openLink(){
        if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

