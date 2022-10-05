//
//  AdminVC.swift
//  DogWalker


import UIKit

class AdminVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        !self.btnOwner.isSelected ? self.arrWalkerData.count : self.arrOwnerData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !self.btnOwner.isSelected {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OwnerCell", for: indexPath) as! OwnerCell
            cell.configCell(data: self.arrWalkerData[indexPath.row])
            let tap = UITapGestureRecognizer()
            tap.addAction {
                let data = self.arrWalkerData[indexPath.row]
                self.userBlock(value: !data.isEnable, dataId: data.docID, type: true)
            }
            cell.btnUser.isUserInteractionEnabled = true
            cell.btnUser.addGestureRecognizer(tap)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalkerCell", for: indexPath) as! WalkerCell
        cell.configCell(data: self.arrOwnerData[indexPath.row])
        let tap = UITapGestureRecognizer()
        tap.addAction {
            let data = self.arrOwnerData[indexPath.row]
            self.userBlock(value: !data.isEnable, dataId: data.docID, type: false)
        }
        cell.btnUser.isUserInteractionEnabled = true
        cell.btnUser.addGestureRecognizer(tap)
        return cell
    }
    

    @IBOutlet weak var btnOwner: UIButton!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var btnWalker: UIButton!
    @IBOutlet weak var lblWalker: UILabel!
    
    @IBOutlet weak var tblList: UITableView!
    
    
    var arrOwnerData = [UserOwnerModel]()
    var arrWalkerData = [UserWalkerModel]()
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnOwner {
            self.btnOwner.isSelected = true
            self.lblOwner.backgroundColor = self.btnOwner.isSelected ? UIColor.hexStringToUIColor(hex: "#A17DDB") : .clear
            
            self.btnWalker.isSelected = false
            self.lblWalker.backgroundColor = self.btnWalker.isSelected ? UIColor.hexStringToUIColor(hex: "#A17DDB") : .clear
            
            self.getWalkerData()
            
        }else if sender == btnWalker {
            self.btnOwner.isSelected = false
            self.lblOwner.backgroundColor = self.btnOwner.isSelected ? UIColor.hexStringToUIColor(hex: "#A17DDB") : .clear
            
            self.btnWalker.isSelected = true
            self.lblWalker.backgroundColor = self.btnWalker.isSelected ? UIColor.hexStringToUIColor(hex: "#A17DDB") : .clear
            
            self.getOwnerData()
        }else{
            UIApplication.shared.setStart()
        }
        
        self.tblList.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getOwnerData()
        self.btnOwner.isSelected = true
        self.lblOwner.backgroundColor = self.btnOwner.isSelected ? UIColor.hexStringToUIColor(hex: "#A17DDB") : .clear
        
        self.btnWalker.isSelected = false
        self.lblWalker.backgroundColor = self.btnWalker.isSelected ? UIColor.hexStringToUIColor(hex: "#A17DDB") : .clear
        // Do any additional setup after loading the view.
    }
}




class OwnerCell: UITableViewCell {
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var btnReservation: UIButton!
    @IBOutlet weak var vwMain: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.vwMain.layer.cornerRadius = 15.0
        DispatchQueue.main.async {
            self.imgProfile.layer.cornerRadius = self.imgProfile.frame.height/2
        }
    }
    
    func configCell(data: UserWalkerModel){
        self.lblID.text = data.docID.description
        self.lblName.text = data.name.description
        self.lblTime.text = "Availability" + data.timing.description
        self.btnStar.setTitle(data.rating.description, for: .normal)
        self.btnUser.isSelected = data.isEnable
        self.btnReservation.isSelected = data.reserved
        self.imgProfile.setImgWebUrl(url: data.profile, isIndicator: true)
    }
}

class WalkerCell: UITableViewCell {
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var vwMain: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.vwMain.layer.cornerRadius = 15.0
        DispatchQueue.main.async {
            self.imgProfile.layer.cornerRadius = self.imgProfile.frame.height/2
        }
    }
    
    func configCell(data: UserOwnerModel){
        self.lblID.text = data.docID
        self.lblName.text = data.name.description
        self.lblTime.text = data.age.description + "Years"
        self.lblAddress.text = data.address.description
        self.btnUser.isSelected = data.isEnable
        self.imgProfile.setImgWebUrl(url: data.profile, isIndicator: true)
    }
}


extension AdminVC {
    func getOwnerData() {
        _ = AppDelegate.shared.database.collection(dDogOwner).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.arrOwnerData.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if  let name: String = data1[dUser_name] as? String,
                        let email: String = data1[dUser_email] as? String,
                        let password: String = data1[dUser_password] as? String,
                        let description: String = data1[dUser_description] as? String,
                        let isEnable: Bool = data1[dIsEnable] as? Bool,
                        let profile: String = data1[dUser_image] as? String,
                        let address: String = data1[dUser_address] as? String,
                        let age: String = data1[dUser_age] as? String
                    {
                    self.arrOwnerData.append(UserOwnerModel(docID: data.documentID, name: name, email: email, password: password, userType: UserType.Owner.getname(), isEnable: isEnable, description: description, profile: profile, address: address, age: age))
                        }
                }
                
                self.tblList.delegate = self
                self.tblList.dataSource = self
                self.tblList.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func getWalkerData() {
        _ = AppDelegate.shared.database.collection(dDogWalker).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.arrWalkerData.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if  let name: String = data1[dUser_name] as? String,
                        let email: String = data1[dUser_email] as? String,
                        let password: String = data1[dPassword] as? String,
                        let type: String = data1[dType] as? String ,
                        let exp: String = data1[dExp] as? String,
                        let hourlyRate: String = data1[dUser_hourly_rate] as? String ,
                        let timing: String = data1[dTiming] as? String,
                        let from: String = data1[dTimingFrom] as? String,
                        let to: String = data1[dTimingTo] as? String,
                        let description: String = data1[dUser_description] as? String,
                        let isEnable: Bool = data1[dIsEnable] as? Bool,
                        let lat: Double = data1[dLat] as? Double,
                        let lng: Double = data1[dLng] as? Double,
                        let profile: String = data1[dUser_image] as? String,
                        let rating: Double = data1[dRating] as? Double,
                        let reserved: Bool = data1[dIsReserved] as? Bool
                    {
                        self.arrWalkerData.append(UserWalkerModel(docID: data.documentID, name: name, experience: exp, email: email, password: password, hourlyRate: hourlyRate, userType: type, timing: timing, from: from, to: to, isEnable: isEnable, description: description,lat: lat,lng: lng,profile: profile, rating: rating,reserved: reserved, isFavourite: false))
                    }
                }
                
                self.tblList.delegate = self
                self.tblList.dataSource = self
                self.tblList.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func userBlock(value:Bool, dataId: String, type: Bool){
        if type {
            let ref = AppDelegate.shared.database.collection(dDogWalker).document(dataId)
            ref.updateData([
                dIsEnable: value
            ]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Document successfully updated")
                    self.getWalkerData()
                }
            }
        }else{
            let ref = AppDelegate.shared.database.collection(dDogOwner).document(dataId)
            ref.updateData([
                dIsEnable: value
            ]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Document successfully updated")
                    self.getOwnerData()
                }
            }
        }
        
    }
}
