//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var animalNames: [String] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    let apiController = APIController()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // transition to login view if conditions require
        
        //bearer is use to save the token that the api returns to us
        //so if there is no token we redirect the user to login/signup
        if apiController.bearer == nil{
            performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = animalNames[indexPath.row]

        return cell
    }

    // MARK: - Actions
    
    @IBAction func getAnimals(_ sender: UIBarButtonItem) {
        // fetch all animals from API
        apiController.fetchAllAnimalNames { (result) in
            //by uising try? we dont have to use a "do catch" block
            //but if unsuccessful it simply returns nil
            if let names = try? result.get(){
                //Continue on the main queue because the did set will update ui
                DispatchQueue.main.async {
                    
                    //assign names to animalNames of this class
                    self.animalNames = names.sorted()
                }
            }
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue" {
            // inject dependencies to use the same instance of apiController on all controllers
            if let loginVC = segue.destination as? LoginViewController{
                //dependency injection to use the same instance of the apiController
                //because if we create another instance that will not have the samecontent as this one
                loginVC.apiController = apiController
            }
            
        }else if segue.identifier == "ShowAnimalDetailSegue"{
            if let detailVC = segue.destination as? AnimalDetailViewController{
                //get index of the selected row
                if let indexPath = tableView.indexPathForSelectedRow {
                    
                    //inject the selected animal to the datailVC
                    detailVC.animalName = animalNames[indexPath.row]
                    
                    //inject the apiController which has the token to the datailVC
                    detailVC.apiController = apiController
                }
            }
        }
    }
}
