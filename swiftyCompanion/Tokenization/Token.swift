//
//  Token.swift
//  SwiftyCompanion
//
//  Created by Muamba-nzambi, Moses on 2019/12/15.
//  Copyright © 2019 MuaMoses. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith

class Auth: NSObject {
    
    private let userAccount = "myAccount"
    private var token = String()
    private var bearer: [String: String] { return ["Authorization": "Bearer " + token] }
    
    private var authURL = "https://api.intra.42.fr/oauth/token"
    private var tokenInfoURL: String { return authURL + "/info" }
    
    private var parameters = [
        "grant_type": "client_credentials",
        "client_id": "5ea2dc240adceb205b6e6da7f0e5fa47a329628c5cd9e3773e0341c73b136217",
        "client_secret": "fe6f09621fbc7877fd712bf9f46b95ca292e88ef2fa6d9096282cfcb5051cdc1",
        "scope": "public"
    ]

    func checkIfTokenStoredInKeyChain() {
        let userData = Locksmith.loadDataForUserAccount(userAccount: userAccount)
        if let value = userData?["token"] as? String {
            token = value
        } else {
            token = ""
        }
    }
    
    func getToken() {
        
        checkIfTokenStoredInKeyChain()
        if token.isEmpty {
            Alamofire.request(authURL, method: .post, parameters: parameters).validate().responseJSON { (responseJSON) in
                switch responseJSON.result {
                case .success(let value):
                    let json = JSON(value)
                    if let value = json["access_token"].string {
                        self.token = value
                        do {
                            try Locksmith.saveData(data: ["token": value], forUserAccount: self.userAccount)
                        } catch {
                            print("Unable to save token in KeyChain")
                        }
                        print("Generated a new token: ", self.token)
                    }
                case .failure:
                    var errorMessage = "Received an error requesting the token"
                    var response = JSON()
                    if let data = responseJSON.data {
                        do {
                            response = try JSON(data: data)
                        } catch (let error) {
                            print(error)
                        }
                        if let message = response["error_description"].string {
                            if !message.isEmpty {
                                errorMessage = message
                            }
                        }
                    }
                    print("Error: ", errorMessage)
                }
            }
        } else {
            print("Using the same token:", token)
            checkToken()
        }
    }
    
    func checkToken() {
        Alamofire.request(tokenInfoURL, method: .get, headers: bearer).validate().responseJSON { (responseJSON) in
            switch responseJSON.result {
            case .success(let value):
                let json = JSON(value)
                print("The token will expire in: ", json["expires_in_seconds"], " seconds")
            case .failure:
                print("Token is invalid. Will get a new one.")
                do {
                    try Locksmith.deleteDataForUserAccount(userAccount: self.userAccount)
                } catch {
                    print("Couldn't delete data for user \(self.userAccount) from KeyChain. Error: ", error)
                }
                print("Invalid token was deleted from KeyChain")
                self.getToken()
            }
        }
    }
    
    func searchLogin(_ login: String, completionHandler: @escaping (JSON?, String?) -> Void ) {
        let loginURL = "https://api.intra.42.fr/v2/users/" + login
        print("Login URL -> ", loginURL)
        print("Token: -> ", token)
        Alamofire.request(loginURL, headers: bearer).validate().responseJSON { (responseJSON) in
            switch responseJSON.result {
            case .success(let value):
                completionHandler(JSON(value), nil)
            case .failure:
                var errorMessage: String?
                var response = JSON()
                if let data = responseJSON.data {
                    do {
                        response = try JSON(data: data)
                    } catch (let error) {
                        print("Error creating a JSON object", error)
                    }
                    debugPrint(response)
                    errorMessage = response["message"].string
                }
                completionHandler(nil, errorMessage)
            }
        }
    }
}
