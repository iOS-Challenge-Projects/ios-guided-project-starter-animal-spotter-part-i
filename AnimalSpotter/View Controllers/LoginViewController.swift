//
//  LoginViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginTypeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var signInButton: UIButton!
    
    //we get this from prepare segue to use the same instance of APIController()
    var apiController: APIController?
    
    var loginType = LoginType.signUp

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.backgroundColor = UIColor(hue: 190/360, saturation: 70/100, brightness: 80/100, alpha: 1.0)
            signInButton.tintColor = .white
            signInButton.layer.cornerRadius = 8.0
    }
    
    // MARK: - Action Handlers
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        // perform login or sign up operation based on loginType
        //unwrap values
        guard let apiController = apiController else { return }
        guard let username = usernameTextField.text, !username.isEmpty, let password = passwordTextField.text, !password.isEmpty else {return }
        
        //create User object
        let user = User(username: username, password: password)
        
        //Check mode and call corresponding method
        if loginType == .signUp{
            apiController.signUp(with: user) { (error) in
                
                //Handle errors
                if let error = error {
                   print("Error occurred during sign up \(error)")
                }else{
                    //the request is done in the background
                    //since now we need to update the UI we must move the
                    //proceess to the main queue
                    DispatchQueue.main.async {
                        //Display alert that sign up worked
                        let alertController = UIAlertController(title: "Sign Up Successful", message: "Now please sign in", preferredStyle: .alert)
                        
                        //create button for the alert
                        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        
                        //assing it
                        alertController.addAction(alertAction)
                        
                        //present it
                        self.present(alertController, animated: true){
                            //run when the presenter view is visable
                            
                            
                            //this will change the sign up to sign
                            self.loginType = .signIn
                            self.loginTypeSegmentedControl.selectedSegmentIndex = 1
                            self.signInButton.setTitle("Sign in", for: .normal)
                        }
                    }
                }
            }
            //Sign in
        }else{
            apiController.signIn(with: user) { (error) in
                //handle error
                if let error = error {
                    print("Error occur during sign in: \(error)")
                }else{
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            }
        }
    }
    
    @IBAction func signInTypeChanged(_ sender: UISegmentedControl) {
        // switch UI between login types
        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            signInButton.setTitle("Sign Up", for: .normal)
        }else{
            loginType = .signIn
            signInButton.setTitle("Sign In", for: .normal)
        }
    }
}
