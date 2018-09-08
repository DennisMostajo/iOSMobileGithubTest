//
//  User.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class User: Object
{
    @objc dynamic var id = 0
    @objc dynamic var login = "" // user name
    @objc dynamic var avatar_url = "" // user image avatar
    @objc dynamic var html_url = "" // user link profile
    @objc dynamic var repos_url = "" // user link repositories
    
    override static func primaryKey() -> String
    {
        return "id"
    }
    
    static func fromJson(_ json:JSON) -> User
    {
        let user = User()
        user.id = json["id"].intValue
        user.login = json["login"].stringValue
        user.avatar_url = json["avatar_url"].stringValue
        user.html_url = json["html_url"].stringValue
        user.repos_url = json["repos_url"].stringValue
        return user
    }
}
