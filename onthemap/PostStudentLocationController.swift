//
//  PostStudentLocationController.swift
//  onthemap
//
//  Created by antonio silva on 12/20/15.
//  Copyright © 2015 antonio silva. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

//Controller that shows the location entered on the map and asks for a URL to post on parse API
class PostStudentLocationController: UIViewController , UITextViewDelegate{
    
    var mapItem : MKMapItem!
    
    
    @IBOutlet weak var studentURLText: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var mapKit: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //when the user click on the submit button, show the activityIndicator and set the alpha of UI elements to 0.1. If the URL is valid, post the location entered to parse API, creating or updating the existing location for the current logged user and dismiss the current view, otherwise, show an UIAlertAction with a friendly error message.
    @IBAction func submit(sender: AnyObject) {
        let delegate=UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        activityIndicator.startAnimating()
        studentURLText.alpha=0.1
        mapKit.alpha=0.1
        submitBtn.alpha=0.1
        
        let media=studentURLText.text!
        let latitude=mapItem.placemark.coordinate.latitude
        let longitude=mapItem.placemark.coordinate.longitude
        let mapString=mapItem.placemark.name!
        
        
        guard(!media.isEmpty) else {
            OnMapClient.sharedInstance().showAlert(self, title: "Error", msg: "URL must not be empty")
            stopAnimating()
            return
        }
        
        guard let url = NSURL(string:media) where UIApplication.sharedApplication().canOpenURL(url) else{
            OnMapClient.sharedInstance().showAlert(self, title: "Error", msg: "Please, enter a valid URL")
            stopAnimating()
            return
        }
        
        
        var student=delegate.loggedStudent
        
        student!.mediaURL=media
        student!.mapString=mapString
        student!.latitude=latitude
        student!.longitude=longitude
        
        
        OnMapClient.sharedInstance().postStudentLocation(student!) {(success: Bool, error: NSError?)in
            
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.stopAnimating()
                
                guard (error==nil && success) else{
                    OnMapClient.sharedInstance().showAlert(self, title: "Error", msg: "Error posting student location")
                    return
                }
                
                self.dismissViewControllerAnimated(true, completion:nil)
                
            })
        }
        
    }
    
    //stop the activityIndicator and reset the alpha of UI elements to 1
    func stopAnimating(){
        self.activityIndicator.stopAnimating()
        self.studentURLText.alpha=1
        self.mapKit.alpha=1
        self.submitBtn.alpha=1
        
        
    }
    
    //dismiss the view when the user click the cancel btn
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentURLText.delegate=self
        reset()
    }
    
    //put a MKPointAnnotation on the map for the address previously entered and zoom to the center region of the map
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let center=mapItem.placemark.location?.coordinate
        
        let region = MKCoordinateRegion(center: center!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapKit.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        
        pin.coordinate=CLLocationCoordinate2D(latitude: (center?.latitude)!, longitude: (center?.longitude)!)
        
        self.mapKit.addAnnotation(pin)
    }
    
    
    //set the initial text and style of the location textview
    func reset(){
        studentURLText.text = "Share an URL"
        studentURLText.textColor = UIColor.lightGrayColor()
        studentURLText.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        studentURLText.layer.borderWidth = 1.0;
        studentURLText.layer.cornerRadius = 5.0;
        
        
    }
    
    //handle the return key to dismiss the keyboard
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //as soon as the user start to type, remove the initial textr and change the text color to black
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    //as soon as the user finish to type, check the user input. If its empty, set the initial text
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            reset()
        }
    }
    
    //if the user touches outside the textview, resign the firstresponder, hiding the keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    ///Subscribe to keyboardWillShow and keyboardWillHide notifications.
    func subscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    ///Unsubscribe to keyboardWillShow and keyboardWillHide notifications.
    func unsubscribeFromKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    
    ///Scroll up the vertical screen to show the keyboard only on bottom input text.
    func keyboardWillHide(notification: NSNotification) {
        
        view.frame.origin.y = 0
        
    }
    
    ///Scroll down the vertical screen when the keyboard dismiss minus the login btn constraint height/2.
    func keyboardWillShow(notification: NSNotification) {
        
        if(view.frame.origin.y == 0){
            view.frame.origin.y-=getKeyboardHeight(notification)
        }
        
    }
    
    ///Get the keyboard height to use when need to scroll the screen.
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
        
        
    }
    
    
}
