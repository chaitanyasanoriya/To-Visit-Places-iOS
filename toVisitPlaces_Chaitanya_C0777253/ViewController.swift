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

class ViewController: UIViewController {
    
    @IBOutlet weak var mMapView: MKMapView!
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
    
    /// Setting the Style for the back button, while hiding navigation bar and having floating back button
    func setupBackButton()
    {
        let image = UIImage(named: "back")?.withRenderingMode(.alwaysTemplate)
        mBackButton.setImage(image, for: .normal)
        mBackButton.tintColor = UIColor.systemBlue
    }
    
    /// Shows a hint to that you can pinch to zoom in and out on the first opening
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
    
    /// Adding Double Tap gesture to add annotation
    func addDoubleTapGesture()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(addAnnotation))
        tap.numberOfTapsRequired = 2
        mMapView.addGestureRecognizer(tap)
    }
    
    /// Removing the default tap gestures from MapView that are being used to zoom in
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
    
    /// Simple Function to setup Location Manager
    func setupLocationManager()
    {
        mLocationManager.delegate = self
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Function to check if Location Service is enabled on the device
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
    
    /// Function to Check the Permission Authorization of the Location Service
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
    
    /// Function to center the camera on User Location
    func centerViewOnUserLocation()
    {
        if let location = mLocationManager.location?.coordinate
        {
            let region = MKCoordinateRegion.init(center: location,span: SPAN)
            mMapView.setRegion(region, animated: true)
        }
    }
    
    /// Action for the User Location Button
    /// - Parameter sender: its sender is Location Button on the bottom right corner of the screen
    @IBAction func centerLocation(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
    
    /// Function Called when Double Tap Gesture is recognized on MapView. This function is responsible to find where the user tapped and reverse GeoCode
    /// - Parameter gestureRecognizer: It gets the double tap gesture
    @objc func addAnnotation(gestureRecognizer:UITapGestureRecognizer){
        removeOverlaysAndAnnotations()
        let touchPoint = gestureRecognizer.location(in: mMapView)
        let newCoordinates = mMapView.convert(touchPoint, toCoordinateFrom: mMapView)
        mDestination = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        CLGeocoder().reverseGeocodeLocation(self.mDestination!, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription )
                return
            }
            
            let (title, subtitle) = self.getTitleSubTitle(placemarks?[0])
            self.mPlace = Place(longitude: newCoordinates.longitude, latitude: newCoordinates.latitude, title: title, subtitle: subtitle)
            self.mAlreadyStarred = false
            self.showAnnotation(place: self.mPlace!)
        })
    }
    
    /// Function to show Annotation on MapView
    /// - Parameter place: Place is a custom class that holds Latitude, Longitude, Title of place and Subtitle
    func showAnnotation(place: Place)
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        annotation.title = place.title
        annotation.subtitle = place.subtitle
        self.mMapView.addAnnotation(annotation)
    }
    
    /// Function to get Title and Sub-Title of the placemark from Geocoder
    /// - Parameter placemark: Object from Geocoder that has the information such as country, postal code etc.
    /// - Returns: Title and Sub-Title where Sub-Title can be optional
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
    
    
    /// Function responsible to draw directions on MapView
    func getDirections()
    {
        guard let location = mLocationManager.location?.coordinate else
        {
            showAlert(title: "Error", message: "The Application was not able to find your current location, please try again later.")
            return
        }
        if mDestination != nil || mPlace != nil
        {
            if(mDestination == nil && mPlace != nil)
            {
                mDestination = CLLocation(latitude: mPlace!.latitude, longitude: mPlace!.longitude)
            }
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
    
    /// Function responsible to create a MKDirections Request
    /// - Parameter coordinate: It is simply the coordinates of the origin location
    /// - Returns: Object of MKDirections Request with selected Transport Type and No Alternate Routes
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
    
    /// Action Outlet for Find Way Button for Navigation
    /// - Parameter sender: sender is the Find Way button on the bottom left corner of the screen
    @IBAction func findWayButtonClicked(_ sender: Any) {
        getDirections()
    }
    
    /// Function that removes all the overlays and annotations from the mapview
    func removeOverlaysAndAnnotations()
    {
        mMapView.removeOverlays(mMapView.overlays)
        mMapView.removeAnnotations(mMapView.annotations)
    }
    
    /// Action Outlet for Segmented Control Button, which is called when the Segmented Control Button changes value
    /// - Parameter sender: sender is the Segmented Control
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
    
    /// Generalized Function to present an Alert to the user. Typically used in some sort of error
    /// - Parameters:
    ///   - title: This is the title of the alert
    ///   - message: This is the message of the alert
    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "okay", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Action Outlet for the Floating Back Button. It pops this View Controller from the navigation controller
    /// - Parameter sender: Floating Back Button
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Built-in function called when the View is just about to disappear. Sets ths mPlace as nil, as it signifies if this View Controller is adding a place or showing already favourite place
    /// - Parameter animated: tell if the disappearance is being animated or not
    override func viewWillDisappear(_ animated: Bool) {
        self.mPlace = nil
    }
    
}

extension ViewController: CLLocationManagerDelegate
{
    
    /// Built-in function called when the authorization of location permissions is changed. It calls checkLocationAuthorization to update MapView
    /// - Parameters:
    ///   - manager: It is the CLLocationManager
    ///   - status: Tells the status of the authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension ViewController: MKMapViewDelegate
{
    /// Built-in function called when a overlay is being drawn. It adds the color to the directions Polylines, blue color for automobile and green for walking
    /// - Parameters:
    ///   - mapView: MapView on which the overlay is being drawn
    ///   - overlay: Overlay being Drawn
    /// - Returns: the Overlay Renderer
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
    
    /// Built-in function called when annotation is being added to the MapView. It modifies the MKPointAnnotation, adds custom images, allows the Annotation to be draggable, adds a Callout Accessory Button to add to favourites and also adds tint to the button in case it is already a favourite place
    /// - Parameters:
    ///   - mapView: MapView in which Annotation is being added
    ///   - annotation: Annotation being added
    /// - Returns: the MKAnnotationView which shows the title, subtitle and Button for an Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = mMapView.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
        pinAnnotation.image = UIImage(named: "pin")
        pinAnnotation.centerOffset = CGPoint(x: 0,y: -(pinAnnotation.image?.size.height ?? 0)/2)
        pinAnnotation.canShowCallout = true
        pinAnnotation.isDraggable = true
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
    
    
    /// Built-in function, called when callout accessory of Annotation is tapped. It is being called to add or remove a particular place from Favourite Places
    /// - Parameters:
    ///   - mapView: MapView whose Annotation's Callout accessory is tapped
    ///   - view: Annotation View whose Callout accessory is tapped
    ///   - control: Callout accessory which was tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if mPlace != nil
        {
            if view.rightCalloutAccessoryView?.tintColor == UIColor.systemBlue
            {
                PlacesHelper.getInstance().removePlace(place: mPlace!)
                view.rightCalloutAccessoryView?.tintColor = UIColor.systemGray
            }
            else
            {
                PlacesHelper.getInstance().addPlace(place: mPlace!)
                view.rightCalloutAccessoryView?.tintColor = UIColor.systemBlue
            }
        }
    }
    
    /// Built-in function, called when a Annotation is being dragged. Used to update the status of a Annotation being dragged. This updates the Information of a Annotation if it is already a favourite place
    /// - Parameters:
    ///   - mapView: MapView whose annotation is dragged
    ///   - view: AnnotationView being dragged
    ///   - newState: the new state of the dragged annotation
    ///   - oldState: old state of the dragged annotation
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        print(newState)
        if newState == .ending
        {
            self.mDestination = CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(self.mDestination!, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription )
                    return
                }
                let (title, subtitle) = self.getTitleSubTitle(placemarks?[0])
                let place = Place(longitude: view.annotation!.coordinate.longitude, latitude: view.annotation!.coordinate.latitude, title: title, subtitle: subtitle)
                PlacesHelper.getInstance().replace(oldPlace: self.mPlace!, newPlace: place)
                self.mPlace = place
                self.mMapView.removeAnnotations(self.mMapView.annotations)
                self.showAnnotation(place: place)
            })
        }
    }
}

extension UserDefaults {
    
    /// Function that tells if a key exists in the User Defaults of not
    /// - Parameter key: String Key
    /// - Returns: Boolean, true if key exists, false if key does not exist
    static func exists(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
}
