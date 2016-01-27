//
//  SearchStudentLocationController.swift
//  onthemap
//
//  Created by antonio silva on 12/20/15.
//  Copyright © 2015 antonio silva. All rights reserved.
//

import Foundation
import UIKit
import MapKit


//Controller that asks for a address and if succeed push modally PostStudentLocationController
class SearchStudentLocationController:UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var locationText: UITextView!
    @IBOutlet weak var findBtn: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //dismiss the view when the user click the cancel btn
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion:nil)
    }
    
    //check if the location textview is not empty and geocode the text entered. If geocode fail or it's empty, show a UIAlertAction to the user with a error description. If succeed, push the PostStudentLocationController on the navigationcontroller
    @IBAction func findOnMap(sender: AnyObject) {
        
        
        guard let location=locationText.text where location.characters.count > 0 else {
            OnMapClient.sharedInstance().showAlert(self, title: "Error", msg: "Please, enter a valid location")
            return
            
        }
        
        activityIndicator.startAnimating()
        locationText.alpha=0.1
        findBtn.alpha=0.1
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = location
        
        let search = MKLocalSearch(request: request)
        
        
        search.startWithCompletionHandler { (response:MKLocalSearchResponse?, error:NSError?) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.activityIndicator.stopAnimating()
                self.locationText.alpha=1
                self.findBtn.alpha=1
                
                 if(error != nil || response?.mapItems.count == 0 ){
                    let msg="Error searching for the address"
                    OnMapClient.sharedInstance().showAlert(self, title: "Error", msg: msg)
                    
                }else{
                    
                    let controller =  self.storyboard?.instantiateViewControllerWithIdentifier("postStudentLocation") as! PostStudentLocationController!
                    
                    controller.mapItem=response?.mapItems[0]
                    
                    self.navigationController?.pushViewController(controller, animated:true)
                    
                    
                }
            })
            
            
            
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    //set the delegate to self and set the textview style and initial text
    override func viewDidLoad() {
        super.viewDidLoad()
        locationText.delegate=self
        reset()
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
    
    //set the initial text and style of the location textview
    func reset(){
        locationText.text = "Enter your location"
        locationText.textColor = UIColor.lightGrayColor()
        locationText.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        locationText.layer.borderWidth = 1.0;
        locationText.layer.cornerRadius = 5.0;
        
        
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
    
    
    
}
