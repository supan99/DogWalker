//
//  LoginVC.swift
//  DogWalker
//

import UIKit

@available(iOS 15.0.0, *)
class LoginVC: UIViewController {
    //MARK: Outlet
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblTerm: UILabel!
    @IBOutlet weak var btnApple: RoundedCornerButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    
    //MARK: Class Variable
    var userType: UserType?
    var flag = true
    private let socialLoginManager: SocialLoginManager = SocialLoginManager()
    
    //MARK: Custom Method
    
    func setUpView(){
        self.applyStyle()
        
        self.lblTerm.isHidden = self.userType == .Owner
        self.socialLoginManager.delegate = self
        self.btnApple.isHidden = self.userType == .Admin
        self.btnSignUp.isHidden = self.userType == .Admin
        self.btnForgotPassword.isHidden = self.userType == .Admin
    }
    
    func applyStyle(){
        
    }
    
    //MARK: Action Method
    @IBAction func btnCreateAccountTapped(_ sender: UIButton) {
        if sender == btnApple {
            self.socialLoginManager.performAppleLogin()
        }else {
            if self.userType == .Owner {
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OwnerSignUpVC") as! OwnerSignUpVC
                self.navigationController?.pushViewController(nextVC, animated: true)
            } else if self.userType == .Walker {
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalkerSignUpVC") as! WalkerSignUpVC
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
        }
    }
    
    @IBAction func btnForgotPasswordTapped(_ sender: UIButton) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgetPasswordVC") as! ForgetPasswordVC
        nextVC.modalPresentationStyle = .overFullScreen
        self.present(nextVC, animated: true)
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        let error = self.validation(email: self.txtEmail.text?.trim() ?? "", password: self.txtPassword.text?.trim() ?? "")
        if error.isEmpty {
            self.flag = false
            if self.txtEmail.text?.trim() == "Admin@gmail.com" && self.txtPassword.text?.trim() == "Admin@1234" && self.userType == .Admin{
                if let vc = UIStoryboard.main.instantiateViewController(withClass: AdminVC.self){
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else if self.userType == .Walker{
                self.firebaseLogin(data: self.txtEmail.text?.trim() ?? "", password: self.txtPassword.text?.trim() ?? "", userType: self.userType?.getname().description ?? "admin")
            }else if self.userType == .Owner{
                self.firebaseLogin(data: self.txtEmail.text?.trim() ?? "", password: self.txtPassword.text?.trim() ?? "", userType: self.userType?.getname().description ?? "admin")
            }else{
                Alert.shared.showAlert(message: "Please check admin credentials !!!", completion: nil)
            }
        }else{
            Alert.shared.showAlert(message: error, completion: nil)
        }
    }
    
    //MARK: Delegates
    
    //MARK: UILifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.hexStringToUIColor(hex: "#2D3655")
    }
    
    deinit {
        debugPrint("‼️‼️‼️ deinit : \(self) ‼️‼️‼️")
    }
    
    private func validation(email:String, password:String) -> String {
        if email.isEmpty {
            return STRING.errorEmail
        }else if !Validation.isValidEmail(email) {
            return STRING.errorValidEmail
        }else if password.isEmpty {
            return STRING.errorPassword
        }
        
        return ""
    }
    
    
    func firebaseLogin(data: String, password: String,userType: String){
        FirebaseAuth.Auth.auth().signIn(withEmail: data, password: password) { [weak self] authResult, error in
            guard self != nil else { return }
            
            if self?.userType == .Owner {
                self?.loginUser(email: data, password: password, userType: userType)
            }else {
                self?.loginWalkerUser(email: data, password: password, userType: userType)
            }
        }
    }
    
    func loginWalkerUser(email:String,password:String,userType:String) {
        let type = self.userType == .Owner ? dDogOwner : dDogWalker
        _ = AppDelegate.shared.database.collection(type).whereField(dUser_email, isEqualTo: email).whereField(dPassword, isEqualTo: password).whereField(dType, isEqualTo: userType).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.documents.count != 0 {
                let data1 = snapshot.documents[0].data()
                let docId = snapshot.documents[0].documentID
                if  let name: String = data1[dUser_name] as? String,
                    let isEnable: Bool = data1[dIsEnable] as? Bool,
                    let exp: String = data1[dExp] as? String,
                    let email: String = data1[dUser_email] as? String,
                    let password: String = data1[dPassword] as? String,
                    let hourlyRate: String = data1[dUser_hourly_rate] as? String,
                    let userType: String = data1[dType] as? String,
                    let timing: String = data1[dTiming] as? String,
                    let from: String = data1[dTimingFrom] as? String,
                    let to: String = data1[dTimingTo] as? String,
                    let description: String = data1[dUser_description] as? String,
                    let lat: Double = data1[dLat] as? Double,
                    let lng: Double = data1[dLng] as? Double,
                    let profile: String = data1[dUser_image] as? String,
                    let rating: Double = data1[dRating] as? Double,
                    let reserved: Bool = data1[dIsReserved] as? Bool
                {
                if isEnable {
                    GFunction.userWalker = UserWalkerModel(docID: docId, name: name, experience: exp, email: email, password: password, hourlyRate: hourlyRate, userType: userType, timing: timing, from: from, to: to, isEnable: isEnable, description: description,lat: lat,lng: lng,profile: profile, rating: rating,reserved: reserved, isFavourite: false)
                    GFunction.shared.firebaseRegister(data: email, password: password)
                    UIApplication.shared.setWalkerTab()
                }else{
                    Alert.shared.showAlert(message: "Please contact to admin !!!", completion: nil)
                }
            }
                
            }else{
                if !self.flag {
                    Alert.shared.showAlert(message: "Please check your credentials !!!", completion: nil)
                    self.flag = true
                }
            }
        }
        
    }
    
