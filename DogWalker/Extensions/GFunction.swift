//
//  GFunction.swift


import Foundation
import FirebaseAuth

class GFunction {
    
    static let shared: GFunction = GFunction()
    static var userWalker : UserWalkerModel!
    static var userOwner : UserOwnerModel!

    //Firebase Authentication Login
    func firebaseRegister(data: String,password:String) {
            FirebaseAuth.Auth.auth().signIn(withEmail: data, password: password) { [weak self] authResult, error in
                guard self != nil else { return }
                //return if any error find
                if error != nil {
                    FirebaseAuth.Auth.auth().createUser(withEmail: data, password: password) { authResult, error in
                       // ApiManager.shared.removeLoader()
                        //Return if error find
                        if error != nil {
                            return
                        }else{
                            FirebaseAuth.Auth.auth().signIn(withEmail: data, password: password) { [weak self] authResult, error in
                                guard self != nil else { return }

                            }
                        }
                    }
                }
            }
        }
    
    func UTCToDate(date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "yyyyMMDDHHmmss"
        return formatter.string(from: yourDate!)
    }
    
    func getDate(_ date:Date,_ input: String, output: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = input //"yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: date)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = output //"yyyyMMDDHHmmss"
        return formatter.string(from: yourDate!)
    }
    
    //Permissison for camera check is its not given
    func isGiveCameraPermissionAlert(_ viewController: UIViewController, completion: @escaping ((Bool) -> Void)) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            // Already Authorized
            completion(true)
            
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    completion(true)
                    
                } else {
                    completion(false)
                    print("Disable")
                    
                    var errorMessage : String = ""
                    errorMessage = "Enable to access your camera roll to upload your photos with the app."
                    
                    let permissionAlert = UIAlertController(title: "DogWalker Would like to access your photos?" , message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                    
                    permissionAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        AppDelegate.shared.openLink()
                    }))
                    
                    permissionAlert.addAction(UIAlertAction(title: "Dont Allow", style: .cancel, handler: { (action: UIAlertAction!) in
                        
                    }))
                    
                    DispatchQueue.main.async { [weak self] in
                        guard self != nil else { return }
                        viewController.present(permissionAlert, animated: true, completion: nil)
                    }
                }
            })
        }
    }
}
