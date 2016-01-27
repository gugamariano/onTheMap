//  AppConfig.swift
//  onthemap
//
//  Created by antonio silva on 12/5/15.
//  Copyright © 2015 antonio silva. All rights reserved.
//

import Foundation

//OnTheMap Constants and JSON keys
class AppConfig:NSObject{


    struct Constants {
        
        static let UDACITY_SIGNUP_URL:String = "https://www.udacity.com/account/auth#!/signup"
        static let UDACITY_LOGIN_SESSION_URL:String = "https://www.udacity.com/api/session"
        static let UDACITY_STUDENT_PROFILE="https://www.udacity.com/api/users/"


        static let PARSE_APP_ID:String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let PARSE_REST_API_KEY:String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let STUDENT_LOCATION_URL:String = "https://api.parse.com/1/classes/StudentLocation"
        
        static let STUDENT_LOCATION_MAX_RESULT_SIZE:Int=100

    }
    
    struct JSONKeys {

        static let OBJECT_ID_KEY = "objectId"
        static let UNIQUE_KEY = "uniqueKey"
        static let FIRST_NAME = "firstName"
        static let LAST_NAME = "lastName"
        static let MAP_STRING = "mapString"
        static let MEDIA_URL = "mediaURL"
        static let LATITUDE = "latitude"
        static let LONGITUDE = "longitude"
        static let STUDENT_KEY = "key"
        
        
    }


}