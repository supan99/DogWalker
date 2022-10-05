//
//  ViewController.swift
//  DogWalker
//
//  Created by 2021M05 on 13/07/22.
//

import UIKit

enum UserType {
    case Owner
    case Walker
    case Admin
    
    func getname() -> String {
        switch self {
            case .Admin:
                return "admin"
            case .Owner:
                return "owner"
            case .Walker:
                return "walker"
            default:
                return "admin"
        }
    }
}

@available(iOS 15.0.0, *)
class WelComeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: Action Methods
    
    @IBAction func btnDogOwnerTapped(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        nextVC.userType = .Owner
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnDogWalkerTapped(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        nextVC.userType = .Walker
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnAdminTapped(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        nextVC.userType = .Admin
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

}

