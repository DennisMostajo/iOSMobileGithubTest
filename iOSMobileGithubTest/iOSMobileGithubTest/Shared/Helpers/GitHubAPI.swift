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
/*
 client_id and secret_id are not necessary at the moment but I will apply
 in the future
 - https://developer.github.com/apps/building-oauth-apps/authorizing-oauth-apps/
 */
let CLIENT_ID = "" //
let SECRET_ID = "" //
//----------------------------------------------------------------------//
/**
 Personal access tokens function like ordinary OAuth access tokens. They can be used instead of a password for Git over HTTPS, or can be used to authenticate to the API over Basic Authentication..
 ## Important ##
 Need an API token for scripts or testing? Generate a personal access token for quick access to the GitHub API on https://github.com/settings/tokens.
 
 */
let PERSONAL_ACCESS_TOKEN = "" //
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
