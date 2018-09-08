//
//  GitHubAPI.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

let SERVER_URL = "https://developer.github.com/v3"
let API_URL = "https://api.github.com"
//----------------------------------------------------------------------//
//                        GitHub Credentials
//----------------------------------------------------------------------//
let CLIENT_ID = "641dcd146387d472e8b3"
let SECRET_ID = "21136397105481e58590d2ccc9628b66fdd7e3d6"
let PERSONAL_ACCESS_TOKEN = "6fac61ca1fd80c8e95e52d0d47238c0aa4b3f282"
//----------------------------------------------------------------------//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

enum GitHubAPI: URLRequestConvertible
{
    static let baseURLString = API_URL
    
    case createNewAuthorization
    case getUser(email:String)
    case getAllUsers
    case getRepositoriesFromUser(userName:String)
    case getUsersNextPagination(since:String)
    
    var method: Alamofire.HTTPMethod
    {
        switch self
        {
        case .createNewAuthorization:
            return .post
        default:
            return .get
        }
    }
    
    var path:String
    {
        switch self
        {
        case .createNewAuthorization:
            return "authorizations"
        case .getUser(let email):
            return "users/:\(email)"
        case .getAllUsers:
            return "users"
        case .getRepositoriesFromUser(let userName):
            return "users/\(userName)/repos"
        case .getUsersNextPagination:
            return "users"
        }
    }
    
    func asURLRequest() throws -> URLRequest
    {
        let URL = Foundation.URL(string: GitHubAPI.baseURLString)!
        var request = URLRequest(url:URL.appendingPathComponent(path))
        debugPrint("URL request:\(URL.appendingPathComponent(path))")
        request.httpMethod = method.rawValue
        
        var parameters:[String:AnyObject] = [:]
        
        switch self
        {
            case .createNewAuthorization:
                parameters["note"] = "personal access token" as AnyObject
                parameters["client_id"] = CLIENT_ID as AnyObject
                parameters["client_secret"] = SECRET_ID as AnyObject
            case .getUser(let email):
                parameters["email"] = email as AnyObject
            case .getAllUsers:
                break
            case .getRepositoriesFromUser:
                break
            case .getUsersNextPagination(let since):
                parameters["since"] = since as AnyObject
        }
        parameters["access_token"] = PERSONAL_ACCESS_TOKEN as AnyObject
        debugPrint(parameters)
        let encoding = URLEncoding.methodDependent
        return try! encoding.encode(request, with: parameters)
    }
}

extension URL {
    
    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }
        
        return parameters
    }
}
