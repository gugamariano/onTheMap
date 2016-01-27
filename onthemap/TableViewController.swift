//
//  TableViewController.swift
//  onthemap
//
//  Created by antonio silva on 12/5/15.
//  Copyright © 2015 antonio silva. All rights reserved.
//

import UIKit

//Controller that lists the students locations on a tableView
class TableViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var students: [StudentInformation] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).students
    }
    
    //request the student locations from singletoon OnMapClient, sort the records by last update and reload the table view.
    func reload() {
        
        tableView.alpha=0.1
        activityIndicatorView.startAnimating()
        
        
        
        OnMapClient.sharedInstance().getStudentLocations(AppConfig.Constants.STUDENT_LOCATION_MAX_RESULT_SIZE) { (success,error,result) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.tableView.alpha=1
                self.activityIndicatorView.stopAnimating()
                
                
                guard (success == true) else {
                    OnMapClient.sharedInstance().showAlert(self, title: "Error", msg: "Error downloading student locations")
                    return
                }
                
                
                if let result = result {
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.students = result.sort { (a: StudentInformation , b: StudentInformation) -> Bool in
                        return a.updatedAt > b.updatedAt
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                    
                    
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
        
        tableView.alpha=0.1
        activityIndicatorView.startAnimating()
        
        
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
    
    
    //set the view title and setup the logout, reload and pin buttons on navigation bar
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "On the Map"
        
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //reload the student locations when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reload()
        
    }
    
    //when the user select a table row, open the shared student media URL
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let urls = self.students[indexPath.row].mediaURL as String!
        
        guard let url = NSURL(string:urls) where UIApplication.sharedApplication().canOpenURL(url) else{
            OnMapClient.sharedInstance().showAlert(self, title: "Error", msg: "Please, enter a valid URL")
            return
        }
        
        UIApplication.sharedApplication().openURL(url)
        
        
    }
    
    
    
    //dequeu the StudentCell and set PIN icon, student first and last name
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! StudentCell
        cell.firstName.text=self.students[indexPath.row].firstName!.capitalizedString + " " + self.students[indexPath.row].lastName!.capitalizedString
        
        
        return cell
        
        
    }
    
    //return the students count
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return students.count
        
    }
    
    
}

