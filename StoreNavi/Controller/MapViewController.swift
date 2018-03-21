//
//  MapViewController.swift
//  StoreNavi
//
//  Created by Paresh Navadiya on 17/01/17.
//  Copyright © 2017 Paresh Navadiya. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

//Location : Mondeal Square, Prahladnagar, Ahmedabad
class MapViewController: UIViewController,  UIScrollViewDelegate, CLLocationManagerDelegate {

    // MARK: - View LifeCycle
    
    
//    let MAP_TOPLEFT_LATITUDE = 23.072621  //23.072669
//    let MAP_TOPLEFT_LONGITUDE = 72.532793 //72.532327
//    var MAP_TOPLEFT_X:CGFloat = 27.5
//    var MAP_TOPLEFT_Y:CGFloat = 10
//    //Map Bottom-Right
//    let MAP_BOTTOMRIGHT_LATITUDE = 23.072323 //23.072519
//    let MAP_BOTTOMRIGHT_LONGITUDE =  72.533184//72.532731
//    var MAP_BOTTOMRIGHT_X:CGFloat = 151
//    var MAP_BOTTOMRIGHT_Y:CGFloat = 36.5
//    let MAP_MAX_ZOOM_SCALE:CGFloat = 2.5
    
    let MAP_TOPLEFT_LATITUDE = 33.7771158  //23.072669
    let MAP_TOPLEFT_LONGITUDE = -84.6566933 //72.532327
    var MAP_TOPLEFT_X:CGFloat = 0
    var MAP_TOPLEFT_Y:CGFloat = 0
    //Map Bottom-Right
    let MAP_BOTTOMRIGHT_LATITUDE = 33.7770447 //23.072519
    let MAP_BOTTOMRIGHT_LONGITUDE =  -84.6568730//72.532731
    var MAP_BOTTOMRIGHT_X:CGFloat = 0
    var MAP_BOTTOMRIGHT_Y:CGFloat = 0
    let MAP_MAX_ZOOM_SCALE:CGFloat = 2.5
    
    
    var coordinateConverter: CoordinateConverter!
    var displayScale: CGFloat = 0.0
    var displayOffset = CGPoint.zero
    var minZoomScale: CGFloat = 0.0
    var mapPinsArray = [UIButton]()
    var isInitialMap = false
    
    var btnCurLocation:UIButton?
    
    var locationManager: CLLocationManager!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var imgUserLocationPoint: UIImageView?
    @IBOutlet weak var imgUserLocationRadious: UIImageView?
    
    var currentLatitude:NSNumber = NSNumber(value: 0)
    var currentLongitude:NSNumber = NSNumber(value: 0)

    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //need to updatestatus bar light content
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        //title
        self.navigationItem.title = Constants.alertTitle
        
        let backButton = UIButton.init(type: .custom)
        //backButton.backgroundColor = UIColor.yellow
        backButton.setImage(UIImage.init(named: "back_button"), for: UIControlState.normal)
        backButton.addTarget(self, action:#selector(self.backPressed), for: UIControlEvents.touchUpInside)
        backButton.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButtonLeft = UIBarButtonItem.init(customView: backButton)
        self.navigationItem.leftBarButtonItem = barButtonLeft
        
        //calculation
        //self.caculateTopAndBottom()
        
        //intialization
        self.configureMap()
        
    }
    
    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - OnClick Navigation function
    
