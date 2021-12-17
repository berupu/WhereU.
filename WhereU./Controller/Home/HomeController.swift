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
        userAnnotaion()
        configureTableView()
        
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
        
        
        for poly in mapView.overlays {
            mapView.removeOverlay(poly)
        }
                
        guard let latitude = selectedAnnoationCoordinate?.latitude else {return}
        guard let longitude = selectedAnnoationCoordinate?.longitude else {return}
        
        let coordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)
        
    }
    
    @objc func handleNearbyButton(){
        
        if tableViewPresenter {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .curveLinear, animations: {
                self.tableView.frame = CGRect(x: 0, y: self.view.frame.height - self.view.frame.width, width: self.view.frame.width, height: self.view.frame.height)
            }) { _ in
                self.tableViewPresenter.toggle()
            }
        }else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.tableView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            }) { _ in
                self.tableViewPresenter.toggle()
            }
        }
       
        
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
    
}


    //MARK: - ------------------------------------------Map Functionality.

extension HomeController {
    
    private func zoomToUserLocation(){
        
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: false)
            
            zoomToUsersAnnotationCo.append(userLocation)
            userLocatioCoordinate = userLocation
            ZoomRadius()
        }
    
    }
    
    func ZoomRadius(){
        guard let userLocation = locationManager.location?.coordinate else {return}
        
        let region = CLCircularRegion(center: userLocation, radius: 1000, identifier: "CircularRadius ID")
        locationManager.startMonitoring(for: region)

        
        print("DEBUG: did set region\(region)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
       /* let currentLocation = mapView.userLocation.location
        currentLocation?.distance(from: )
        */
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        
        /*let pins = mapView.annotations
        let currentLocation = mapView.userLocation.location!

        let nearestPin: MKAnnotation? = pins.reduce((CLLocationDistanceMax, nil)) { (nearest, pin) in
            let coord = pin.coordinate
            let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = currentLocation.distance(from: loc)
            return distance < nearest.0 ? (distance, pin) : nearest
        }.1
 
        */
    }
    

    
    
    func ZoomBetweenUsers(selectedCoordinate: [CLLocationCoordinate2D]){
        
          let firstPoint = zoomToUsersAnnotationCo[0]
          let secondPoint = zoomToUsersAnnotationCo[1]

          let midPointLat = (firstPoint.latitude + secondPoint.latitude) / 2
          let midPointLong = (firstPoint.longitude + secondPoint.longitude) / 2
          
          let location = CLLocationCoordinate2D(latitude: midPointLat, longitude: midPointLong)
        
          let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
          mapView.setRegion(viewRegion, animated: false)
         
        zoomToUsersAnnotationCo.removeLast()
    }
    
    
    
    //everytime location will get updated when it changed.
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        databaseRef.child("Users").observeSingleEvent(of: .value) { [self] (snapshot) in
        guard let dictionary = snapshot.value as? [String : AnyObject] else {return}
        
         dictionary.forEach { (key,value) in
            let user = User(dictionary: value as! [String : Any])
            
            if user.uid == currentUser{
                
                guard let userName = user.username else {return}
                guard let uID = user.uid else {return}
                guard let profileImageURL = user.profileImageUrl else {return}
                let values = ["username": userName,
                              "uid": uID,
                              "profileImageUrl": profileImageURL,
                              "latitude": latitude as Any, "longitude": longitude as Any] as [String : Any]
                
                
                locationRef.child(currentUser).updateChildValues(values)
   
            }
           }
        }
    
        }
    
  
    
 }

    //MARK: - Firebase CRUD
extension HomeController{
    
    func fetchUsers(){

        databaseRef.child("Users").observeSingleEvent(of: .value) {(snapshot) in
        
        guard let dictionary = snapshot.value as? [String : AnyObject] else {return}


        dictionary.forEach { (key,value) in

            //let user = User(dictionary: value as! [String : Any])
        }

    } withCancel: { (err) in
        print("Failed to fetch users")
    }

    }
    
