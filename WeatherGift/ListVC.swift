//
//  ListVC.swift
//  WeatherGift
//
//  Created by Linda Chen on 10/17/17.
//  Copyright © 2017 Synestha. All rights reserved.
//

import UIKit
import GooglePlaces

class ListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    
    var currentPage = 0
    var locationsArray = [WeatherLocation ]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK:- Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToPageVC" {
            let controller = segue.destination as! PageVC
            currentPage = (tableView.indexPathForSelectedRow?.row)!
            controller.currentPage = currentPage
            controller.locationsArray = locationsArray
        }
    }
    
    // MARK: - IBActions
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing == true {
            tableView.setEditing(false, animated: true)
            editBarButton.title = "Edit"
            addBarButton.isEnabled = true
        } else {
            tableView.setEditing(true, animated: true)
            editBarButton.title = "Done"
            addBarButton.isEnabled = false
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func saveUserDefaults() {
        var locationsDefaultsArray = [WeatherUserDefault]()
        locationsDefaultsArray = locationsArray
        let locationsData = NSKeyedArchiver.archivedData(withRootObject: locationsDefaultsArray)
        UserDefaults.standard.set(locationsData, forKey: "locationsData")
    }
    
}


//Table extension
extension ListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        cell.textLabel?.text = locationsArray[indexPath.row].name
        return cell
    }
    
    
    // MARK:- Editing Functions
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            locationsArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveUserDefaults()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // First make a copy of the item that you are going to move
        let itemToMove = locationsArray[sourceIndexPath.row]
        // Delete item from teh original location (pre-move)
        locationsArray.remove(at: sourceIndexPath.row)
        // Insert item into the "to", post-move, location
        locationsArray.insert(itemToMove, at: destinationIndexPath.row)
        saveUserDefaults()
    }
    
    // MARK:- Freeze the First Cell.
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.row == 0 ? false : true )
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.row == 0 {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    func updateTable(place: GMSPlace) {
        let newIndexPath = IndexPath(row: locationsArray.count, section: 0)
        var newLocation = WeatherLocation()
        newLocation.name = place.name
        let latitude = place.coordinate.latitude
        let longitude = place.coordinate.longitude
        newLocation.coordinates = "\(latitude),\(longitude)"
        locationsArray.append(newLocation)

        tableView.insertRows(at: [newIndexPath], with: .automatic)
    
        tableView.reloadData()
        saveUserDefaults()
    }
}


//Places extension
extension ListVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        updateTable(place: place)
        dismiss(animated: true, completion: nil)
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
