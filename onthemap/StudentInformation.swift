//
//  StudentInformation.swift
//  onthemap
//
//  Created by antonio silva on 12/12/15.
//  Copyright © 2015 antonio silva. All rights reserved.
//

import Foundation

//Model that represent an Udacity Student
struct StudentInformation {
    
    var uniqueKey:String
    var firstName:String?
    var lastName:String?
    var mediaURL:String?
    var latitude:NSNumber = 0
    var longitude:NSNumber = 0
    var mapString:String?
    var createdAt:String?
    var updatedAt:String?
    var objectId:String?
    
    //init a student by the unique key
    init (key:String){
        uniqueKey = key
    }
    
    //init a student by a key/value dictionary
    init(dictionary: [String : AnyObject]) {
        
        objectId = dictionary[AppConfig.JSONKeys.OBJECT_ID_KEY] as! String!
        uniqueKey = dictionary[AppConfig.JSONKeys.UNIQUE_KEY] as! String!
        firstName = dictionary[AppConfig.JSONKeys.FIRST_NAME] as! String!
        lastName = dictionary[AppConfig.JSONKeys.LAST_NAME] as? String
        mediaURL = dictionary[AppConfig.JSONKeys.MEDIA_URL] as? String
        mapString = dictionary[AppConfig.JSONKeys.MAP_STRING] as? String
        latitude = (dictionary[AppConfig.JSONKeys.LATITUDE] as? NSNumber)!
        longitude = (dictionary[AppConfig.JSONKeys.LONGITUDE] as? NSNumber)!
        
        
        createdAt=dictionary["createdAt"] as? String
        updatedAt=dictionary["updatedAt"] as? String
        
    }
    
    //return an array of students from an array of key/value dictionaries
    static func studentFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        var students = [StudentInformation]()
        
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }
    
    //convert the current StudentINformation to a dictionary
    func toDictionary() -> [String:AnyObject]{
        
        
        let dic : [String:AnyObject] = [
            AppConfig.JSONKeys.UNIQUE_KEY : uniqueKey,
            AppConfig.JSONKeys.FIRST_NAME : firstName!,
            AppConfig.JSONKeys.LAST_NAME : lastName!,
            AppConfig.JSONKeys.MEDIA_URL : mediaURL!,
            AppConfig.JSONKeys.MAP_STRING : mapString!,
            AppConfig.JSONKeys.LATITUDE : latitude,
            AppConfig.JSONKeys.LONGITUDE : longitude,
            
        ]
        
        return dic
        
        
    }
    
}
