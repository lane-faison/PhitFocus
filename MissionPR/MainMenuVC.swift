//
//  MainMenuVC.swift
//  MissionPR
//
//  Created by Lane Faison on 5/31/17.
//  Copyright © 2017 Lane Faison. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import GooglePlaces


class MainMenuVC: UIViewController, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    var controller: NSFetchedResultsController<Gym_Location>!
    var manager: CLLocationManager!
    var myLocation = CLLocationCoordinate2D()
    var gymLocation = CLLocationCoordinate2D()
//    var gym = Gym_Location(context: context)
    
    @IBOutlet weak var viewGoalsBtn: RoundedOutlineButton!
    @IBOutlet weak var gymCheckInBtn: RoundedOutlineButton!
    @IBOutlet weak var setGymBtn: RoundedOutlineButton!
    @IBOutlet weak var setGymLabel: UILabel!
    @IBOutlet weak var gymNameLabel: UILabel!
    @IBOutlet weak var gymStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gymCheckInBtn.isEnabled = false
        gymNameLabel.isHidden = true
        gymStatusLabel.isHidden = true
        
        DispatchQueue.main.async {
            self.manager = CLLocationManager()
            self.manager.delegate = self
            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            self.manager.requestWhenInUseAuthorization()
            self.manager.startUpdatingLocation()
        }
        
        attemptFetch()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        self.myLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    @IBAction func setGymBtnPressed(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        let filter = GMSAutocompleteFilter()
        
        // Restrict results to establishments in the United States
        filter.type = .establishment
        filter.country = "us"
        autocompleteController.delegate = self
        autocompleteController.autocompleteFilter = filter
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func gymCheckInBtnPressed(_ sender: Any) {
        
        print("TAPPED")
        print("GymCoordinates: \(gymLocation)")
        print("myLocation: \(myLocation)")
        
        let gymCoordinates = CLLocation(latitude: gymLocation.latitude, longitude: gymLocation.longitude)
        let myCoordinates = CLLocation(latitude: myLocation.latitude, longitude: myLocation.longitude)
        let distance: CLLocationDistance = myCoordinates.distance(from: gymCoordinates)
        print(distance)
        if distance < 100 {
            print("You are at the gym")
            gymStatusLabel.text = "You are at the gym"
            gymStatusLabel.isHidden = false
        } else {
            print("You are not at the gym")
            gymStatusLabel.text = "You are not at the gym"
            gymStatusLabel.isHidden = false
        }
        
    }
    
    func attemptFetch() {
        let fetchRequest: NSFetchRequest<Gym_Location> = Gym_Location.fetchRequest()
        let nameSort = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [nameSort]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        controller.delegate = self
        self.controller = controller
        
        do {
            try controller.performFetch()
            let data = controller.fetchedObjects

            if (data?.count)! > 0 {
                gymCheckInBtn.isEnabled = true
                gymNameLabel.isHidden = false
                gymNameLabel.text = data![0].name!
                setGymLabel.text = "Gym set to:"
                
                print("DATA: \(data![0])")
                
                gymLocation.latitude = data![0].latitude
                gymLocation.longitude = data![0].longitude
                
                setGymBtn.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
                setGymBtn.setTitle("!", for: .normal)
            }
        } catch {
            let error = error as NSError
            print("\(error)")
        }
    }
}

extension MainMenuVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        print("Place coordinates: \(place.coordinate)")
        
        let gym = Gym_Location(context: context)
        gym.name = place.name
        gym.latitude = place.coordinate.latitude
        gym.longitude = place.coordinate.longitude
        
        gymLocation = CLLocationCoordinate2D(latitude: gym.latitude, longitude: gym.longitude)
        
        ad.saveContext()
        print("Gym name: \(gym.name!)")
        print("Gym lat: \(gym.latitude)")
        print("Gym lng: \(gym.longitude)")
        dismiss(animated: true, completion: nil)
        attemptFetch()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
