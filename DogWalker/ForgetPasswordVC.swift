//
//  ForgetPasswordVC.swift
//  DogWalker

import UIKit

class ForgetPasswordVC: UIViewController {

    //MARK: Outlet
    @IBOutlet weak var vwBack: UIView!
    
    //MARK: Class Variable
    
    //MARK: Custom Method
    
    func setUpView(){
        self.applyStyle()
    }
    
    func applyStyle(){
        self.vwBack.layer.cornerRadius = 25
    }
    
    //MARK: Action Method
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    //MARK: Delegates
    
    //MARK: UILifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }

}
