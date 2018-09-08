//
//  Repository.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 8/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class Repository: Object
{
    @objc dynamic var id = 0
    @objc dynamic var user_id = 0 // user id
    @objc dynamic var name = "" // repository name
    @objc dynamic var description_repo = "" // repository description
    @objc dynamic var repo_html_url = "" // repository link
    @objc dynamic var open_issues_count = 0 // repository open issues counter
    @objc dynamic var forks_count = 0 // repository forks counter
    
    override static func primaryKey() -> String
    {
        return "id"
    }
    
    /**
     This method parse the Repository information from JSON and return a Realm Repository Object.
     */
    static func fromJson(_ json:JSON) -> Repository
    {
        let repository = Repository()
        repository.id = json["id"].intValue
        repository.user_id = json["owner"]["id"].intValue
        repository.name = json["name"].stringValue
        repository.description_repo = json["description"].stringValue
        repository.repo_html_url = json["html_url"].stringValue
        repository.open_issues_count = json["open_issues_count"].intValue
        repository.forks_count = json["forks_count"].intValue
        return repository
    }
}
