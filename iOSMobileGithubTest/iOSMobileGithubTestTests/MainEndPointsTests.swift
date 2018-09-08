//
//  MainEndPointsTests.swift
//  iOSMobileGithubTestTests
//
//  Created by Dennis Mostajo on 8/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import XCTest
import SwiftyJSON

class MainEndPointsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_get_simple_User()
    {
        _ = NetworkManager.manager.startRequest(GitHubAPI.getUser(email: "mostygt@gmail.com"), success:
            {
                responseRequest,responseData in
                debugPrint("getUser StatusCode:\(String(describing: responseRequest?.statusCode))")
                let json = try! JSON(data: responseData! as! Data)
                debugPrint("getUser response:\(json)")
        }, failure:
            {
                _, _, error in
                debugPrint("error:\(error)")
        })
    }
    
    func test_getAllUsers()
    {
        _ = NetworkManager.manager.startRequest(GitHubAPI.getAllUsers, success:
            {
                responseRequest,responseData in
                debugPrint("getAllUsers StatusCode:\(String(describing: responseRequest?.statusCode))")
                let json = try! JSON(data: responseData! as! Data)
                //                debugPrint("getAllUsers response:\(json)")
                if responseRequest?.statusCode == 200
                {
                    DataBaseHelper.clearDatabase()
                    if json.arrayValue.count == 0
                    {
                        // show no results message
                    }
                    else
                    {
                        for userJson in json.arrayValue
                        {
                            let user = User.fromJson(userJson)
                            DataBaseHelper.createOrUpdateUser(user)
                        }
                    }
                    let headers = responseRequest?.allHeaderFields as? [String:String]
                    //                    debugPrint("headers:\(String(describing: headers))")
                    if let link = headers!["Link"]
                    {
                        debugPrint("Link Pagination Users:\(link)")
                        let links = link.components(separatedBy: ",")
                        var dictionary: [String: String] = [:]
                        links.forEach({
                            let components = $0.components(separatedBy: "; ")
                            let cleanPath = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
                            dictionary[components[1]] = cleanPath
                        })
                        if let nextPagePath = dictionary["rel=\"next\""] {
                            debugPrint("nextPagePath: \(nextPagePath)")
                            StorageHelper.setNext_url_pagination(nextPagePath)
                        }
                        
                        if let prevPagePath = dictionary["rel=\"prev\""] {
                            debugPrint("prevPagePath: \(prevPagePath)")
                            StorageHelper.setPrev_url_pagination(prevPagePath)
                        }
                    }
                }
        },
                                                failure:
            {
                _, _, error in
                debugPrint("error:\(error)")
        })
    }
    
    func test_getUsersNextPagination()
    {
        _ = NetworkManager.manager.startRequest(GitHubAPI.getUsersNextPagination(since: "13056860"), success:
            {
                responseRequest,responseData in
                debugPrint("getUsersNextPagination StatusCode:\(String(describing: responseRequest?.statusCode))")
                let json = try! JSON(data: responseData! as! Data)
                //                debugPrint("getUsersNextPagination response:\(json)")
                if responseRequest?.statusCode == 200
                {
                    DataBaseHelper.clearDatabase()
                    if json.arrayValue.count == 0
                    {
                        // show no results message
                    }
                    else
                    {
                        for userJson in json.arrayValue
                        {
                            let user = User.fromJson(userJson)
                            DataBaseHelper.createOrUpdateUser(user)
                        }
                    }
                    let headers = responseRequest?.allHeaderFields as? [String:String]
                    //                    debugPrint("headers:\(String(describing: headers))")
                    if let link = headers!["Link"]
                    {
                        debugPrint("Link Pagination Users:\(link)")
                        let links = link.components(separatedBy: ",")
                        var dictionary: [String: String] = [:]
                        links.forEach({
                            let components = $0.components(separatedBy: "; ")
                            let cleanPath = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
                            dictionary[components[1]] = cleanPath
                        })
                        if let nextPagePath = dictionary["rel=\"next\""] {
                            debugPrint("nextPagePath: \(nextPagePath)")
                            StorageHelper.setNext_url_pagination(nextPagePath)
                        }
                        
                        if let prevPagePath = dictionary["rel=\"prev\""] {
                            debugPrint("prevPagePath: \(prevPagePath)")
                            StorageHelper.setPrev_url_pagination(prevPagePath)
                        }
                    }
                }
        },
                                                failure:
            {
                _, _, error in
                debugPrint("error:\(error)")
        })
    }
    
    // TODO: Check GitHub updates about tokens and authorizations differences on API V3
    // TODO: Improve and Update Authorization Manager
}
