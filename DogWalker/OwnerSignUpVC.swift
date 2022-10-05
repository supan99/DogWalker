//
//  SignUpVC.swift
//  DogWalker


import UIKit

@available(iOS 15.0.0, *)
class OwnerSignUpVC: UIViewController, UINavigationControllerDelegate {

    //MARK: Outlet
    @IBOutlet weak var imgProfile: RoundedImageView!
    @IBOutlet weak var imgCamera: UIImageView!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var txtname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtAge: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRePassword: UITextField!
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
        let tap = UITapGestureRecognizer()
        tap.addAction {
            self.openCameraOptions()
        }
        self.imgCamera.isUserInteractionEnabled = true
        self.imgCamera.addGestureRecognizer(tap)
        
        self.txtAddress.delegate = self
    }
    
    func applyStyle(){
        self.tvDescription.layer.cornerRadius = 8
        self.tvDescription.text = "Description"
        self.tvDescription.textColor = UIColor.lightGray
    }
    
    private func validation(name: String, email:String, age:String, address:String, description:String, password:String, confirmPass:String ) -> String {
        if name.isEmpty{
            return STRING.errorName
        }else if email.isEmpty{
            return STRING.errorEmail
        }else if !Validation.isValidEmail(email){
            return STRING.errorValidEmail
        }else if age.isEmpty{
            return STRING.errorAge
        }else if address.isEmpty {
            return STRING.errorAddress
        }else if description.isEmpty {
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
    
    //MARK: Action Method
    
    @IBAction func btnRegisterClick(_ sender: UIButton) {
        if sender == btnRegister {
            let error = self.validation(name: self.txtname.text?.trim() ?? "", email: self.txtEmail.text?.trim() ?? "", age: self.txtAge.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "", description: self.txtDescription.text.trim() , password: self.txtPassword.text?.trim() ?? "" , confirmPass: self.txtRePassword.text ?? "")
            
            if error.isEmpty {
                self.uploadImagePic(img1: self.img, name: self.txtname.text?.trim() ?? "", email: self.txtEmail.text?.trim() ?? "", age: self.txtAge.text?.trim() ?? "", address: self.txtAddress.text?.trim() ?? "", description: self.txtDescription.text.trim() , password: self.txtPassword.text?.trim() ?? "")
            }else{
                Alert.shared.showAlert(message: error, completion: nil)
            }
        }else if sender == btnRegisterWithApple {
            
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
extension OwnerSignUpVC: UITextViewDelegate {
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


@available(iOS 15.0.0, *)
//MARK:- Extension for Login Function
extension OwnerSignUpVC {
    
    func firebaseRegister(name: String, email: String, age: String, password: String, address: String,description:String, profile: String) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            if error != nil {
                Alert.shared.showAlert(message: error?.localizedDescription.description ?? "", completion: nil)
            }else{
                let uid = authResult?.user.uid ?? ""
                self.createAccount(name: name, email: email, age: age, password: password, address: address, description: description, profile: profile, uid: uid)
            }
        }
    }
    
    func createAccount(name: String, email: String, age: String, password: String, address: String,description:String, profile: String,uid: String) {
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.database.collection(dDogOwner).addDocument(data:
                                                                    [
                                                                        dUser_id: uid,
                                                                        "id": uid,
                                                                        dUser_address: address,
                                                                        dUser_email: email,
                                                                        dUser_name: name,
                                                                        dUser_password : password,
                                                                        dUser_age:  age,
                                                                        dUser_description: description,
                                                                        dUser_image: profile,
                                                                        dIsEnable: true,
                                                                        dIsReserved: false,
                                                                        dLat: self.location.latitude,
                                                                        dLng: self.location.longitude
                                                                    ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                GFunction.userOwner = UserOwnerModel(docID: ref!.documentID, name: name, email: email, password: password, userType: UserType.Owner.getname(), isEnable: true, description: description, profile: profile, address: address, age: age)
                GFunction.shared.firebaseRegister(data: email, password: password)
                Alert.shared.showAlert(message: "Success", completion: nil)
                self.flag = true
            }
        }
    }
}


//MARK:- UIImagePickerController Delegate Methods
@available(iOS 15.0.0, *)
extension OwnerSignUpVC: UIImagePickerControllerDelegate, OpalImagePickerControllerDelegate {
    func uploadImagePic(img1 :UIImage, name: String, email:String, age:String, address:String, description:String, password:String){
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
                self.isImageSelected = true
                self.imageURL = url?.absoluteString ?? ""
                print(url?.absoluteString) // <- Download URL
               
                self.firebaseRegister(name: name, email: email, age: age, password: password, address: address, description: description, profile: self.imageURL)

            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        if let image = info[.editedImage] as? UIImage {
            self.img = image
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
extension OwnerSignUpVC: UITextFieldDelegate {
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
