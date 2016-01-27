//
//  OnMapClient.swift
//  onthemap
//
//  Created by antonio silva on 12/5/15.
//  Copyright © 2015 antonio silva. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

//A singleton client for Student network and json-parsing operations for Udacity/parse and facebook operations
class OnMapClient: NSObject {
    
    var session: NSURLSession
    
    override init(){
        session = NSURLSession.sharedSession()
        super.init()
        
    }
    
    //login a student on Udacity's API with e-mail and password or using a facebook access token.
    //If succeed, set the student key and query the Udacity Student profile for the first and last name, returning a StudentInformation
    func login (email:String?, pwd:String?, accessToken:String?, completionHandler: (success: Bool, error: NSError? , student:StudentInformation?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppConfig.Constants.UDACITY_LOGIN_SESSION_URL)!)
        
        var body:String = ""
        
        request.HTTPMethod = "POST"
        request.timeoutInterval=10
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token=accessToken {
            body = "{\"facebook_mobile\": {\"access_token\": \"\(token)\"}}"
        }else{
            body = "{\"udacity\": {\"username\": \"\(email!)\", \"password\": \"\(pwd!)\"}}"
        }
        
        request.HTTPBody=body.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        
        makeLoginRequest(request, completionHandler: completionHandler)
    }
    
    //make a login request to Udacity API and request Student FirstName and LastName to initialize a StudentInformation if succeed, otherwise return and error to the completionHandler
    func makeLoginRequest(request:NSMutableURLRequest,completionHandler: (success: Bool, error: NSError? , student:StudentInformation?) -> Void) {
    
        self.makeRequest(request , subset: 5){ result, error in
            
            if let error = error {
                NSLog("Error making a request for login student: \(error)")
                completionHandler(success: false, error: error, student: nil)
            } else {
                
                if let account = result["account"] as? [String : AnyObject] {
                    let key = account[AppConfig.JSONKeys.STUDENT_KEY] as! String!
                    var student:StudentInformation=StudentInformation(key: key)
                    let userDataRequest = NSMutableURLRequest(URL: NSURL(string: AppConfig.Constants.UDACITY_STUDENT_PROFILE+key)!)
                    
                    self.makeRequest(userDataRequest , subset: 5){ result2, error2 in
                        
                        if let error2 = error2 {
                            NSLog("Error query Udacity student profile: \(error2)")
                            completionHandler(success: false, error: error2, student: nil)
                        } else {
                            
                            if let user = result2["user"] as? [String : AnyObject] {
                                let firstName=user["first_name"] as! String!
                                let lastName=user["last_name"] as! String!
                                student.firstName=firstName
                                student.lastName=lastName
                                
                                completionHandler(success: true, error: nil, student: student)
                                
                            }else{
                                NSLog("Sudent name could not be parsed, error : \(error2)" )
                                completionHandler(success: false, error: error2, student:nil)
                                
                            }
                        }
                        
                    }
                    
                    
                }else{
                    completionHandler(success: false, error: error, student:nil)
                    print("Error: Student key not found")
                }
                
            }
            
        }
        
    
    
    }
    
    
    
    //query first 100 students locations from parse.com API
    func getStudentLocations(limit:Int ,completionHandler: (success: Bool, error: NSError? , result:[StudentInformation]?) -> Void) {
        
        var url=AppConfig.Constants.STUDENT_LOCATION_URL
        
        if(limit > 0) {
            url=url + "?limit=\(limit)"
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: url )!)
        request.addValue(AppConfig.Constants.PARSE_APP_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(AppConfig.Constants.PARSE_REST_API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.timeoutInterval=20
        
        
        self.makeRequest(request , subset: 0){ result, error in
            
            if let error = error {
                completionHandler(success: false, error: error, result:nil)
            } else {
                
                if let results = result["results"] as? [[String : AnyObject]] {
                    let students = StudentInformation.studentFromResults(results)
                    completionHandler(success: true, error: nil, result:students)
                    
                }
                
                
            }
            
        }
        
    }
    
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            completionHandler(result: parsedResult, error: nil)
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
    }
    
    
    //Utility to make a request and parse the resulted json if succeed. otherwise return the given error for the completionHandler
    func makeRequest(req: NSMutableURLRequest, subset:Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var errString:String = ""
        
        let task = session.dataTaskWithRequest(req) { data, response, error in
            
            guard (error == nil) else {
                errString = "There was an error with your request: \(error)"
                NSLog("Error making a request: \(errString)")
                completionHandler(result:nil, error: NSError(domain: "makeRequest", code: 1, userInfo:[NSLocalizedDescriptionKey: errString]))
                return
            }
            
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                
                var code=2
                if let response = response as? NSHTTPURLResponse {
                    if(response.statusCode == 403){
                        code=403
                    }
                    errString = "Your request returned an invalid response! Status code: \(code)!"
                    
                    
                } else if let response = response {
                    errString = "Your request returned an invalid response! Response: \(response)!"
                } else {
                    errString = "Your request returned an invalid response!"
                }
                
                NSLog("Error making a request: \(errString)")
                completionHandler(result:nil, error: NSError(domain: "makeRequest", code: code, userInfo:nil))
                
                return
            }
            
            
            guard let data = data else {
                errString = "No data was returned by the request!"
                NSLog("Error getting data request: \(errString)")
                completionHandler(result:nil, error: NSError(domain: "makeRequest", code: 3, userInfo:[NSLocalizedDescriptionKey: errString]))
                return
            }
            
            
            let newData = data.subdataWithRange(NSMakeRange(subset, data.length - subset)) /* subset response data! */
            self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            
        }
        
        task.resume()
        
    }
    
    //check if a student location already exists in parse with the udacity uniqueKey. If so, return the StudentInformation object
    func getStudentLocation(key:String, completionHandler: (success: Bool, error: NSError? , result:StudentInformation?) -> Void)  {
        
        var url=AppConfig.Constants.STUDENT_LOCATION_URL+"?where="
        let query="{\"uniqueKey\":\"\(key)\"}".stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        url=url+query
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.addValue(AppConfig.Constants.PARSE_APP_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(AppConfig.Constants.PARSE_REST_API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.timeoutInterval=10
        
        
        self.makeRequest(request , subset: 0){ result, error in
            
            if let error = error {
                NSLog("Error querying student location: \(error)")
                completionHandler(success: false, error: error, result:nil)
            } else {
                
                if let json = result["results"] as? [[String : AnyObject]] {
                    
                    var student:StudentInformation!
                    
                    if(!json.isEmpty){
                    
                         student=StudentInformation(dictionary: json[0])
                        
                    }
                    
                    completionHandler(success: true, error: nil, result:student)
                    
                }else{
                    
                    completionHandler(success: false, error: nil, result:nil)
                
                }
                
            }
        }
        
        
    }
    
    
    //post a student location or update the existent location for a given StudentInformation
    func postStudentLocation(var student:StudentInformation, completionHandler: (success:Bool, error: NSError? ) -> Void) {
        
        let key=student.uniqueKey
        let request = NSMutableURLRequest(URL: NSURL(string: AppConfig.Constants.STUDENT_LOCATION_URL)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(AppConfig.Constants.PARSE_APP_ID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(AppConfig.Constants.PARSE_REST_API_KEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        getStudentLocation(key){ success, error,result in
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                
                if let std=result {
                    student.objectId=std.objectId
                    request.HTTPMethod = "PUT"
                    request.URL=request.URL?.URLByAppendingPathComponent(student.objectId!)
                    
                }else{
                    request.HTTPMethod = "POST"
                }
                
                do {
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(student.toDictionary(), options: NSJSONWritingOptions.PrettyPrinted)
                    request.HTTPBody=jsonData
                    
                    self.makeRequest(request, subset: 0){ result, error in
                        
                        if let error = error {
                            completionHandler(success: false, error: error)
                        } else {
                            completionHandler(success: true, error: nil)
                        }
                    }
                    
                    
                } catch let error as NSError {
                    NSLog("Error posting Student location \(error)")
                }
                
                
            }
            
            
        }
        
    }
    
    //helper method to show an UIAlertAction to the user with a title and a description
    func showAlert(view:UIViewController, title:String, msg:String) -> Void{
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let alertController = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default,handler:nil)
            alertController.addAction(OKAction)
            
            view.presentViewController(alertController, animated: true, completion:nil)
        })
        
    }
    
    
    //logout the current user on Udacity API deleting the XSRF-TOKEN cookie and use FBSDKLoginManager to logout facebook session if active
    func logout(completionHandler: (success:Bool, error: NSError? ) -> Void) {
        
        
        let request = NSMutableURLRequest(URL: NSURL(string: AppConfig.Constants.UDACITY_LOGIN_SESSION_URL)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil

        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies as [NSHTTPCookie]! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        self.makeRequest(request , subset: 5    ){ result, error in
            
            if let error = error {
                completionHandler(success: false, error: error)
            }else{
                
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                

                completionHandler(success: true, error: nil)
                
            }
        }
    
    }
    
    //return a singleton instance for this client
    class func sharedInstance() -> OnMapClient {
        
        struct Singleton {
            static var sharedInstance = OnMapClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
    
}
