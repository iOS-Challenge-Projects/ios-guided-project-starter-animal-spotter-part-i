//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

//For HTTP methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

//To hanlde errors
enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherError
    case badData
    case noDecode
}


class APIController {
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    
    var bearer: Bearer?
    
    // create function for sign up
    //the return could be empty () or Void which is the same
    func signUp(with user: User, completion: @escaping (Error?)->()){
        
        //Adding "users/signup" to the end of the base URL
        let signUpURL = baseUrl.appendingPathComponent("users/signup")
        
        var request = URLRequest(url: signUpURL)
        
        //access the type of HTTP request from the enum
        request.httpMethod = HTTPMethod.post.rawValue
        
        //Specifying the format and the name of the header
        request.setValue("application/json" , forHTTPHeaderField: "Content-Type")
        
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
    
    func signIn(with user: User, completion: @escaping (Error?)->()){
         
         //Adding "users/signup" to the end of the base URL
         let signInURL = baseUrl.appendingPathComponent("users/login")
         
         var request = URLRequest(url: signInURL)
         
         //access the type of HTTP request from the enum
         request.httpMethod = HTTPMethod.post.rawValue
         
         //Specifying the format and the name of the header
         request.setValue("application/json" , forHTTPHeaderField: "Content-Type")
         
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
         URLSession.shared.dataTask(with: request) { (data, response, error) in
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
            
            //Handle data we got back from API
            guard let data = data else {
                completion(NSError())
                return
            }
            
            //Decode the data into Bearer
            let decoder = JSONDecoder()
            do{
                //save the token to the var bearer which is of type Bearer
                self.bearer = try decoder.decode(Bearer.self, from: data)
            }catch{
                print("Error decoding data :\(error)")
                completion(error)
                return
            }
            
            
            
             //if we pass nil means that there is no errors and we can proceed
             completion(nil)
             
         }.resume()
         
     }
    
    // create function for fetching all animal names
    //The new Result type allows to especify a success case and an error
    //IN comparison on the two methods above we only handle the error to signal
    //if the request was successful we pass nil and if not we pass the error
    func fetchAllAnimalNames(completion: @escaping (Result<[String], NetworkError>) -> Void) {
        //if there is no bearer/token then we dont want to continue because
        //to get the animals the API requires auth
        guard let bearer = bearer else {
            completion(.failure(.noAuth))
            return
        }
        
        let allAnimalsUrl = baseUrl.appendingPathComponent("animals/all")
        
        var request = URLRequest(url: allAnimalsUrl)
        
        request.httpMethod = HTTPMethod.get.rawValue
        
        //here we pass the token in the header of the request
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
        
            //Handle response always start with error handling
            
            //401 which is an error
            if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            //Handle error
            if let error = error {
                print("Error receiving animal name data: \(error)")
                completion(.failure(.otherError))
                return
            }
            
            //check if data exist
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do{
                let animalNames = try decoder.decode([String].self, from: data)
                completion(.success(animalNames))
            }catch{
                print("Error decoding data: \(error)")
                completion(.failure(.noDecode))
                return
            }
 
        }.resume()
    }
    
    
    // create function to get details
    func fetchDetails(for animalName: String, completion: @escaping (Result<Animal, NetworkError>) -> Void)  {
        
        guard let bearer = bearer else {
            completion(.failure(.noAuth))
            return
        }
        
        //put the selected animal in the url
        let animalsUrl = baseUrl.appendingPathComponent("animals/\(animalName)")
        
        var request = URLRequest(url: animalsUrl)
        
        request.httpMethod = HTTPMethod.get.rawValue
        
        //here we pass the token in the header of the request
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
               
                   //Handle response always start with error handling
                   
                   //401 which is an error
                   if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                       completion(.failure(.badAuth))
                       return
                   }
                   
                   //Handle error
                   if let error = error {
                       print("Error receiving animal \(animalName) details: \(error)")
                       completion(.failure(.otherError))
                       return
                   }
                   
                   //check if data exist
                   guard let data = data else {
                       completion(.failure(.badData))
                       return
                   }
                   
                   let decoder = JSONDecoder()
            //here we tell the decoder that if a date is found to use
            //secondsSince1970 to conver it into a swift date
            decoder.dateDecodingStrategy = .secondsSince1970
                   
                   do{
                       let animalDetails = try decoder.decode(Animal.self, from: data)
                       completion(.success(animalDetails))
                   }catch{
                       print("Error decoding animal details: \(error)")
                       completion(.failure(.noDecode))
                       return
                   }
        
               }.resume()
        
    }
    
    // create function to fetch image
    
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void)  {
        
        let imageUrl = URL(string: urlString)!
        
        var request = URLRequest(url: imageUrl)
        
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let _ = error {
                completion(.failure(.otherError))
            }
            
            guard let data = data else {
                completion(.failure(.badData))
                return
            }
            
            let image = UIImage(data: data)!
            
            completion(.success(image))
            
        }.resume()
        
    }
}
