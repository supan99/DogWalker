//
//  WalkerDetailsVC.swift
//  DogWalker

import UIKit

class WalkerDetailsVC: UIViewController {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblHoursRate: UILabel!
    @IBOutlet weak var lblDates: UILabel!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var lblTiming: UILabel!
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnAddToFav: UIButton!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblHrsCount: UILabel!
    
    var datePicker = UIDatePicker()
    var count = 2
    var rate = 25.50
    let toolBar = UIToolbar()
    let toolBar1 = UIToolbar()
    var data: UserWalkerModel!
    var isFav:  Bool = true
    
    func setUpView(){
        self.txtDate.delegate = self
        self.txtTime.delegate = self
        
        self.txtTime.inputView = datePicker
        self.txtDate.inputView = datePicker
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.doneButtonTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.sizeToFit()
        
        let doneButtonTime = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.doneButtonTappedTime))
        let spaceButtonTime = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar1.setItems([spaceButtonTime, doneButtonTime], animated: false)
        toolBar1.sizeToFit()
        
        self.txtDate.inputAccessoryView = toolBar
        self.txtTime.inputAccessoryView = toolBar1
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        self.applyStyle()
    }
    
    func applyStyle(){
        if data != nil {
            self.imgProfile.setImgWebUrl(url: data.profile, isIndicator: true)
            
            self.lblname.text = data.name.description
            self.lblHoursRate.text = "$" + data.hourlyRate.description + "/Hr"
            self.lblDates.text = data.from.description + " To " + data.to.description
            
            self.lblTiming.text = data.timing.description
            self.lblDescription.text = data.description.description
            self.count = 1
            self.rate = Double(data.hourlyRate.trim()) ?? 0.0
            self.lblHrsCount.text = self.count.description + "Hr"
            self.lblTotal.text =  "$" + (self.rate * Double(self.count)).description
            
            self.btnStar.setTitle(data.rating.description, for: .normal)
        }
    }
    
    @objc func doneButtonTapped() {
        self.txtDate.text = GFunction.shared.getDate(datePicker.date, "dd-MM-yyyy hh:mm:ss +0000", output: "dd/MM/yyyy")
        self.txtDate.resignFirstResponder()
    }
    
    @objc func doneButtonTappedTime() {
        self.txtTime.text = GFunction.shared.getDate(datePicker.date, "dd-MM-yyyy hh:mm:ss +0000", output: "hh:mm a")
        self.txtTime.resignFirstResponder()
    }
    
    //MARK: Action Method
    @IBAction func btnCounterClick(_ sender: UIButton) {
        if sender == btnPlus {
            self.count += 1
            self.lblHrsCount.text = self.count.description + "Hr"
            self.lblTotal.text =  "$" + (self.rate * Double(self.count)).description
        }else if sender == btnMinus {
            if self.count > 1 {
                self.count -= 1
            }
            self.lblHrsCount.text = self.count.description + "Hr"
            self.lblTotal.text =  "$" + (self.rate * Double(self.count)).description
        }else if sender == btnContinue {
            let error = self.validation(date: self.txtDate.text?.trim() ?? "", time: self.txtTime.text?.trim() ?? "")
            
            if error.isEmpty {
                let cost = self.rate * Double(self.count)
                self.sendRequest(uid: GFunction.userOwner.docID, data: self.data, time: self.txtTime.text?.trim() ?? "", date: self.txtDate.text?.trim() ?? "", total_cost: cost.description, hrs: count.description)
            }else {
                Alert.shared.showAlert(message: error, completion: nil)
            }
        }else if sender == btnAddToFav {
            self.isFav = false
            self.checkAddToSave(data: self.data, uid: GFunction.userOwner.docID)
        }
    }
    
    func addToFav(data: UserWalkerModel, uid:String) {
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.database.collection(dFavourite).addDocument(data:
                                                                        [
                                                                            dUser_id: uid,
                                                                            dExp: data.experience,
                                                                            dIsEnable: data.isEnable,
                                                                            dLat: data.lat,
                                                                            dLng : data.lng,
                                                                            dRating: data.rating,
                                                                            dIsReserved: data.reserved,
                                                                            dTiming: data.timing,
                                                                            dTimingFrom: data.from,
                                                                            dTimingTo: data.to,
                                                                            dUser_description: description,
                                                                            dUser_email: data.email,
                                                                            dUser_hourly_rate: data.hourlyRate,
                                                                            dUser_image: data.profile,
                                                                            dUser_name: data.name
                                                                        ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                Alert.shared.showAlert(message: "This dog walker has been added into your favourite list!!!") { (true) in
                    UIApplication.shared.setOwnerTab()
                }
            }
        }
    }
    
    
    func checkAddToSave(data: UserWalkerModel, uid:String) {
        _ = AppDelegate.shared.database.collection(dFavourite).whereField(dUser_id, isEqualTo: uid).whereField(dWalker_id, isEqualTo: data.docID).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            if snapshot.documents.count == 0 {
                self.isFav = true
                self.addToFav(data: data,uid: uid)
            }else{
                if !self.isFav {
                    Alert.shared.showAlert(message: "This dog walker has been already existing into Save list!!!", completion: nil)
                }
                
            }
        }
    }
    
    func validation(date: String, time:String) -> String {
        if date.isEmpty {
            return "Please select date"
        }else if time.isEmpty {
            return "Please select time"
        }
        
        return ""
    }
    //MARK: Delegates
    
    //MARK: UILifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = true
    }

    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }

}

extension WalkerDetailsVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtDate {
            self.datePicker.datePickerMode = .date
            self.datePicker.minimumDate = Date()
            return true
        } else if textField == self.txtTime {
            self.datePicker.datePickerMode = .time
            self.datePicker.minimumDate = Date()
            return true
        }
        return true
    }
    
    func sendRequest(uid:String,data: UserWalkerModel,time: String,date: String, total_cost: String, hrs: String) {
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.database.collection(dDogWalker).document(data.docID).collection(dOwnerRequest).addDocument(data:
                                                                                                                                [
                                                                                                                                    dOrderDate: date,
                                                                                                                                    dOrderID: "",
                                                                                                                                    dOrderTime: time,
                                                                                                                                    dStatus : dPending,
                                                                                                                                    dTotal_cost:  total_cost,
                                                                                                                                    dTotal_time: hrs,
                                                                                                                                    dUser_id: uid,
                                                                                                                                    dPaymentStatus: dPending,
                                                                                                                                    dWalker_id: data.docID])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.updateData(dataId: ref!.documentID, data: data)
            }
        }
    }
    
    func updateData(dataId:String,data: UserWalkerModel) {
        let ref = AppDelegate.shared.database.collection(dDogWalker).document(data.docID).collection(dOwnerRequest).document(dataId)
        ref.updateData([
            dOrderID: dataId
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Document successfully updated")
                if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestSentVC") as? RequestSentVC {
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        }
    }
    
    
}
