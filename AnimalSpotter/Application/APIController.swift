//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class APIController {
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    
    // create function for sign up
    //the return could be empty () or Void which is the same
    func signUp(with user: User, completion: @escaping (Error?)->()){
        
        //Adding "users/signup" to the end of the base URL
        let signUpURL = baseUrl.appendingPathComponent("users/signup")
        
        var request = URLRequest(url: signUpURL)
        
        //access the type of HTTP request from the enum
        request.httpMethod = HTTPMethod.post.rawValue
    }
    
    // create function for sign in
    
    // create function for fetching all animal names
    
    // create function to fetch image
}
