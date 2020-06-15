//
//  ViewController.swift
//  toVisitPlaces_Chaitanya_C0777253
//
//  Created by Chaitanya Sanoriya on 13/06/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var mMapView: MKMapView!
    
    private var mContext: NSManagedObjectContext!
    let mLocationManager = CLLocationManager()
    let SPAN = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    var mDestination: CLLocation?
    var mTransportType: MKDirectionsTransportType = .automobile
    @IBOutlet weak var mSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mBackButton: UIButton!
    var mPlace: Place?
    var mAlreadyStarred: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        setupCoreData()
        checkLocationServices()
        removeTapGestures()
        addDoubleTapGesture()
        showPinchHint()
        setupBackButton()
        if self.mPlace != nil
        {
            showAnnotation(place: self.mPlace!)
        }
    }
    
    func setupCoreData()
    {
        //Setting up Core Data variables for this UIViewController
        let app_delegate = UIApplication.shared.delegate as! AppDelegate
        self.mContext = app_delegate.persistentContainer.viewContext
    }
    
    func setupBackButton()
    {
        //let button = UIButton(type: .custom)
        let image = UIImage(named: "back")?.withRenderingMode(.alwaysTemplate)
        mBackButton.setImage(image, for: .normal)
        mBackButton.tintColor = UIColor.systemBlue
    }
    
    func showPinchHint()
    {
        let defaults = UserDefaults.standard
        if UserDefaults.exists(key: "first")
        {
            return
        }
        defaults.set(false, forKey: "first")
        let alert = UIAlertController(title: "You Can Pinch to Zoom in and Zoom out", message: "", preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when)
        {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func addDoubleTapGesture()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(addAnnotation))
        tap.numberOfTapsRequired = 2
        mMapView.addGestureRecognizer(tap)
    }
    
    func removeTapGestures()
    {
        if (mMapView.subviews[0].gestureRecognizers != nil){
            for gesture in mMapView.subviews[0].gestureRecognizers!{
                if (gesture is UITapGestureRecognizer){
                    mMapView.subviews[0].removeGestureRecognizer(gesture)
                }
            }
        }
    }
    
    func setupLocationManager()
    {
        mLocationManager.delegate = self
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else
        {
            showAlert(title: "Location Services are Disabled", message: "The application required Location Services to be enabled to show your location and directions. Please enable Location Services from settings")
        }
    }
    
    func checkLocationAuthorization()
    {
        switch CLLocationManager.authorizationStatus()
        {
        case .authorizedWhenInUse:
            mMapView.showsUserLocation = true
            centerViewOnUserLocation()
            mLocationManager.startUpdatingLocation()
            break
        case .denied:
            showAlert(title: "Location Permissions Denied!", message: "The application required Location Permissions to be enabled to show your location and directions. Please Allow Location Permissions from settings")
        case .notDetermined:
            mLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Code Add alert
            break
        case .authorizedAlways:
            break
        @unknown default:
            // Code
            break
        }
    }
    
    func centerViewOnUserLocation()
    {
        if let location = mLocationManager.location?.coordinate
        {
            let region = MKCoordinateRegion.init(center: location,span: SPAN)
            mMapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func centerLocation(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    
    @objc func addAnnotation(gestureRecognizer:UITapGestureRecognizer){
        removeOverlaysAndAnnotations()
        let touchPoint = gestureRecognizer.location(in: mMapView)
        let newCoordinates = mMapView.convert(touchPoint, toCoordinateFrom: mMapView)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = newCoordinates
        mDestination = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        CLGeocoder().reverseGeocodeLocation(self.mDestination!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription )
                return
            }
            
            let (title, subtitle) = self.getTitleSubTitle(placemarks?[0])
//            annotation.title = title
//            annotation.subtitle = subtitle
//            self.mMapView.addAnnotation(annotation)
            self.mPlace = Place(longitude: newCoordinates.longitude, latitude: newCoordinates.latitude, title: title, subtitle: subtitle)
            self.mAlreadyStarred = false
            self.showAnnotation(place: self.mPlace!)
        })
    }
    
    func showAnnotation(place: Place)
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        annotation.title = place.title
        annotation.subtitle = place.subtitle
        self.mMapView.addAnnotation(annotation)
    }
    
    func getTitleSubTitle( _ placemark: CLPlacemark?) -> (String, String?)
    {
        var title = ""
        var subtitle = ""
        if placemark == nil
        {
            return ("Unknown","")
        }
        if placemark!.subThoroughfare != nil
        {
            title.append(placemark!.subThoroughfare!)
        }
        if placemark!.thoroughfare != nil
        {
            if(title != "")
            {
                title.append(", ")
            }
            title.append(placemark!.thoroughfare!)
        }
        if placemark!.subLocality != nil
        {
            if(subtitle != "")
            {
                subtitle.append(", ")
            }
            subtitle.append(placemark!.subLocality!)
        }
        if placemark!.locality != nil
        {
            if(subtitle != "")
            {
                subtitle.append(", ")
            }
            subtitle.append(placemark!.locality!)
        }
        if placemark!.subAdministrativeArea != nil
        {
            if(subtitle != "")
            {
                subtitle.append(", ")
            }
            subtitle.append(placemark!.subAdministrativeArea!)
        }
        if placemark!.administrativeArea != nil
        {
            if(subtitle != "")
            {
                subtitle.append(", ")
            }
            subtitle.append(placemark!.administrativeArea!)
        }
        if placemark!.country != nil
        {
            if(subtitle != "")
            {
                subtitle.append(", ")
            }
            subtitle.append(placemark!.country!)
        }
        if placemark!.postalCode != nil
        {
            if(subtitle != "")
            {
                subtitle.append(", ")
            }
            subtitle.append(placemark!.postalCode!)
        }
        return (title, subtitle)
    }
    
    
    func getDirections()
    {
        guard let location = mLocationManager.location?.coordinate else
        {
            showAlert(title: "Error", message: "The Application was not able to find your current location, please try again later.")
            return
        }
        if mDestination != nil
        {
            mMapView.removeOverlays(mMapView.overlays)
            let request = createDirectionRequest(from: location)
            let directions = MKDirections(request: request)
            
            directions.calculate { [unowned self] (response, error) in
                guard let response = response else
                {
                    self.showAlert(title: "Error", message: "Directions could not be calculated")
                    return
                }
                
                for route in response.routes
                {
                    self.mMapView.addOverlay(route.polyline)
                    self.mMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
        else
        {
            showAlert(title: "Destination Not Selected", message: "Please select a destination before trying to find a way.")
        }
    }
    
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request
    {
        let destination_coordinate = mDestination!.coordinate
        let starting_location = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destination_coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: starting_location)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = self.mTransportType
        request.requestsAlternateRoutes = false
        return request
    }
    
    @IBAction func findWayButtonClicked(_ sender: Any) {
        getDirections()
    }
    
    func removeOverlaysAndAnnotations()
    {
        mMapView.removeOverlays(mMapView.overlays)
        mMapView.removeAnnotations(mMapView.annotations)
    }
    
    @IBAction func transportationTypeChanged(_ sender: Any) {
        switch mSegmentedControl.selectedSegmentIndex {
        case 0:
            mTransportType = .automobile
        case 1:
            mTransportType = .walking
        default:
            break
        }
    }
    
    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.mPlace = nil
    }
    
}

