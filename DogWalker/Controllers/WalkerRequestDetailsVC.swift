//
//  WalkerRequestDetailsVC.swift
//  DogWalker

import UIKit

class WalkerRequestDetailsVC: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblHrs: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    var data: OrderModel!
    
    @IBAction func btnContinueTapped(_ sender: UIButton) {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestSentVC") as? RequestSentVC {
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if data != nil {
            self.lblRate.text = "$" + data.cost
            self.lblName.text = data.name
            self.lblAddress.text = data.address
            self.lblTime.text = "Arrival at " + data.arrivalTime + " on " + data.arrivalDate
            self.lblHrs.text = data.hrs.description + "Hrs"
            self.imgProfile.setImgWebUrl(url: data.profile, isIndicator: true)
        }
    }
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }
    
    @IBAction func btnClick(_ sender: UIButton){
        self.updateData(data: self.data, status: dAccepted)
    }

    
    func updateData(data: OrderModel,status: String) {
        let ref = AppDelegate.shared.database.collection(dDogWalker).document(data.walkerID).collection(dOwnerRequest).document(data.docID)
        ref.updateData([
            dStatus: status
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Document successfully updated")
                let strDate = "Available on \(data.arrivalDate) at \(data.arrivalTime)"
                self.sendRequest(orderData: data,date: strDate)
            }
        }
    }
    
    
    func sendRequest(orderData: OrderModel, date: String) {
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.database.collection(dDogOwner).document(orderData.userID).collection(dWalkerRequest).addDocument(data:
                                                                                                                                    [
                                                                                                                                        dExp: GFunction.userWalker.experience,
                                                                                                                                        "hrs": orderData.hrs,
                                                                                                                                        "price": orderData.cost,
                                                                                                                                        dUser_name : GFunction.userWalker.name,
                                                                                                                                        "availablity" : date
                                                                                                                                    ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestSentVC") as? RequestSentVC {
                    nextVC.isOwner = false
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        }
    }
    
}