    func userAnnotaion(){
        

        locationRef.observe(.value) { [self] (snapshot) in
            
            guard let dictionary = snapshot.value as? [String : AnyObject] else {return}
            guard let currentUser = Auth.auth().currentUser?.uid else {return}

            dictionary.forEach { (key, value) in
                                
                
                let userLocation = UserLocation(dictionary: value as! [String : Any])

                if userLocation.uid != currentUser {
                    guard let userName = userLocation.username else {return}
                    guard  let latitude = userLocation.latitude else {return}
                    guard let longitude = userLocation.longitude else {return}

                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    
                    addAnnotationOnMapView(for: userLocation, with: location)
                                        
                    
                    let distanceInMeter = nearByAnnotation(tolocation: location)
                    
                    let userAnnotation = UserAnnotation(anno: userName, dis: Int(distanceInMeter))
                    userDistanceNameInfo.append(userAnnotation)
                    tableView.reloadData()
                    
                    if userDistanceNameInfo.count > 0 {
                        nearByButton.isHidden = false
                    }
                    
                }
            }
        
             
        } withCancel: { (err) in
            print("BERUPU: failed to fetch userAnnotation \(err)")
        }
        
    }
    
    func nearByAnnotation(tolocation: CLLocation) -> Double {
      
        let fromLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
          
        let toLocation = CLLocation(latitude: tolocation.coordinate.latitude, longitude: tolocation.coordinate.longitude)
          
        let distance = fromLocation.distance(from: toLocation)
          
        return distance
      
  }
}




    //MARK: - MapView

extension HomeController {
    
    func addAnnotationOnMapView(for user: UserLocation, with coordinate: CLLocation){
        guard let profileUrl = user.profileImageUrl else {return}
        let url = URL(string: profileUrl)
        
        userImage.sd_setImage(with: url) { [self] _,_,_,_  in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
            annotation.title = user.username
            mapView.addAnnotation(annotation)

            mapView.selectAnnotation(annotation, animated: true)
            
        }

   }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView Id")
        view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView Id")

        if annotation.title != "My Location"{
            view?.image = UIImage(systemName: "figure.walk")
        }else {
            view?.image = UIImage(systemName: "circle.circle.fill")
        }
        //view?.image?.withTintColor(UIColor.)
        view?.canShowCallout = true

        view?.frame.size = CGSize(width: 20, height: 20)
        //view?.layer.cornerRadius = 50/2


        view?.leftCalloutAccessoryView = userImage
        //view?.leftCalloutAccessoryView?.layer.cornerRadius = 45/2

        view?.rightCalloutAccessoryView = connectButton
        return view

    }
    
    /*
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //guard let capital = view.annotation as? Capital else { return }
        let placeName = "Connect with"
        let placeInfo = "username"

        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
 
    }
     */
    
//MARK: - Polyline Draw  ⚠️ for polyline need to call: mapView(rendererFor overlay: MKOverlay)
    
    func generatePolyline(toDestination destination: MKMapItem){

        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()       //starting point
        request.destination = destination                    //destination point
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)

        directionRequest.calculate { (response, error) in
            
            guard let response = response else {return}
            
            self.route = response.routes[0]            //route array with start and end point
                        
            guard let polyline = self.self.route?.polyline else {return}
            self.mapView.addOverlay(polyline)
            
           }
        
            ZoomBetweenUsers(selectedCoordinate: zoomToUsersAnnotationCo)
            //zoomToUserLocation()
        //zoomToFit(annotations: zoomToUsersAnnotation)
    }
    
    //MARK: - PolyLine Design
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {


        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 7
            
            return renderer
        }
       
        return MKOverlayRenderer()
    
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let selectedAnno = view.annotation?.coordinate else {return}
        
        selectedAnnoationCoordinate = selectedAnno
        
        zoomToUsersAnnotationCo.append(selectedAnno)
        
        
    }

    
}
    

    //MARK: - Location Access Permission

extension HomeController  {
    
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

//MARK: -------------------------TableView

extension HomeController : UITableViewDelegate, UITableViewDataSource {
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        //tableView.backgroundColor = .cyan
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 20
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
        tableViewPresenter = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return " NearBy Friends"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userDistanceNameInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                
        cell.textLabel?.text = "\(String(describing: userDistanceNameInfo[indexPath.row].annotationTitle!)) is   \(String(describing: userDistanceNameInfo[indexPath.row].distance!))m   Away"
        
        
    
        return cell
    }

}