extension ViewController: CLLocationManagerDelegate
{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension ViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        if(mTransportType == .automobile)
        {
            renderer.strokeColor = .blue
        }
        else if(mTransportType == .walking)
        {
            renderer.strokeColor = .green
        }
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = mMapView.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
        pinAnnotation.image = UIImage(named: "pin")
        pinAnnotation.centerOffset = CGPoint(x: 0,y: -(pinAnnotation.image?.size.height ?? 0)/2)
        pinAnnotation.canShowCallout = true
        let btn = UIButton(type: .detailDisclosure)
        btn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        if self.mAlreadyStarred
        {
            btn.tintColor = UIColor.systemBlue
        }
        else
        {
            btn.tintColor = UIColor.systemGray
        }
        pinAnnotation.rightCalloutAccessoryView = btn
        return pinAnnotation
    }
    
    //MARK: - callout accessory control tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if mPlace != nil
        {
            if view.rightCalloutAccessoryView?.tintColor == UIColor.systemBlue
            {
                PlacesHelper.removePlace(place: mPlace!, context: self.mContext)
                view.rightCalloutAccessoryView?.tintColor = UIColor.systemGray
            }
            else
            {
                PlacesHelper.addPlace(place: mPlace!, context: self.mContext)
                view.rightCalloutAccessoryView?.tintColor = UIColor.systemBlue
            }
        }
    }
}
extension UserDefaults {
    
    static func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
}
