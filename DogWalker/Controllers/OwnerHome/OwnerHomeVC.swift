//
//  OwnerHomeVC.swift
//  DogWalker

import MapKit
import UIKit
import CoreLocation


class OwnerHomeTVC: UITableViewCell {
   
    @IBOutlet weak var vwBack: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblExp: UILabel!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblAvailability: UILabel!
    
    
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
    }
    
}

class OwnerHomeVC: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnVerifyWalker: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    
    var array = [UserWalkerModel]()
    var arrayData = [UserWalkerModel]()
    var arrDataNearByWalker = [NearByWalkerModel]()
    var arrNearByWalker = [GMSMarker]()
    var locationManager = CLLocationManager()
    var pendingItem: DispatchWorkItem?
    var pendingRequest: DispatchWorkItem?
    
    var selectedLocation = CLLocationCoordinate2D()
    
    //MARK: Action Methods
    @IBAction func showFilter(sender: UIButton) {
        let alert = UIAlertController(title: "Filter", message: "Please Select an Filter", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "A To Z", style: .default , handler:{ (UIAlertAction)in
            self.array = self.array.sorted(by: {($0.name < $1.name)})
            self.tblView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Z To A", style: .default , handler:{ (UIAlertAction)in
            self.array = self.array.sorted(by: {($0.name > $1.name)})
            self.tblView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Low To High", style: .default , handler:{ (UIAlertAction)in
            self.array = self.array.sorted(by: {($0.hourlyRate < $1.hourlyRate)})
            self.tblView.reloadData()
        }))

        alert.addAction(UIAlertAction(title: "High To Low", style: .default , handler:{ (UIAlertAction)in
            self.array = self.array.sorted(by: {($0.hourlyRate > $1.hourlyRate)})
            self.tblView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Reset", style: .default , handler:{ (UIAlertAction)in
            self.array = self.arrayData
            self.tblView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

    
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    @IBAction func btnFavTapped(_ sender: Any) {
        let nextVC = FavouriteVC.instantiate(fromAppStoryboard: .main)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func btnBellTapped(_ sender: Any) {
        let nextVC = NotificationVC.instantiate(fromAppStoryboard: .main)
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

    
    @IBAction func btnLogout(_ sender: Any) {
        Alert.shared.showAlert("", actionOkTitle: "Logout", actionCancelTitle: "Cancel", message: "Are you sure you want to logout?") { Bool in
            if Bool {
                UIApplication.shared.setStart()
            }
        }
    }
    
    
    func setUpView(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.txtSearch.delegate = self
        
        self.perform(#selector(self.setCurrentLocation), with: nil, afterDelay:1.0)
    }
    
    // Set Current Location
    @objc func setCurrentLocation()
    {
        self.mapView.camera = GMSCameraPosition(target: LocationManager.shared.getUserLocation().coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        self.selectedLocation = LocationManager.shared.getUserLocation().coordinate
    }
    
    func setWalkerOnMap(arrWalker: [NearByWalkerModel]){
        self.arrNearByWalker.forEach({$0.map = nil})
        self.arrNearByWalker.removeAll()
        arrWalker.forEach { [weak self] walker in
            guard let self = self else {return}
            if let latitde = walker.latitude, let longitude = walker.longitude {
                let coordinate = CLLocationCoordinate2D(latitude: latitde, longitude: longitude)
                self.setMarkerOnMap(walkerData: coordinate)
            }
        }
    }
    
    func setMarkerOnMap(walkerData : CLLocationCoordinate2D) {
        
        let position = walkerData
        let marker = GMSMarker(position: position)
        marker.userData = walkerData
        marker.icon = UIImage(named: "mapPin")
        marker.map = self.mapView
        
        self.arrNearByWalker.append(marker)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.btnVerifyWalker.layer.cornerRadius = self.btnVerifyWalker.bounds.height/2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }

}

extension OwnerHomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OwnerHomeTVC") as! OwnerHomeTVC
        cell.configCell(data: self.array[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func btnLikeTapped(_ sender: UIButton) {
        self.array[sender.tag].isFavourite.toggle()
        self.tblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "WalkerDetailsVC") as? WalkerDetailsVC {
            nextVC.data = self.array[indexPath.row]
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    func getData(){
        AppDelegate.shared.database.collection(dDogWalker).whereField(dIsEnable, isEqualTo: true).addSnapshotListener{querySnapshot , error in
            
            guard let snapshot = querySnapshot else {
                print("Error")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[dUser_name] as? String, let isEnable: Bool = data1[dIsEnable] as? Bool, let exp: String = data1[dExp] as? String, let email: String = data1[dUser_email] as? String, let password: String = data1[dPassword] as? String, let hourlyRate: String = data1[dUser_hourly_rate] as? String, let userType: String = data1[dType] as? String, let timing: String = data1[dTiming] as? String, let from: String = data1[dTimingFrom] as? String, let to: String = data1[dTimingTo] as? String, let description: String = data1[dUser_description] as? String, let lat: Double = data1[dLat] as? Double, let lng: Double = data1[dLng] as? Double, let profile: String = data1[dUser_image] as? String, let rating: Double = data1[dRating] as? Double, let reserved: Bool = data1[dIsReserved] as? Bool {
                        print("Data Count : \(self.array.count)")
                        self.array.append(UserWalkerModel(docID: data.documentID, name: name, experience: exp, email: email, password: password, hourlyRate: hourlyRate, userType: userType, timing: timing, from: from, to: to, isEnable: isEnable, description: description, lat: lat, lng: lng, profile: profile, rating: rating, reserved: reserved, isFavourite: false))
                        
                        self.arrDataNearByWalker.append(NearByWalkerModel(latitude: lat, longitude: lng, name: name))
                    }
                    self.arrayData = self.array
                    self.tblView.delegate = self
                    self.tblView.dataSource = self
                    self.tblView.reloadData()
                }
                self.setWalkerOnMap(arrWalker: self.arrDataNearByWalker)
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
}
extension OwnerHomeVC:  UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.pendingRequest?.cancel()
        
        guard textField.text != nil else {
            return
        }
        
        if(textField.text?.count == 0){
            self.array = self.arrayData
            self.tblView.reloadData()
            return
        }
        
        //self.isTextEdit = true
        
        self.pendingRequest = DispatchWorkItem{ [weak self] in
            
            guard let self = self else { return }
            
            self.array = self.arrayData.filter({$0.name.localizedStandardContains(textField.text ?? "")})
            self.tblView.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: self.pendingRequest!)
    }
}