    func backPressed() {
        //do stuff here
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Intializers
    func caculateTopAndBottom() {
        
        if UIImage(named: "custommap") != nil {
            
            MAP_TOPLEFT_X = 18
            MAP_TOPLEFT_Y = 30
            
            MAP_BOTTOMRIGHT_X = mapImageView.frame.width-12
            MAP_BOTTOMRIGHT_Y = mapImageView.frame.height-32
            print("MAP_TOPLEFT_X:\(MAP_TOPLEFT_X), MAP_TOPLEFT_Y:\(MAP_TOPLEFT_Y), MAP_BOTTOMRIGHT_X:\(MAP_BOTTOMRIGHT_X), MAP_BOTTOMRIGHT_Y:\(MAP_BOTTOMRIGHT_Y)")
            
            
            let borderView:UIView = UIView(frame: CGRect(x: MAP_TOPLEFT_X, y: MAP_TOPLEFT_Y, width: MAP_BOTTOMRIGHT_X-MAP_TOPLEFT_X, height: MAP_BOTTOMRIGHT_Y-MAP_TOPLEFT_Y))
            borderView.backgroundColor = UIColor.clear
            borderView.layer.borderColor = UIColor.yellow.cgColor
            borderView.layer.borderWidth = 1.0
            borderView.layer.masksToBounds = true
            self.mapImageView.addSubview(borderView)
            
        }
    }
    
    func configureMap() {

        self.mapImageView.isUserInteractionEnabled = true
        self.mapImageView.contentMode = .scaleAspectFit
//        self.mapImageView.addSubview(self.imgUserLocationRadious!)
//        self.mapImageView.addSubview(self.imgUserLocationPoint!)
        self.imgUserLocationRadious?.center = CGPoint(x: CGFloat(self.view.frame.size.width / 2), y: CGFloat(0))
        self.imgUserLocationPoint?.center = CGPoint(x: CGFloat(self.view.frame.size.width / 2), y: CGFloat(0))
        //We setup a pair of anchors that will define how the floorplan image, maps to geographic co-ordinates
        
        
        var anchor1 = GeoAnchor()
        anchor1.latitudeLongitude = CLLocationCoordinate2DMake(MAP_TOPLEFT_LATITUDE, MAP_TOPLEFT_LONGITUDE)
        anchor1.pixel = CGPoint(x: CGFloat(MAP_TOPLEFT_X), y: CGFloat(MAP_TOPLEFT_Y))
        var anchor2 = GeoAnchor()
        anchor2.latitudeLongitude = CLLocationCoordinate2DMake(MAP_BOTTOMRIGHT_LATITUDE, MAP_BOTTOMRIGHT_LONGITUDE)
        anchor2.pixel = CGPoint(x: CGFloat(MAP_BOTTOMRIGHT_X), y: CGFloat(MAP_BOTTOMRIGHT_Y))
        var anchorPair = GeoAnchorPair()
        anchorPair.fromAnchor = anchor1
        anchorPair.toAnchor = anchor2
        
        //Initialize the coordinate system converter with two anchor points.
        coordinateConverter = CoordinateConverter(anchors: anchorPair)
        
        //Start detecting current location of user
        // Setup a reference to location manager.
//        self.locationManager = CLLocationManager()
//        self.locationManager.delegate = self
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        self.locationManager.activityType = .fitness
        appDelegate.startLocationUpdates()
        getLocation()
        //Hide user location circle image till we get accurate user location
        self.imgUserLocationPoint?.isHidden = true
        self.imgUserLocationRadious?.isHidden = true
        
        //sample add pin
//        self.addPin(withLatitude: 23.072468, andLongitude: 72.533026, withPinColor: UIColor.red)
//        //sample pin
//        self.addPin(withLatitude: 23.072608, andLongitude: 72.532947, withPinColor: UIColor.blue)
//        self.addPin(withLatitude: 23.072332, andLongitude: 72.532982, withPinColor: UIColor.purple)
//        //23.072591, 72.533035
//        self.addPin(withLatitude: 23.072586, andLongitude: 72.533035, withPinColor: UIColor.brown)
//        //23.072372, 72.533124
//        self.addPin(withLatitude: 23.072372, andLongitude: 72.533124, withPinColor: UIColor.cyan)
        
         self.addPin(withLatitude: 33.7771548, andLongitude: -84.6568687, withPinColor: UIColor.red)
         //sample pin
         self.addPin(withLatitude: 33.7771673, andLongitude: -84.6567868, withPinColor: UIColor.blue)
         self.addPin(withLatitude: 33.7772420, andLongitude: -84.6568197, withPinColor: UIColor.purple)
    }
    
    
    func addPin(with location: CLLocation, pin btnPin: UIButton) {
        btnPin.addTarget(self, action: #selector(self.handleTap(onPin:)), for: .touchUpInside)
        btnPin.isUserInteractionEnabled = true
        let pointOnImage = coordinateConverter.point(from: location.coordinate)
        //These coordinates need to be scaled based on how much the image has been scaled
        let scaledPoint = CGPoint(x: CGFloat(pointOnImage.x * displayScale + displayOffset.x), y: CGFloat(pointOnImage.y * displayScale + displayOffset.y))
        //Move the pin and radius to the user's location
        btnPin.center = scaledPoint
        //Add Pin on map image
        self.mapImageView.addSubview(btnPin)
        //Add Pin into array for later use
        mapPinsArray.append(btnPin)
    }
    
    // MARK: - Handle Tap on MapPin
    
    func handleTap(onPin sender: Any) {
        let btnPin = (sender as! UIButton)
        //Inform to parent control using delegate
        print("\(btnPin)")
    }
    
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization managerStatus: CLAuthorizationStatus) {
//        switch managerStatus {
//        case .authorizedAlways, .authorizedWhenInUse:
//            self.startTrackingLocation()
//            //Got authorization, start tracking location
//            
//        case .notDetermined:
//            self.locationManager.requestWhenInUseAuthorization()
//            //Request for Authorization
//            
//        default:
//            break
//        }
//    }
    
    func startTrackingLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startUpdatingLocation()
        //Set animattion on user radious
        self.animateUserRadious()
    }
    
    func animateUserRadious() {
        self.imgUserLocationRadious?.layer.removeAllAnimations()
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .curveLinear], animations: {() -> Void in
            self.imgUserLocationRadious?.transform = (self.imgUserLocationRadious?.transform.scaledBy(x: 0.8, y: 0.8))!
        }, completion: {(_ finished: Bool) -> Void in
            self.imgUserLocationRadious?.transform = CGAffineTransform.identity
        })
    }
    
    //MARK:- CLLocationManagerDelegate
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//        let location:CLLocation? = locations.last
//        
//        if location != nil {
//            
//            self.currentLatitude = NSNumber(value: locations.last!.coordinate.latitude)
//            self.currentLongitude = NSNumber(value: locations.last!.coordinate.longitude)
//            if location!.horizontalAccuracy < 160 {
//                self.imgUserLocationPoint?.isHidden = false
//                self.imgUserLocationRadious?.isHidden = false
//                self.updateUserLocation(location!)
//                //Display user location on map
//            }
//        }
//        
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        self.currentLatitude = 0
//        self.currentLongitude = 0
//    }
    
    //MARK:- Swift Location
    func getLocation() {
        let x = Location.getLocation(accuracy: .room, frequency: .continuous, success: { (_, location) in
            print("A new update of location is available: \(location)")
            
            let newLocation = CLLocation(coordinate: location.coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
            
            if self.btnCurLocation == nil {
                
                self.btnCurLocation = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(32), height: CGFloat(32)))
                self.btnCurLocation!.setImage(UIImage(named:"cur-map-pin")!, for: .normal)
                self.addPin(with: newLocation, pin: self.btnCurLocation!)

            }
            
            var pointOnImage = self.coordinateConverter.point(from: newLocation.coordinate)
            //pointOnImage.x -= self.btnCurLocation!.frame.width/2
            pointOnImage.y -= self.btnCurLocation!.frame.height/2
            self.btnCurLocation!.center = pointOnImage
            
            
        }) { (request, last, error) in
            request.cancel() // stop continous location monitoring on error
            print("Location monitoring failed due to an error \(error)")
        }
        x.register(observer: LocObserver.onAuthDidChange(.main, { (request, oldAuth, newAuth) in
            print("Authorization moved from \(oldAuth) to \(newAuth)")
        }))
    }
    
    //MARK: - Location Updates
    func didUpdateLocation(locations: [CLLocation]) {
        let location:CLLocation? = locations.last
        
        if location != nil {
            
            self.currentLatitude = NSNumber(value: locations.last!.coordinate.latitude)
            self.currentLongitude = NSNumber(value: locations.last!.coordinate.longitude)
            if location!.horizontalAccuracy < 160 {
                self.imgUserLocationPoint?.isHidden = false
                self.imgUserLocationRadious?.isHidden = false
                self.updateUserLocation(location!)
                //Display user location on map
            }
        }
    }
    
    func didFailWithError() {
        self.currentLatitude = 0
        self.currentLongitude = 0

    }
    
    
    //MARK:- Helpers
    func addPin(withLatitude laitude: Double, andLongitude longitude: Double, withPinImage imageName: String) {
        let btnMapPin = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(4), height: CGFloat(4)))
        //Display Business Owner with default Grey Color
        btnMapPin.setImage(UIImage(named: imageName)!, for: .normal)
        let newLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(laitude, longitude), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
        self.addPin(with: newLocation, pin: btnMapPin)
        var pointOnImage = coordinateConverter.point(from: newLocation.coordinate)
        //pointOnImage.x -= btnMapPin.frame.width/2
        pointOnImage.y -= btnMapPin.frame.height/2
        btnMapPin.center = pointOnImage
        
        btnMapPin.addTarget(self, action: #selector(MapViewController.btnPinClickedAction(_:)), for: .touchUpInside)
//        var frame = btnMapPin.frame
//        frame.origin = pointOnImage
//        btnMapPin.frame = frame
        
        do {
            try Location.monitor(regionAt: newLocation.coordinate, radius: 3, enter: { (entryRequest:RegionRequest) -> (Void) in
                print("entryRequest : \(String(describing: entryRequest.name))")
            }, exit: { (exitRequest:RegionRequest) -> (Void) in
                print("exitRequest : \(String(describing: exitRequest.name))")
            }) { (errorRequest:RegionRequest, error:Error) -> (Void) in
                print("region : \(String(describing: errorRequest.name)) : error : \(error.localizedDescription)")
            }
        }
        catch {
            
        }
    }
    
    func addPin(withLatitude laitude: Double, andLongitude longitude: Double, withPinColor color:UIColor) {
        let btnMapPin = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(32), height: CGFloat(32)))
        btnMapPin.setImage(UIImage(named:"map-pin")!, for: .normal)
        //Display Business Owner with default Grey Color
        //btnMapPin.backgroundColor = color
        let newLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(laitude, longitude), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
        self.addPin(with: newLocation, pin: btnMapPin)
        var pointOnImage = coordinateConverter.point(from: newLocation.coordinate)
        //pointOnImage.x -= btnMapPin.frame.width/2
        pointOnImage.y -= btnMapPin.frame.height/2
        btnMapPin.center = pointOnImage
        
        btnMapPin.addTarget(self, action: #selector(MapViewController.btnPinClickedAction(_:)), for: .touchUpInside)
//        var frame = btnMapPin.frame
//        frame.origin = pointOnImage
//        btnMapPin.frame = frame
        do {
            try Location.monitor(regionAt: newLocation.coordinate, radius: 3, enter: { (entryRequest:RegionRequest) -> (Void) in
                print("entryRequest : \(String(describing: entryRequest.name))")
            }, exit: { (exitRequest:RegionRequest) -> (Void) in
                print("exitRequest : \(String(describing: exitRequest.name))")
            }) { (errorRequest:RegionRequest, error:Error) -> (Void) in
                print("region : \(String(describing: errorRequest.name)) : error : \(error.localizedDescription)")
            }
        }
        catch {
            
        }
    }
    
    func updateUserLocation(_ location: CLLocation) {
        //We animate transition from one position to the next, this makes the dot move smoothly over the map
        UIView.animate(withDuration: 0.75, animations: {() -> Void in
            let pointOnImage = self.coordinateConverter.point(from: location.coordinate)
            //These coordinates need to be scaled based on how much the image has been scaled
            //Calculate and set the size of the radius
            let radiusFrameSize: CGFloat = CGFloat(location.horizontalAccuracy) * self.coordinateConverter.pixelsPerMeter * 2
            self.imgUserLocationRadious?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: radiusFrameSize, height: radiusFrameSize)
            if self.isInitialMap {
                self.isInitialMap = false
            }
            //Move the pin and radius to the user's location
            
            var pointCentre = pointOnImage
            pointCentre.x -= self.imgUserLocationPoint!.frame.width/2.0
            pointCentre.y -= self.imgUserLocationPoint!.frame.height/2.0
            self.imgUserLocationPoint?.center = pointCentre
            
//            var radiusCentre = pointOnImage
//            radiusCentre.x -= self.imgUserLocationRadious!.frame.width/2.0
//            radiusCentre.y -= self.imgUserLocationRadious!.frame.height/2.0
            self.imgUserLocationRadious?.center = pointOnImage
        })
    }
    
    
    func stopLocationMonitoring() {
        self.locationManager.stopUpdatingLocation()
    }
    
    //MARK:- Action
    @IBAction func btnPinClickedAction(_ sender:UIButton) {
    
    }
}
