//
//  MapViewVC.swift
//  DogWalker
//
//

import UIKit
import CoreLocation

class MapViewVC: UIViewController {

    //MARK: Outlet
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var currentLocationMarker: UIImageView!
    @IBOutlet weak var txtAddress: UITextField!
    
    //MARK: Class Variable
    var selectedLocation = CLLocationCoordinate2D()
    var address = ""
    
    var doneCompletion : ((_ location: CLLocationCoordinate2D, _ address: String) -> Void) = {_,_ in}
    
    //MARK: Custom Method
    
    func setUpView(){
        self.applyStyle()
        self.mapView.delegate = self
        self.perform(#selector(self.setCurrentLocation), with: nil, afterDelay:1.0)
    }
    
    // Set Current Location
    @objc func setCurrentLocation()
    {
        self.mapView.camera = GMSCameraPosition(target: LocationManager.shared.getUserLocation().coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        self.selectedLocation = LocationManager.shared.getUserLocation().coordinate
        self.getLocationAddressFromLatLong(position: self.selectedLocation)
    }
    
    func applyStyle(){
        
    }
    
    //MARK: Action Method
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        self.doneCompletion(selectedLocation,self.address)
        self.dismiss(animated: true)
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

extension MapViewVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
    {
        self.selectedLocation = position.target
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.getLocationAddressFromLatLong(position: position.target)
    }
}

//MARK: Google Map Methods
extension MapViewVC {
    func getLocationAddressFromLatLong(position: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(position) { response, error in
            //
            if error != nil {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            } else {
                if let places = response?.results() {
                    if let place = places.first {
                        
                        
                        if let lines = place.lines {
                            print("GEOCODE: Formatted Address: \(lines)")
                            self.address = lines.joined(separator: ", ")
                            self.txtAddress.text = self.address
                        }
                        
                    } else {
                        print("GEOCODE: nil first in places")
                    }
                } else {
                    print("GEOCODE: nil in places")
                }
            }
        }
    }
}
