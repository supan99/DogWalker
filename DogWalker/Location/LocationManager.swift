//
//  LocationManager.swift

import UIKit
import CoreLocation
import GoogleMaps

@objc protocol LocationManagerDelegate {
    @objc optional func didUpdateLocation(locations: CLLocation)
    @objc optional func didUpdateLocationOnAppDidBecomeActive(locations: CLLocation)
    @objc optional func didChangeAuthorizationStatus(status: CLAuthorizationStatus)
}

enum LocationAccuracyType{
    case forcePreciseOn,`default`
}

class LocationManager: NSObject , CLLocationManagerDelegate {
    
    static let shared : LocationManager = LocationManager()
    
    var location            : CLLocation = CLLocation()
    var locationManager     : CLLocationManager = CLLocationManager()
    var delegate: LocationManagerDelegate?
    var isNotifyOnLocationOff: Bool = true
    var locationType: LocationAccuracyType = .default
    
    //---------------------------------------------------------------------
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(LocationManager.didBecomeActiveNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    //MARK: - Current Lat Long
    
    //TODO: To get location permission just call this method
    func getLocation(with locationType: LocationAccuracyType = .default) {
        //Set location type required by the app
        self.locationType = locationType
        
        //Change accuracy based on app type & requirement
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    //TODO: To get permission is allowed or declined
    func checkStatus() -> CLAuthorizationStatus{
        return CLLocationManager.authorizationStatus()
    }
    
    //TODO: To get user's current location
    func getUserLocation() -> CLLocation {
        if isNotifyOnLocationOff && !self.isLocationServiceEnabled() {
            return CLLocation(latitude: 45.452377830414086, longitude: -73.59100606438005)
        }
        
        if location.coordinate.longitude == 0.0 {
            return CLLocation(latitude: 45.452377830414086, longitude: -73.59100606438005)
            // return CLLocation(latitude: 0.0, longitude: 0.0)
            //            return CLLocation(latitude: 38.751544, longitude: 38.7504604)
        }
        return location
    }
    
    //MARK: Delegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locationFirst = locations.first else {
            return
        }
        location = locationFirst
        
        if let _ = self.delegate {
            self.delegate?.didUpdateLocation?(locations: location)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Changelocation"), object: nil)
        
        
        //TODO: Uncomment the below code to get notified for updated location
        
        //        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"LocationChange"), object: nil)
        //        print("\(location.coordinate.latitude)  Latitude \(location.coordinate.longitude) Longitude")
    }
    
    func isLocationServiceEnabled() -> Bool {
        
        if CLLocationManager.authorizationStatus() == .denied {
            let alertController = UIAlertController(title: "Location Permission Denied", message: "To re-enable, please go to Settings and turn on Location Service for " + "ReminderApp", preferredStyle: .alert)
            
            let setting = UIAlertAction(title: "Go to Settings", style: .default, handler: { (UIAlertAction) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)! as URL)
                }
            })
            
            let close = UIAlertAction(title: "Close", style: .default, handler: { (UIAlertAction) in
                
            })
            
            alertController.addAction(setting)
            //            alertController.addAction(close)
            
            GFunction.shared.getAppWindow()?.rootViewController?.present(alertController, animated: true, completion: nil)
            return false
        }else if CLLocationManager.authorizationStatus() == .notDetermined{
            return CLLocationManager.locationServicesEnabled()
        }else {
            if #available(iOS 14.0, *) {
                let accuracyAuthorization = self.locationManager.accuracyAuthorization
                switch accuracyAuthorization {
                case .fullAccuracy:
                    break
                case .reducedAccuracy:
                    if self.locationType == .forcePreciseOn{
                        let alertController = UIAlertController(title: "Precise Location Required", message: "To re-enable, please go to Settings and turn on precise location service for " + "ReminderApp", preferredStyle: .alert)
                        
                        let setting = UIAlertAction(title: "Go to Settings", style: .default, handler: { (UIAlertAction) in
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
                            } else {
                                // Fallback on earlier versions
                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)! as URL)
                            }
                        })
                        
                        let close = UIAlertAction(title: "Close", style: .default, handler: { (UIAlertAction) in
                            
                        })
                        
                        alertController.addAction(setting)
                        //            alertController.addAction(close)
                        
                        GFunction.shared.getAppWindow()?.rootViewController?.present(alertController, animated: true, completion: nil)
                        return false
                    }
                    break
                }
            } else {
                // Fallback on earlier versions
            }
            
            return true
        }
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let _ = self.delegate {
            self.delegate?.didChangeAuthorizationStatus?(status: status)
        }
        switch status {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        case .denied:
            print("Permission Denied")
            break
        case .notDetermined:
            print("Permission Not Determined")
            break
        case .restricted:
            break
        default:
            print("\(location.coordinate.latitude)")
            print("\(location.coordinate.longitude)")
            break
        }
        
        if #available(iOS 14.0, *) {
            let accuracyAuthorization = manager.accuracyAuthorization
            switch accuracyAuthorization {
            case .fullAccuracy:
                break
            case .reducedAccuracy:
                if self.locationType == .forcePreciseOn{
                    manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "ForRides") { (error) in
                        debugPrint("\(error)")
                    }
                }
                break
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func didBecomeActiveNotification(_ notification: Notification) {
        self.location = self.getUserLocation()
        if let _ = self.delegate {
            self.delegate?.didUpdateLocationOnAppDidBecomeActive?(locations: location)
        }
    }
    
    //TODO: Uncomment below code to get address from location
    
    func getAddressFromLocation(latitude : String , longitude : String , handler : @escaping ((GMSAddress?) -> ())) {
        
        let geocoder = GMSGeocoder()
        
        var location : CLLocation?
        if latitude.isEmpty || longitude.isEmpty {
            
        }else{
            location = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
        }
        
        if let loc = location {
            geocoder.reverseGeocodeCoordinate(loc.coordinate, completionHandler: { (response, error) in
                
                if error == nil{
                    if let res = response?.results(){
                        for address in res {
                            if address.locality != nil {
                                handler(address)
                                return
                            }
                        }
                        handler(nil)
                        debugPrint("not found")
                    }else{
                        handler(nil)
                        debugPrint("not found")
                    }
                }
            })
        }
    }
    
}



//MARK :- CLLocation2D
extension CLLocationCoordinate2D
{
    func getBearing(toPoint point: CLLocationCoordinate2D) -> Double
    {
        func degreesToRadians(degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / Double.pi }
        
        let lat1 = degreesToRadians(degrees: latitude)
        let lon1 = degreesToRadians(degrees: longitude)
        
        let lat2 = degreesToRadians(degrees: point.latitude);
        let lon2 = degreesToRadians(degrees: point.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        let degree = radiansToDegrees(radians: radiansBearing)
        
        if degree >= 0 {
            return degree
        }
        else {
            return 360 + degree
        }
        
        //        return radiansToDegrees(radians: radiansBearing)
    }
    
    func getDistanceMetresBetweenLocationCoordinates(_ cordinate : CLLocationCoordinate2D) -> Double
    {
        let location1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let location2 = CLLocation(latitude: cordinate.latitude, longitude: cordinate.longitude)
        return location1.distance(from: location2)
    }
    
}
extension CLLocationCoordinate2D: Equatable {}
public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
}


extension GFunction {
    func getAppWindow() -> UIWindow? {
        return UIApplication.shared.windows.first ?? nil
    }
}
