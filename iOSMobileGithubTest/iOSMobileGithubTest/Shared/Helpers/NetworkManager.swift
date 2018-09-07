//
//  NetworkManager.swift
//  iOSMobileGithubTest
//
//  Created by Dennis Mostajo on 7/9/18.
//  Copyright © 2018 Dennis Mostajo. All rights reserved.
//

import UIKit
import Alamofire

class NetworkManager: NSObject
{
    static let policy = ServerTrustPolicy.pinCertificates(certificates: ServerTrustPolicy.certificates(), validateCertificateChain: true, validateHost: true)
    static let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "developer.github.com": .disableEvaluation, // for test access development API
        "api.github.com": .disableEvaluation // for test API
    ]
    static let manager:AuthorizationManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        return AuthorizationManager(configuration: configuration, delegate: SessionDelegate(), serverTrustPolicyManager:ServerTrustPolicyManager(policies:serverTrustPolicies))
    }()
}

extension Foundation.URLRequest {
    static func allowsAnyHTTPSCertificateForHost(_ host: String) -> Bool {
        return true
    }
}
