//
//  LoginController.swift
//  onthemap
//
//  Created by antonio silva on 12/5/15.
//  Copyright © 2015 antonio silva. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

//A Controller that asks for a Udacity Student e-mail and password or the facebook linked account. If none, provide a link to Udacity registration 

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    
    //open the Udacity's signup URL
    @IBAction func signUp(sender: AnyObject) {
        
        let url=NSURL(string: AppConfig.Constants.UDACITY_SIGNUP_URL)!
        
        UIApplication.sharedApplication().openURL(url)
        
    }
    
    //login a student in Udacity API for a given e-mail and password
    @IBAction func login(sender: AnyObject) {
        
        emailText.resignFirstResponder()
        pwdText.resignFirstResponder()
        
        
        if (emailText.text?.isEmpty == true  || pwdText.text?.isEmpty == true) {
            displayError(nil,msg:"Please, type your e-mail and password")
            return
            
        }
        
        postLogin(nil)
        
    }
    
    //post login to Udacity APIs and if succeed, segue to location list table view, otherwise display a popup error
    func postLogin(accessToken:String?){
        
        prepareUIforPosting()
        
        OnMapClient.sharedInstance().login(emailText.text!,  pwd:pwdText.text!, accessToken: accessToken) {(success, error,result) in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.activityView.stopAnimating()
                self.loginBtn.userInteractionEnabled=true
                self.emailText.enabled=true
                self.pwdText.enabled=true
                
                if(success){
                    
                    if let student = result! as StudentInformation! {
                        
                        let delegate=UIApplication.sharedApplication().delegate as! AppDelegate
                        delegate.loggedStudent=student
                        
                        self.performSegueWithIdentifier("mapSegue", sender: nil)
                        
                    }
                }else{
                    self.displayError(error,msg:nil)
                }
            })
            
            
            
            
        }
        
    }
    
    //display a UIAlertAction for a given NSError
    func displayError(error: NSError?, var msg:String?) {
        if(error != nil ){
            if(error?.code == 403 ){
                msg="Invalid e-mail or password"
            }else{
                msg="Network error. Check your internet connection"
            }
        }
        
        
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default,handler:nil)
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true, completion:nil)
        
        
        
    }
    
    //clean email and password text, hide the activity view, set view's alpha  to 1 and subscribe to  keyboard notifications
    override func viewWillAppear(animated: Bool) {
        reset()
        subscribeToKeyboardNotifications()
        
        let token=checkFBToken()
        
        if(token != nil){
            hideAll()
            postLogin(token)
        }
        
    }
    
    //unsubscribe from keyboard notification
    override func viewWillDisappear(animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    
    //check if the FB token is valid. If so login the user at Udacity with the token, otherwise show the FB connect button
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paddingEmail = UIView(frame: CGRectMake(0, 0, 10, self.emailText.frame.size.height))
        let paddingPwd = UIView(frame: CGRectMake(0, 0, 10, self.pwdText.frame.size.height))
        
        
        emailText.leftView=paddingEmail
        emailText.leftViewMode=UITextFieldViewMode .Always
        
        pwdText.leftView=paddingPwd
        pwdText.leftViewMode=UITextFieldViewMode .Always
        
        addFBLoginBtn()
        
        
    }
    
    //set the alpha of UI elements to 1, clear the textfields and hides the activityView
    func reset(){
        
        emailText.alpha=1
        pwdText.alpha=1
        loginBtn.alpha=1
        signupBtn.alpha=1
        
        emailText.text = ""
        pwdText.text = ""
        emailText.enabled=true
        pwdText.enabled=true
        
        activityView.hidden=true
        self.view.alpha=1
        
    }
    
    //set the alpha of UI elements to 0 when the user is already logged in on facebook
    func hideAll(){
        emailText.alpha=0
        pwdText.alpha=0
        loginBtn.alpha=0
        signupBtn.alpha=0
    }
    
    //Disable the loginButton, and e-mail and passwords inputText and start the activityView animation
    func prepareUIforPosting(){
        
        loginBtn.userInteractionEnabled=false
        activityView.startAnimating()
        emailText.enabled=false
        pwdText.enabled=false
        
        
    }
    
    //Add a Facebook login button to the bottom of the view
    func addFBLoginBtn(){
        
        let fbLogin:FBSDKLoginButton = FBSDKLoginButton()
        
        fbLogin.readPermissions = ["public_profile", "email", "user_friends"]
        fbLogin.delegate = self
        fbLogin.center = CGPoint(x:self.view.frame.width/2 , y:self.view.frame.height - 30)
        
        self.view.addSubview(fbLogin)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //stop editing when touches outside the input
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            view.frame.origin.y-=getKeyboardHeight(notification)-100
        }
        
    }
    
    ///Get the keyboard height to use when need to scroll the screen.
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
        
        
    }
    
    
    
    //result from FB login process
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        if error == nil
        {
            
            let token=self.checkFBToken()
            
            guard (token != nil) else{
                
                print("Error login facebook")
                return
            }
            
            self.hideAll()
            self.postLogin(token)
            
        }
        else
        {
            NSLog(error.localizedDescription)
        }
    }
    
    
    
    //When user logged out of FB, logout at Udacity
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        
        OnMapClient.sharedInstance().logout(){ success, error in
            print("user has request logout out")
            
            if(success && error == nil ){
                print("user has logged out")
            }
        }
    }
    
    //check the result from FB authentication/authorization and if the token is valid, post and login at Udacity
    func checkFBToken() -> String?{
        if(FBSDKAccessToken.currentAccessToken() != nil){
            
            let token=FBSDKAccessToken.currentAccessToken().tokenString
            return token
            
        }else{
            
            return nil
        }
        
    }
    
    
}

