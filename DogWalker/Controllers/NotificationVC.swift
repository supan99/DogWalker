//
//  NotificationVC.swift
//  DogWalker


import UIKit
class NotificationTVC: UITableViewCell {
    //MARK: Outlet
    
    //MARK: Class Variable
    @IBOutlet weak var vwBack: UIView!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArrivalTime: UILabel!
    @IBOutlet weak var lblExp: UILabel!
    
    
    
    //MARK: Custom Method
    
    func setUpView(){
        self.vwBack.layer.cornerRadius = 8
    }
    
    //MARK: UILifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpView()
    }
    
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }
}

class NotificationVC: UIViewController {

    //MARK: Outlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Class Variable
    var razorpayObj : Razorpay.RazorpayCheckout? = nil
    let razorpayKey = "rzp_test_HCVYCp9beI7gNu"
    var array = [RequestModel]()
    var docID = ""
    
    //MARK: Custom Method
    
    func setUpView(){
        self.applyStyle()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        razorpayObj = RazorpayCheckout.initWithKey(razorpayKey, andDelegate: self)
    }
    
    func applyStyle(){
        self.getData()
    }
    
    //MARK: Action Method
    
    //MARK: Delegates
    
    //MARK: UILifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
  
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }

    
    @IBAction func btnRemoveAll(_ sender : UIButton){
        self.deleteAll()
    }
}

extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVC") as! NotificationTVC
        let data = self.array[indexPath.row]
        cell.lblName.text = data.user_name
        cell.lblExp.text = data.exp
        cell.lblPrice.text = "$"+data.price
        cell.lblHours.text = data.hrs
        cell.lblArrivalTime.text = data.availablity
        cell.btnCancel.addAction(for: .touchUpInside) {
            self.delete(dataID: data.docID)
        }
        
        cell.btnPay.addAction(for: .touchUpInside) {
            self.docID = data.docID
            let price = Float(data.price)! * 100.00
            let options: [String:Any] = ["amount" : price.description,
                                         "description" : "Booking Walker",
                                         "image": UIImage(named: "img"),
                                         "name" : data.user_name,
                                         "prefill" :
                                            ["contact" : "9632587410",
                                             "email":GFunction.userOwner.email],
                                         "theme" : "#F00000",
                                         "currency": "USD"
            ]
            
            if let rzp = self.razorpayObj {
                rzp.open(options)
            } else {
                print("Unable to initialize")
            }
        }
        return cell
    }
}


extension NotificationVC : RazorpayPaymentCompletionProtocol {
    func onPaymentError(_ code: Int32, description str: String) {
        print("error: ", code, str)
        Alert.shared.showAlert(message: str, completion: nil)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        self.delete(dataID: self.docID)
    }
    
    func getData(){
        AppDelegate.shared.database.collection(dDogOwner).document(GFunction.userOwner.docID).collection(dWalkerRequest).addSnapshotListener{querySnapshot , error in
            
            guard let snapshot = querySnapshot else {
                print("Error")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if  let available: String = data1["availablity"] as? String,
                        let exp: String = data1[dExp] as? String,
                        let hrs: String = data1["hrs"] as? String,
                        let price: String = data1["price"] as? String,
                        let userName: String = data1[dUser_name] as? String
                            
                    {
                    print("Data Count : \(self.array.count)")
                    self.array.append(RequestModel(docID: data.documentID, availablity: available, user_name: userName, price: price, hrs: hrs, exp: exp))
                    
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                }
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func delete(dataID: String) {
        let ref =  AppDelegate.shared.database.collection(dDogOwner).document(GFunction.userOwner.docID).collection(dWalkerRequest).document(dataID)
        ref.delete(){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                self.getData()
            }
        }
    }
    
    func deleteAll(){
        for data in array {
            let ref =  AppDelegate.shared.database.collection(dDogOwner).document(GFunction.userOwner.docID).collection(dWalkerRequest).document(data.docID)
            ref.delete(){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
