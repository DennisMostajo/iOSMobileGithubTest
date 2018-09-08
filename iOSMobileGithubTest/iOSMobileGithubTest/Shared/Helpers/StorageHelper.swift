//
//  StorageHelper.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 8/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit

class StorageHelper
{
    class func setIsFirstTime(_ isFirstTime: Bool)
    {
        UserDefaults.standard.set(isFirstTime, forKey: StorageProperty.isFirstTime.rawValue)
    }
    
    class func isFirstTime() -> Bool
    {
        return !UserDefaults.standard.bool(forKey: StorageProperty.isFirstTime.rawValue)
    }
    
    class func setCurrentRefreshToken(_ token: String)
    {
        UserDefaults.standard.setValue(token, forKey: StorageProperty.currentRefreshToken.rawValue)
    }
    
    class func getCurrentRefreshToken() -> String?
    {
        return UserDefaults.standard.string(forKey: StorageProperty.currentRefreshToken.rawValue)
    }
    
    class func setCurrentAccessToken(_ token: String)
    {
        UserDefaults.standard.setValue(token, forKey: StorageProperty.currentAccessToken.rawValue)
    }
    
    class func getCurrentAccessToken() -> String?
    {
        return UserDefaults.standard.string(forKey: StorageProperty.currentAccessToken.rawValue)
    }
    
    class func setPrev_url_pagination(_ prev_url_pagination: String)
    {
        UserDefaults.standard.setValue(prev_url_pagination, forKey: StorageProperty.prev_url_pagination.rawValue)
    }
    
    class func getPrev_url_pagination() -> String?
    {
        return UserDefaults.standard.string(forKey: StorageProperty.prev_url_pagination.rawValue)
    }
    
    class func setNext_url_pagination(_ next_url_pagination: String)
    {
        UserDefaults.standard.setValue(next_url_pagination, forKey: StorageProperty.next_url_pagination.rawValue)
    }
    
    class func getNext_url_pagination() -> String?
    {
        return UserDefaults.standard.string(forKey: StorageProperty.next_url_pagination.rawValue)
    }
    
    class func clearAll ()
    {
        for key in StorageProperty.allValues
        {
            switch (key)
            {
            default:
                UserDefaults.standard.removeObject(forKey: key.rawValue)
            }
        }
    }
}

enum StorageProperty:String
{
    case isFirstTime = "isFirstTime"
    case currentRefreshToken = "currentRefreshToken"
    case currentAccessToken = "currentAccessToken"
    case prev_url_pagination = "prev_url_pagination"
    case next_url_pagination = "next_url_pagination"
    
    static let allValues:[StorageProperty] = [isFirstTime,
                                              currentRefreshToken,
                                              currentAccessToken,
                                              prev_url_pagination,
                                              next_url_pagination]
}

