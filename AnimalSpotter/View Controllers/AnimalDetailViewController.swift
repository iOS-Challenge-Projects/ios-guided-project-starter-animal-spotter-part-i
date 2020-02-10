//
//  AnimalDetailViewController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 10/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var timeSeenLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var animalImageView: UIImageView!
    
    //use to get the selected animal
    var animalName: String?
    
    //Use to get the injected instance which has the current token
    var apiController: APIController?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDetails()
    }
    
    private func getDetails(){
        guard let apiController = apiController, let animalName = animalName else {
            print("API Controller and animal name are require dependencies.")
            return
        }
        
        apiController.fetchDetails(for: animalName) { (results) in
            do{
                let animal = try results.get()
                DispatchQueue.main.async {
                    self.updateViews(with: animal)
                }
                
                apiController.fetchImage(at: animal.imageURL) { (result) in
                    if let image = try? result.get(){
                        self.animalImageView.image = image
                    }
                }
            }catch{
                if let error = error as? NetworkError{
                    switch error {
                    case .noAuth:
                        print("No token exist")
                        
                        //In a production app we must show errors to user similar to:
                        let alertController  = UIAlertController(title: "Not logged in", message: "Please sign in", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    case .badAuth:
                        print("Invalid Token")
                    case .otherError:
                        print("Other error occured, see log")
                    case .badData:
                        print("No data exist, or is corrupted")
                    case .noDecode:
                        print("Jdon could not be decoded")
                        
                    }
                }
            }
        }
    }
    
    
    private func updateViews(with animal: Animal){
        title = animal.name
        descriptionLabel.text = animal.description
        coordinatesLabel.text = "lat: \(animal.latitude), long: \(animal.longitude)"
        let df = DateFormatter()
        df.timeStyle = .short
        df.timeStyle = .none
        
        timeSeenLabel.text = df.string(from: animal.timeSeen)
    }
    
}
