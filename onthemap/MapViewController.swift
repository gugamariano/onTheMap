//
//  MapViewController.swift
//  onthemap
//
//  Created by antonio silva on 12/12/15.
//  Copyright © 2015 antonio silva. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

//A controller that pins a MKPointAnnotation on the map for the last 100 Udacity Student locations
class MapViewController: UIViewController,MKMapViewDelegate
{
    
    @IBOutlet weak var activityViewIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var map: MKMapView!
    var locationManager: CLLocationManager!
    
    //request the student locations from singletoon OnMapClient, pins a MKPointAnnotation on the map for the last 100 locations with the Student First and Last Name, and set the subtitle to student's shared media URL
    func reload() {
        
        self.map.alpha=0.1
        
        self.activityViewIndicator.startAnimating()
        
        let mapAnnotations = self.map.annotations
        self.map.removeAnnotations(mapAnnotations)
        
        
        OnMapClient.sharedInstance().getStudentLocations(AppConfig.Constants.STUDENT_LOCATION_MAX_RESULT_SIZE) { (success,error,students) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.map.alpha=1
                self.activityViewIndicator.stopAnimating()
                
                guard (success == true) else {
                    OnMapClient.sharedInstance().showAlert(self, title: "Error", msg: "Error downloading student locations")
                    
                    return
                }
                
                if let students = students {
                    
                    var annotations:Array = [MKPointAnnotation]()
                    
                    for student in students {
                        
                        
                        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(student.latitude), longitude: CLLocationDegrees(student.longitude))
                        
                        let pin = MKPointAnnotation()
                        
                        pin.coordinate=location
                        pin.title=student.firstName! + " " + student.lastName!
                        pin.subtitle=student.mediaURL
                        
                        annotations.append(pin)
                        
                    }
                    
                    
                    
                    self.map.addAnnotations(annotations)
                    
                    let location = CLLocationCoordinate2D(
                        latitude: 0,
                        longitude: 0
                    )
                    
                    let span = MKCoordinateSpanMake(160, 120)
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.map.setRegion(region, animated: true)
                    
                    
                    
                    
                }
                
                
            })
            
            
        }
        
        
    }
    
    //Perform a segue to SearchStudentLocationController when the user clicks the pin button
    func pin() {
        
        performSegueWithIdentifier("searchStudentLocation", sender: self)
        
    }
    
    //when the user clicks the logout button, logout the current user on Udacity and facebook
    func logout() {
        
        activityViewIndicator.startAnimating()
        map.alpha=0.1
        
        
            OnMapClient.sharedInstance().logout(){ success, error in
                dispatch_async(dispatch_get_main_queue(), {
                
                if(success && error == nil){
                    self.dismissViewControllerAnimated(true, completion: nil)
                }else{
                    OnMapClient.sharedInstance().showAlert(self, title: "Error", msg: "Error login out")
                    self.logout()
                }
                
            })
        }
    }
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    
    //set the view title and setup the logout, reload and pin buttons on navigation bar
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLeftBarButton()
        setRightBarButton()
        
        
    }
    
    //set the left logout button
    func setLeftBarButton() {
        
        let backBtn = UIBarButtonItem(title: "Log out", style: UIBarButtonItemStyle.Plain, target: self, action: "logout") as UIBarButtonItem
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.backBarButtonItem = nil;
    }
    
    //set the right reload and pin button
    func setRightBarButton() {
        
        
        let reload = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reload")
        
        let pinImage = UIImage(named: "pin")! as UIImage
        let pin = UIBarButtonItem(image: pinImage , style: UIBarButtonItemStyle.Plain, target: self, action: "pin")
        
        self.navigationItem.rightBarButtonItems = [pin,reload]
        
    }
    
    
    
    
    //Reuse a pin from the queue and setup a detail button for the rightCalloutAccessoryView
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view?.canShowCallout = true
            view?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            view?.annotation = annotation
        }
        
        view?.reloadInputViews()
        
        return view
        
        
    }
    
    //when the user taps the MKPointAnnotation, open the URL associate with this annotation
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MKPointAnnotation {
            
            let url=NSURL(string: annotation.subtitle!)!
            
            UIApplication.sharedApplication().openURL(url)
            
            
        }
    }
    
    
    
}

