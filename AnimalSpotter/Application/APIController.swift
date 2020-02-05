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
        
        //Specifying the format and the name of the header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        
        do{
            //encode data into a user object
            let jsonData = try jsonEncoder.encode(user)
            //Assing the data to the body of the request
            request.httpBody = jsonData
            
        }catch{
            print("Error encoding data\(error)")
            completion(error)
            return
        }
        
        //We get the data, a response ok 201, and an error, all are optional
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            //here we unwrap it and downcasted
            if let response = response as? HTTPURLResponse, response.statusCode != 200{
                //send the NSError code in the completion with the statusCode
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error{
                completion(error)
                return
            }
            
            //if we pass nil means that there is no errors and we can proceed
            completion(nil)
            
        }.resume()
        
    }
    
    // create function for sign in
    
    // create function for fetching all animal names
    
    // create function to fetch image
}
