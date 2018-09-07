//
//  UsersVc.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit
import SwiftyJSON
import DateToolsSwift
import JWTDecode
import Toast_Swift

class UsersVc: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _ = NetworkManager.manager.startRequest(GitHubAPI.getAllUsers, success:
            {
                responseRequest,responseData in
                debugPrint("getAllUsers StatusCode:\(String(describing: responseRequest?.statusCode))")
                let json = try! JSON(data: responseData! as! Data)
                debugPrint("getAllUsers response:\(json)")
        },
        failure:
            {
                _, _, error in
                debugPrint("error:\(error)")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
