//
//  DataBaseHelper.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit
import RealmSwift
import DateToolsSwift
import Foundation

class DataBaseHelper {
    //-----------------------------------------------------------------------------------//
    //                                  TO MIGRATION
    //-----------------------------------------------------------------------------------//
    //-----------------------------------------------------------------------------------//
    // Change the value of DB_VERSION every time a change is made to the REALM database
    //-----------------------------------------------------------------------------------//
    static let DB_VERSION: UInt64 = 1
    //-----------------------------------------------------------------------------------//
    
    //MARK: Creates Methods
    
    class func createOrUpdateUser(_ user: User)
    {
        do {
            let realm = try Realm()
            realm.refresh()
            try realm.write {
                realm.create(User.self, value: user, update: true)
                debugPrint("--->User added or updated: \(user.id)")
            }
            
        } catch {
            debugPrint("Error creating or updating User")
        }
    }
    
    class func createOrUpdateRepository(_ repository: Repository)
    {
        do {
            let realm = try Realm()
            realm.refresh()
            try realm.write {
                realm.create(Repository.self, value: repository, update: true)
                debugPrint("--->Repository added or updated: \(repository.id)")
            }
            
        } catch {
            debugPrint("Error creating or updating Repository")
        }
    }
    
    //MARK: Get Methods
    
    class func getUsers() -> Results<User>?
    {
        do {
            let realm = try Realm()
            return realm.objects(User.self).sorted(byKeyPath: "id", ascending: true)
        } catch {
            return nil
        }
    }
    
    class func getUserById(user_id:Int) -> User?
    {
        do
        {
            let realm = try Realm()
            return realm.object(ofType: User.self, forPrimaryKey: user_id)
        }
        catch
        {
            return nil
        }
    }
    
    class func getRepositories() -> Results<Repository>?
    {
        do {
            let realm = try Realm()
            return realm.objects(Repository.self).sorted(byKeyPath: "id", ascending: true)
        } catch {
            return nil
        }
    }
    
    class func getRepositoryById(repository_id:Int) -> Repository?
    {
        do
        {
            let realm = try Realm()
            return realm.object(ofType: Repository.self, forPrimaryKey: repository_id)
        }
        catch
        {
            return nil
        }
    }
    
    class func getRepositoriesByUserId(user_id:Int) -> Results<Repository>? {
        do {
            let realm = try Realm()
            return realm.objects(Repository.self).filter("user_id = %@",user_id).sorted(byKeyPath: "id", ascending: true)
        } catch {
            return nil
        }
    }
    
    //MARK: Update Methods
    
    //MARK: Delete Methods
    
    //MARK: Migrations
    class func DBUpdate()
    {
        debugPrint("--->DBUpdate")
        // define a migration block
        // you can define this inline, but we will reuse this to migrate realm files from multiple versions
        // to the most current version of our data model
        let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1
            {
                /*
                 //---------------------------------------------------------------------//
                 //            THIS IS FOR ANY NEW CLASS OR COLUMN ADDED
                 //---------------------------------------------------------------------//
                 migration.enumerate("name class".className()) { oldObject, newObject in
                 // No-op.
                 // dynamic properties are defaulting the new column to true
                 // but the migration block is still needed
                 }
                 */
                
                //---------------------------------------------------------------------//
                //                          TO MIGRATION
                //---------------------------------------------------------------------//
                //-----------------------------------------------------------------------------------//
                // Change the value of DB_VERSION every time a change is made to the REALM database
                //-----------------------------------------------------------------------------------//
            }
            debugPrint("->oldSchemaVersion:\(oldSchemaVersion)")
            debugPrint("Migration complete.")
        }
        
//        var config = Realm.Configuration(schemaVersion: DB_VERSION, migrationBlock: migrationBlock)
//        config.fileURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.iOSMobileGithubTest.extension")!.appendingPathComponent("database.realm")
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: DB_VERSION, migrationBlock: migrationBlock)
        let realm = try! Realm()
        debugPrint("--->Path to realm file:\(String(describing: Realm.Configuration.defaultConfiguration.fileURL?.path))")
        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey:kCFURLFileProtectionNone], ofItemAtPath: (realm.configuration.fileURL?.path)!)
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}
