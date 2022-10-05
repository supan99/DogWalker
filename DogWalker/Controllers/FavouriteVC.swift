//
//  FavouriteVC.swift
//  DogWalker
//
//  Created by 2021M05 on 01/08/22.
//

import UIKit
class FavouriteTVC: UITableViewCell {
   
    @IBOutlet weak var vwBack: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblExp: UILabel!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblAvailability: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    
    func applyStyle(){
        self.vwBack.layer.cornerRadius = 8
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyStyle()
    }
    
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }
    
    func configCell(data: UserWalkerModel){
        self.lblExp.text = data.experience.description + "Yrs"
        self.lblName.text = data.name.description
        self.lblHours.text = data.hourlyRate.description + "/Hr"
        self.lblAvailability.text = "Availability \(data.timing.description)"
        
        self.imgProfile.setImgWebUrl(url: data.profile, isIndicator: true)
        self.btnLike.setImage(data.isFavourite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)
    }
    
}

class FavouriteVC: UIViewController {

    
    @IBOutlet weak var tblView: UITableView!
    
    var array = [UserWalkerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData(uid: GFunction.userOwner.docID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }

}
extension FavouriteVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavouriteTVC", for: indexPath) as! FavouriteTVC
        cell.configCell(data: self.array[indexPath.row])
        cell.btnLike.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        cell.selectionStyle = .none
        cell.btnLike.tag = indexPath.row
        cell.btnLike.addTarget(self, action: #selector(btnLikeTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func btnLikeTapped(_ sender: UIButton) {
        Alert.shared.showAlert("", actionOkTitle: "Delete", actionCancelTitle: "Cancel", message: "Are you sure you want to remove this walker from favourite list?") { Bool in
            if Bool {
                let data = self.array[sender.tag]
                self.removeFromFav(data: data)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "WalkerDetailsVC") as? WalkerDetailsVC {
            nextVC.data = self.array[indexPath.row]
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func removeFromFav(data: UserWalkerModel){
        let ref = AppDelegate.shared.database.collection(dFavourite).document(data.docID)
        ref.delete(){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                Alert.shared.showAlert(message: "You removed this dog walker from your favourite list") { Bool in
                    if Bool {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func getData(uid: String){
        AppDelegate.shared.database.collection(dFavourite).whereField(dUser_id, isEqualTo: uid).addSnapshotListener{querySnapshot , error in
            
            guard let snapshot = querySnapshot else {
                print("Error")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[dUser_name] as? String, let isEnable: Bool = data1[dIsEnable] as? Bool, let exp: String = data1[dExp] as? String, let email: String = data1[dUser_email] as? String, let hourlyRate: String = data1[dUser_hourly_rate] as? String, let timing: String = data1[dTiming] as? String, let from: String = data1[dTimingFrom] as? String, let to: String = data1[dTimingTo] as? String, let description: String = data1[dUser_description] as? String, let lat: Double = data1[dLat] as? Double, let lng: Double = data1[dLng] as? Double, let profile: String = data1[dUser_image] as? String, let rating: Double = data1[dRating] as? Double, let reserved: Bool = data1[dIsReserved] as? Bool {
                        print("Data Count : \(self.array.count)")
                        self.array.append(UserWalkerModel(docID: data.documentID, name: name, experience: exp, email: email, password: "", hourlyRate: hourlyRate, userType: "", timing: timing, from: from, to: to, isEnable: isEnable, description: description, lat: lat, lng: lng, profile: profile, rating: rating, reserved: reserved, isFavourite: true))
                    }
                    self.tblView.delegate = self
                    self.tblView.dataSource = self
                    self.tblView.reloadData()
                }
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
}
