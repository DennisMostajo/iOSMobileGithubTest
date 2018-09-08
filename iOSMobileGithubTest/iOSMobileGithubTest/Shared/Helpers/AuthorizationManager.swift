//
//  AuthorizationManager.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JWTDecode

open class AuthorizationManager: SessionManager {
    
    public typealias NetworkSuccessHandler = (HTTPURLResponse?,AnyObject?) -> Void
    public typealias NetworkFailureHandler = (HTTPURLResponse?, AnyObject?, Error) -> Void
    
    fileprivate typealias CachedTask = () -> Void
    
    fileprivate var cachedTasks = Array<CachedTask>()
    fileprivate var isRefreshing = false {
        didSet {
            if !isRefreshing {
                self.cachedTasks = self.cachedTasks.compactMap{ element in
                    element()
                    return nil
                }
            }
        }
    }
    
    open func startRequest(
        _ urlRequestConvertible: URLRequestConvertible,
        success: NetworkSuccessHandler?,
        failure: NetworkFailureHandler?) -> Request?
    {
        let cachedTask: CachedTask = { [weak self] in
            guard let strongSelf = self else { return }
            
            _ = strongSelf.startRequest(
                urlRequestConvertible,
                success: success,
                failure: failure
            )
        }
        
        if self.isRefreshing {
            self.cachedTasks.append(cachedTask)
            return nil
        }
        
        // Append your auth tokens here to your parameters
        
        let request = self.request(urlRequestConvertible)
        request.response { [weak self] response in
            guard let strongSelf = self else { return }
            // check if is unauthorized
            let data = response.data
            if let response = response.response , response.statusCode == 401
            {
                let json = try! JSON(data: data!)
                let message = json["msg"].stringValue
                // check is is token has expired
                if (message == "Token has expired")
                {
                    debugPrint("Authorization Manager response:\(json)")
                    strongSelf.cachedTasks.append(cachedTask)
                    strongSelf.refreshTokens()
                }
                return
            }
            
            if let error = response.error {
                failure?(response.response, response.data as AnyObject?, error)
            } else {
                success?(response.response, response.data as AnyObject)
            }
        }
        request.resume()
        
        return request
    }
    
    /**
    I have been presented with several issues about authorizations for which this method will be improved in the future
     ## Important ##
     For more information check:
     - https://developer.github.com/apps/managing-oauth-apps/troubleshooting-authorization-request-errors/
     - https://developer.github.com/apps/managing-oauth-apps/troubleshooting-oauth-app-access-token-request-errors/
     */
    func refreshTokens()
    {
        // TODO: Check GitHub updates about tokens and authorizations differences on API V3
        // TODO: Improve and Update Authorization Manager handling tokens authorizations
    }
}
