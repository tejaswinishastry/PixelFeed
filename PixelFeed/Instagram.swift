//
//  Instagram.swift
//  PixelFeed
//
//  Created by Tejaswini Shastry on 6/17/17.
//  Copyright © 2017 Tejaswini Shastry. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

struct Instagram {
    
    enum Router: URLRequestConvertible {
        /* Implicit flow creadentials */
        static let baseURLString = "https://api.instagram.com"
        static let clientID = "bf342377b7954b909d781b43a88a8239"
        static let redirectURI = "https://www.facebook.com/app.design.inspirations/"
        
        case userPhotos(String, String)
        case likePhoto(String, String)
        case unlikePhoto(String, String)
        case user(String)
        case requestOauthToken
        
        
        // MARK: URLRequestConvertible
        
        func asURLRequest() throws -> URLRequest {
            let result: (path: String, parameters: [String: AnyObject]?, method: HTTPMethod) = {
                switch self {
                case .user (let accessToken):
                    let userParams = ["access_token": accessToken]
                    let pathString = "v1/users/self"
                    return (pathString, userParams as [String : AnyObject]?, HTTPMethod(rawValue: "GET")!)

                case .userPhotos (let userID, let accessToken):
                    let userPhotoParams = ["access_token": accessToken]
                    let pathString = "/v1/users/" + userID + "/media/recent"
                    return (pathString, userPhotoParams as [String : AnyObject]?, HTTPMethod(rawValue: "GET")!)
                
                case .likePhoto (let photoId, let accessToken):
                    let likePhotoParams = ["access_token": accessToken]
                    let pathString = "/v1/media/" + photoId + "/likes"
                    return (pathString, likePhotoParams as [String : AnyObject]?, HTTPMethod(rawValue: "POST")!)
                    
                case .unlikePhoto (let photoId, let accessToken):
                    let unlikePhotoParams = ["access_token": accessToken]
                    let pathString = "/v1/media/" + photoId + "/likes"
                    return (pathString, unlikePhotoParams as [String : AnyObject]?, HTTPMethod(rawValue: "DELETE")!)
                    
                case .requestOauthToken:
                    let pathString = "/oauth/authorize/?client_id=" + Router.clientID + "&redirect_uri=" + Router.redirectURI + "&response_type=token" + "&scope=likes"
                    return (pathString, nil, HTTPMethod(rawValue: "GET")!)
                }
        }()
        
            
            let baseURL = URL(string: Router.baseURLString)!
            var urlRequest = URLRequest(url: URL(string: result.path ,relativeTo:baseURL)!)
            urlRequest.httpMethod = result.method.rawValue
            let encoding = Alamofire.URLEncoding.default
            return try! encoding.encode(urlRequest, with: result.parameters)
        }
    }
    
}