    func loginUser(email:String,password:String,userType:String) {
        let type = self.userType == .Owner ? dDogOwner : dDogWalker
        _ = AppDelegate.shared.database.collection(type).whereField(dUser_email, isEqualTo: email).whereField(dUser_password, isEqualTo: password).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.documents.count != 0 {
                let data1 = snapshot.documents[0].data()
                let docId = snapshot.documents[0].documentID
                if  let name: String = data1[dUser_name] as? String,
                    let email: String = data1[dUser_email] as? String,
                    let password: String = data1[dUser_password] as? String,
                    let description: String = data1[dUser_description] as? String,
                    let isEnable: Bool = data1[dIsEnable] as? Bool,
                    let profile: String = data1[dUser_image] as? String,
                    let address: String = data1[dUser_address] as? String,
                    let age: String = data1[dUser_age] as? String
                {
                if isEnable {
                    GFunction.userOwner = UserOwnerModel(docID: docId, name: name, email: email, password: password, userType: userType, isEnable: isEnable, description: description, profile: profile, address: address, age: age)
                    GFunction.shared.firebaseRegister(data: email, password: password)
                    UIApplication.shared.setOwnerTab()
                }else{
                    Alert.shared.showAlert(message: "Please contact to admin !!!", completion: nil)
                }
                
                }
                
            }else{
                if !self.flag {
                    Alert.shared.showAlert(message: "Please check your credentials !!!", completion: nil)
                    self.flag = true
                }
            }
        }
        
    }
}

@available(iOS 15.0.0, *)
extension LoginVC: SocialLoginDelegate {
    
    func socialLoginData(data: SocialLoginDataModel) {
        print("Social Id==>", data.socialId ?? "")
        print("First Name==>", data.firstName ?? "")
        print("Last Name==>", data.lastName ?? "")
        print("Email==>", data.email ?? "")
        print("Login type==>", data.loginType ?? "")
        self.loginUser(email: data.email, password: data.socialId,userType: self.userType?.getname() ?? "")
    }
}



