//
//  WalketHomeVC.swift
//  DogWalker


import UIKit
class WalkerHomeTVC: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblYrs: UILabel!
    @IBOutlet weak var lblHrs: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var vwBack: UIView!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    
    @IBOutlet weak var lblTiming: UILabel!
    func applyStyle(){
        self.vwBack.layer.cornerRadius = 8
        self.btnApply.layer.cornerRadius = 8
        self.btnReject.layer.cornerRadius = 8
    }
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyStyle()
    }
    
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }
    
    func configCell(data: OrderModel){
        self.lblName.text = data.name.description
        self.lblHrs.text = data.hrs.description + "Hrs"
        self.lblYrs.text = data.age.description + "Yrs"
        self.lblRate.text = "$ " + data.cost.description
        self.lblAddress.text = data.address.description
        self.imgProfile.setImgWebUrl(url: data.profile, isIndicator: true)
        self.btnApply.isHidden = !(data.status == dPending)
        self.btnReject.isHidden = !(data.status == dPending)
        
        self.lblTiming.text = "Available from \(data.arrivalDate) on \(data.arrivalTime)"
    }
}

class WalkerHomeVC: UIViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblName: UILabel!
    
    var array = [OrderModel]()
    func setUpView(){
        self.getData()
        self.lblName.text = "Hello " + GFunction.userWalker.name.description.capitalized
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        Alert.shared.showAlert("", actionOkTitle: "Logout", actionCancelTitle: "Cancel", message: "Are you sure you want to logout?") { Bool in
            if Bool {
                UIApplication.shared.setStart()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }
}

extension WalkerHomeVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalkerHomeTVC") as! WalkerHomeTVC
        let data = self.array[indexPath.row]
        cell.configCell(data: data)
        cell.btnApply.addAction(for: .touchUpInside) {
            self.updateData(data: data, status: dAccepted)
        }
        cell.btnReject.addAction(for: .touchUpInside) {
            Alert.shared.showAlert("DogWalker", actionOkTitle: "Reject", actionCancelTitle: "Cancel", message: "Are you sure you want to reject this request?") { Bool in
                self.updateData(data: data, status: dRejected)
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.array[indexPath.row]
        if data.status == dAccepted {
            if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "WalkerRequestDetailsVC") as? WalkerRequestDetailsVC {
                nextVC.data = data
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
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
                self.sendRequest(orderData: data, date: strDate)
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
    
    
    func getData(){
        AppDelegate.shared.database.collection(dDogWalker).document(GFunction.userWalker.docID).collection(dOwnerRequest).whereField(dPaymentStatus, isEqualTo: dPending).addSnapshotListener{querySnapshot , error in
            
            guard let snapshot = querySnapshot else {
                print("Error")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if  let arrivalDate: String = data1[dOrderDate] as? String,
                        let arrivalTime: String = data1[dOrderTime] as? String,
                        let cost: String = data1[dTotal_cost] as? String,
                        let hrs: String = data1[dTotal_time] as? String,
                        let status: String = data1[dStatus] as? String,
                        let userID: String = data1[dUser_id] as? String,
                        let walkerID: String = data1[dWalker_id] as? String,
                        let paymentStatus: String = data1[dPaymentStatus] as? String
                            
                    {
                    print("Data Count : \(self.array.count)")
                    let orderData = OrderModel()
                    orderData.docID = data.documentID
                    orderData.arrivalDate = arrivalDate
                    orderData.arrivalTime = arrivalTime
                    orderData.cost = cost
                    orderData.hrs = hrs
                    orderData.status = status
                    orderData.userID = userID
                    orderData.walkerID = walkerID
                    orderData.paymentStatus = paymentStatus
                    self.getUserData(userID: userID, orderData: orderData)
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.tblView.delegate = self
                    self.tblView.dataSource = self
                    self.tblView.reloadData()
                }
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func getUserData(userID: String, orderData: OrderModel){
        AppDelegate.shared.database.collection(dDogOwner).whereField(dUser_id, isEqualTo: userID).addSnapshotListener{querySnapshot , error in
            
            guard let snapshot = querySnapshot else {
                print("Error")
                return
            }
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if  let name: String = data1[dUser_name] as? String,
                        let profile: String = data1[dUser_image] as? String,
                        let address: String = data1[dUser_address] as? String,
                        let age: String = data1[dUser_age] as? String {
                        print("Data Count : \(self.array.count)")
                        orderData.profile = profile
                        orderData.name = name
                        orderData.address = address
                        orderData.age = age
                        self.array.append(orderData)
                    }
                }
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
}
