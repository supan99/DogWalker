//
//  WalkerSignUpVC.swift
//  DogWalker


import UIKit
import FirebaseAuth

@available(iOS 15.0.0, *)
class WalkerSignUpVC: UIViewController, UINavigationControllerDelegate {

    //MARK: Outlet
    @IBOutlet weak var imgCamera: UIImageView!
    @IBOutlet weak var imgProfile: RoundedImageView!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtExp: UITextField!
    @IBOutlet weak var txtHours: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnDaily: UIButton!
    @IBOutlet weak var btnSpan: UIButton!
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    @IBOutlet weak var txtTiming: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRePassword: UITextField!
    @IBOutlet weak var stTiming: UIStackView!
    @IBOutlet weak var btnRegister: RoundedCornerButton!
    @IBOutlet weak var btnRegisterWithApple: RoundedCornerButton!
    
    //MARK: Class Variable
    var flag = true
    var imgPicker = UIImagePickerController()
    var imgPicker1 = OpalImagePickerController()
    var isImageSelected : Bool = false
    var imageURL = ""
    var img = UIImage()
    var location:CLLocationCoordinate2D!
    
    //MARK: Custom Method
    
    func setUpView(){
        self.applyStyle()
        self.tvDescription.delegate = self
        self.txtAddress.delegate = self
    }
    
    func applyStyle(){
        self.tvDescription.layer.cornerRadius = 8
        self.tvDescription.text = "Description"
        self.tvDescription.textColor = UIColor.lightGray
        
        let tap = UITapGestureRecognizer()
        tap.addAction {
            self.openCameraOptions()
        }
        self.imgCamera.isUserInteractionEnabled = true
        self.imgCamera.addGestureRecognizer(tap)
        
        self.stTiming.isHidden = true
        self.btnDaily.isSelected = true
    }
    
    func openCameraOptions(){
        
        let actionSheet = UIAlertController(title: nil, message: "Select Image", preferredStyle: .actionSheet)
        
        let cameraPhoto = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return Alert.shared.showAlert(message: "Camera not Found", completion: nil)
            }
            GFunction.shared.isGiveCameraPermissionAlert(self) { (isGiven) in
                if isGiven {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.imgPicker.mediaTypes = ["public.image"]
                        self.imgPicker.sourceType = .camera
                        self.imgPicker.cameraDevice = .rear
                        self.imgPicker.allowsEditing = true
                        self.imgPicker.delegate = self
                        self.present(self.imgPicker, animated: true)
                    }
                }
            }
        })
        
        let PhotoLibrary = UIAlertAction(title: "Gallary", style: .default, handler:
                                            { [self]
            (alert: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let photos = PHPhotoLibrary.authorizationStatus()
                if photos == .denied || photos == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({status in
                        if status == .authorized {
                            DispatchQueue.main.async {
                                self.imgPicker1 = OpalImagePickerController()
                                self.imgPicker1.imagePickerDelegate = self
                                self.imgPicker1.isEditing = true
                                present(self.imgPicker1, animated: true, completion: nil)
                            }
                        }
                    })
                }else if photos == .authorized {
                    DispatchQueue.main.async {
                        self.imgPicker1 = OpalImagePickerController()
                        self.imgPicker1.imagePickerDelegate = self
                        self.imgPicker1.isEditing = true
                        present(self.imgPicker1, animated: true, completion: nil)
                    }
                    
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            
        })
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        actionSheet.addAction(cameraPhoto)
        actionSheet.addAction(PhotoLibrary)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    private func validation(name: String, email:String, exp:String, hourlyRate:String,isDaily: Bool ,description:String, password:String, confirmPass:String, timing: String, from:String, to: String, address: String) -> String {
        if !self.isImageSelected{
            return STRING.errorProfile
        }else if name.isEmpty{
            return STRING.errorName
        }else if email.isEmpty{
            return STRING.errorEmail
        }else if !Validation.isValidEmail(email){
            return STRING.errorValidEmail
        }else if exp.isEmpty{
            return STRING.errorExp
        }else if hourlyRate.isEmpty {
            return STRING.errorHourlyRate
        }else if isDaily {
            if timing.isEmpty {
                return STRING.errorTiming
            }
        } else if isDaily == false {
            if from.isEmpty {
                return STRING.errorTimingFrom
            }else if to.isEmpty {
                return STRING.errorTimingTo
            }
        }else if address.isEmpty {
            return "Please select address"
        } else if description.isEmpty {
            return STRING.errorDescription
        }else if password.isEmpty {
            return STRING.errorPassword
        } else if password.count < 8 {
            return STRING.errorPasswordCount
        } else if !Validation.isValidPassword(password) {
            return STRING.errorValidCreatePassword
        } else if confirmPass.isEmpty {
            return STRING.errorConfirmPassword
        } else if password != confirmPass {
            return STRING.errorPasswordMismatch
        }
        
        return ""
        
    }
    
    //MARK: Action Method
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnRegister {
            let error = self.validation(name: self.txtName.text?.trim() ?? "", email: self.txtEmail.text?.trim() ?? "", exp: self.txtExp.text?.trim() ?? "",hourlyRate: self.txtHours.text?.trim() ?? "",isDaily: self.btnDaily.isSelected, description: self.txtDescription.text.trim(), password: self.txtPassword.text?.trim() ?? "",confirmPass: self.txtRePassword.text?.trim() ?? "", timing: self.txtTiming.text?.trim() ?? "", from: self.txtFrom.text?.trim() ?? "", to: self.txtTo.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "")
            
            if error.isEmpty {
                self.uploadImagePic(img1: self.img, name: self.txtName.text?.trim() ?? "", email: self.txtEmail.text?.trim() ?? "", exp: self.txtExp.text?.trim() ?? "",hourlyRate: self.txtHours.text?.trim() ?? "",isDaily: self.btnDaily.isSelected, description: self.txtDescription.text.trim(), password: self.txtPassword.text?.trim() ?? "", timing: self.txtTiming.text?.trim() ?? "", from: self.txtFrom.text?.trim() ?? "", to: self.txtTo.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "")
            }else{
                Alert.shared.showAlert(message: error, completion: nil)
            }
        }else if sender == btnRegisterWithApple {
            
        }else if sender == btnDaily {
            sender.isSelected = true
            self.btnSpan.isSelected = !sender.isSelected
            self.stTiming.isHidden = true
        }else if sender == btnSpan {
            sender.isSelected = true
            self.btnDaily.isSelected = !sender.isSelected
            self.stTiming.isHidden = false
        }
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        Alert.shared.showAlert("", actionOkTitle: "Logout", actionCancelTitle: "Cancel", message: "Are you sure you want to logout?") { Bool in
            if Bool {
                UIApplication.shared.setStart()
            }
        }
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

@available(iOS 15.0.0, *)
extension WalkerSignUpVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
}


