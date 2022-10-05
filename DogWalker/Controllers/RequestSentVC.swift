//
//  RequestSentVC.swift
//  DogWalker

import UIKit

class RequestSentVC: UIViewController {

    @IBOutlet weak var vwBack: UIView!
   
    var timer: Timer!
    var isOwner: Bool = true
    
    func applyStyle(){
        self.vwBack.layer.cornerRadius = 25
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyStyle()
        var timeLeft = 5
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            timeLeft -= 1
            if timeLeft == 0 {
                timer.invalidate()
                self.isOwner ? UIApplication.shared.setOwnerTab() : UIApplication.shared.setWalkerTab()
            }
        }
    }
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }

}
