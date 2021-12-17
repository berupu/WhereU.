//
//  HomeController.swift
//  WhereU.
//
//  Created by be RUPU on 16/12/21.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire
import SDWebImage

class HomeController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let databaseRef = Database.database().reference()
    let geofire = GeoFire(firebaseRef: Database.database().reference())
    let locationRef = Database.database().reference().child("Users_Location")
    
    let locationManager = CLLocationManager()
    var currentUserLocation = CLLocation()
    let mapView = MKMapView()
    private var route : MKRoute?
    private var selectedAnnoationCoordinate: CLLocationCoordinate2D?
    
    private var zoomToUsersAnnotationCo = [CLLocationCoordinate2D]()
    
    var userLocatioCoordinate :CLLocationCoordinate2D?
    var userDistanceNameInfo = [UserAnnotation]()
    
    let tableView = UITableView()
    private let cellIdentifier = "CellID"
    
    var tableViewPresenter = false

    
    //MARK: - ---------------------------- UI Properties
    
    let logOutButton : UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setImage(UIImage(systemName: "lock.open"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    let userImage: UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .blue
        iv.contentMode = .scaleAspectFill
        iv.frame.size = CGSize(width: 45, height: 45)
        iv.layer.cornerRadius = 45/2
        iv.clipsToBounds = true
        return iv
    }()
    
    let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "figure.stand.line.dotted.figure.stand"), for: .normal)
        button.frame.size = CGSize(width: 45, height: 45)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 45/2
        button.backgroundColor = .lightGray
        button.tintColor = UIColor.black
        button.addTarget(self, action: #selector(handleConnectButton), for: .touchUpInside)
        return button
    }()
    
    let nearByButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "dot.radiowaves.left.and.right"), for: .normal)
        button.addTarget(self, action: #selector(handleNearbyButton), for: .touchUpInside)
        button.tintColor = .black
        button.isHidden = true
        return button
    }()
 
    
    
    
    //MARK: ---------------------------- ViewDidLoad  ⚠️
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        checkIfLoggedIn()
        mapViewCustomUI()
        
    }
    
    
    func mapViewCustomUI(){
        view.addSubview(logOutButton)
        logOutButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingTop: 4, width: 50, height: 50)
        logOutButton.layer.cornerRadius = 25
        
        view.addSubview(nearByButton)
        nearByButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 4, width: 50, height: 50)
        nearByButton.layer.cornerRadius = 25

    }
    
    //MARK: - -------------------------------Selector
    
    @objc func handleLogout(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "LogOut", style: .destructive, handler: { (_) in
            
            do{
                try Auth.auth().signOut()
                
                let loginController = LogInController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
            } catch {
                print("Failed to LogOut")
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    @objc func handleConnectButton(){
        
        
        
    }
    
    @objc func handleNearbyButton(){
        
        
       
        
    }
    
    
    
    func checkIfLoggedIn(){
        if Auth.auth().currentUser != nil {
            enableLocationService()
            configureMapView()
        }else {
            let nav = UINavigationController(rootViewController: LogInController())
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        }
    }
    
    func signOut(){
        
        do{
            try Auth.auth().signOut()
        }catch{
            print("failed to SIGNOUT")
        }
    }
    

    private func configureMapView(){
        enableLocationService()
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.frame = view.frame
        mapView.userTrackingMode = .follow
        zoomToUserLocation()
    }
    
    func enableLocationService(){
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
       
        case .notDetermined:
            print("Not Determined")
            
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
            
        case .denied:
            print("denied")
            
        case .authorizedAlways:
            print("authorizedAlways")
            
//            locationManager.startUpdatingLocation()
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .denied {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
}


    //MARK: - ------------------------------------------Map Functionality.

extension HomeController {
    
    private func zoomToUserLocation(){
        
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: false)
            
            zoomToUsersAnnotationCo.append(userLocation)
            userLocatioCoordinate = userLocation
            
        }
    
    }
}