//MARK:- Extension for Login Function
@available(iOS 15.0.0, *)
extension WalkerSignUpVC {
    
    
    func firebaseRegister(name: String, email:String, exp:String, hourlyRate:String,isDaily: Bool ,description:String, password:String, timing: String, from:String, to: String, profile: String, address: String) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            if error != nil {
                Alert.shared.showAlert(message: error?.localizedDescription.description ?? "", completion: nil)
            }else{
                let uid = authResult?.user.uid ?? ""
                self.createAccount(name: name, email:email, exp:exp, hourlyRate:hourlyRate, isDaily: isDaily ,description:description, password:password, timing: timing, from:from, to: to, profile: profile, uid: uid, address: address)
            }
        }
    }
    
    
    func createAccount(name: String, email:String, exp:String, hourlyRate:String,isDaily: Bool ,description:String, password:String, timing: String, from:String, to: String, profile: String, uid: String, address: String) {
        AppDelegate.shared.database.collection(dDogWalker).document(uid).setData([
            "id": uid,
            dUser_id: uid,
            dExp: exp,
            dIsEnable: true,
            dLat: self.location.latitude,
            dLng : self.location.longitude,
            dAddress: address,
            dPassword:  password,
            dRating: 0.0,
            dIsReserved: false,
            dTiming: timing,
            dTimingFrom: from.isEmpty ? "daily" : from,
            dTimingTo: to.isEmpty ? "daily" : to,
            dType: UserType.Walker.getname(),
            dUser_description: description,
            dUser_email: email,
            dUser_hourly_rate: hourlyRate,
            dUser_image: profile,
            dUser_name: name,
        ], completion: { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                GFunction.userWalker = UserWalkerModel(docID: uid, name: name, experience: exp, email: email, password: password, hourlyRate: hourlyRate, userType: UserType.Walker.getname(), timing: timing, from: from, to: to, isEnable: true, description: description, lat: -1.2975733, lng: 36.871645, profile: profile, rating: 0.0, reserved: false, isFavourite: false)
                UIApplication.shared.setWalkerTab()
                self.flag = true
            }
        })
    }
}


//MARK:- UIImagePickerController Delegate Methods
@available(iOS 15.0.0, *)
extension WalkerSignUpVC: UIImagePickerControllerDelegate, OpalImagePickerControllerDelegate {
    func uploadImagePic(img1 :UIImage, name: String, email:String, exp:String, hourlyRate:String,isDaily: Bool ,description:String, password:String, timing: String, from:String, to: String, address: String ){
        let data = img1.jpegData(compressionQuality: 0.8)! as NSData
        // set upload path
        let imagePath = GFunction.shared.UTCToDate(date: Date())
        let filePath = "profile_images/\(imagePath)" // path where you wanted to store img in storage
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        let storageRef = Storage.storage().reference(withPath: filePath)
        storageRef.putData(data as Data, metadata: metaData) { (metaData, error) in
            if let error = error {
                return
            }
            storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                self.imageURL = url?.absoluteString ?? ""
                print(url?.absoluteString) // <- Download URL
                
                self.firebaseRegister(name: name, email:email, exp:exp, hourlyRate:hourlyRate, isDaily: isDaily ,description:description, password:password, timing: timing, from:from, to: to, profile: self.imageURL, address: address)
                
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        if let image = info[.editedImage] as? UIImage {
            self.img = image
            self.isImageSelected = true
            self.imgProfile.image = image
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        do { picker.dismiss(animated: true) }
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingAssets assets: [PHAsset]){
        for image in assets {
            if let image = getAssetThumbnail(asset: image) as? UIImage {
                self.img = image
                self.imgProfile.image = image
                self.isImageSelected = true
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: (asset.pixelWidth), height: ( asset.pixelHeight)), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func imagePickerDidCancel(_ picker: OpalImagePickerController){
        dismiss(animated: true, completion: nil)
    }
}

@available(iOS 15.0.0, *)
extension WalkerSignUpVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtAddress {
            let nextVC = MapViewVC.instantiate(fromAppStoryboard: .main)
            nextVC.modalPresentationStyle = .overFullScreen
            
            nextVC.doneCompletion = { location, address in
                self.txtAddress.text = address
                self.location = location
            }
            
            self.present(nextVC, animated: true)
            return false
        }
        return true
    }
}
