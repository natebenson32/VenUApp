//
//  FirstViewController.swift
//  VenU App
//
//  Created by X Code User on 11/28/17.
//  Copyright © 2017 Nate Benson. All rights reserved.
//

import UIKit
import Eureka
import GooglePlacePicker

class SearchViewController: FormViewController {
    var location : GMSPlace?
    var delegate : Delegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Search")
            <<< DateRow(){
                $0.title = "Date"
                $0.value = Date(timeIntervalSinceNow: 0)
                $0.tag = "datetag"
            }
            <<< TimeInlineRow("Time"){
                $0.title = "Time"
                $0.value = Date().addingTimeInterval(60*60*24)
                $0.tag = "timetag"
            }
            +++ Section("VenU")
            <<< LabelRow () { row in
                row.title = "Location"
                row.value = "Tap to search"
                row.tag = "LocTag"
                var rules = RuleSet<String>()
                rules.add(rule: RuleClosure(closure: { (loc) -> ValidationError? in
                    if loc == "Tap to search" {
                        return ValidationError(msg: "You must select a location")
                    } else {
                        return nil
                    }
                }))
                row.add(ruleSet:rules)
                }.onCellSelection { cell, row in
                    // crank up Google's place picker when row is selected.
                    let autocompleteController = GMSAutocompleteViewController()
                    autocompleteController.delegate = self
                    self.present(autocompleteController, animated: true,
                                 completion: nil)
            }
            +++ Section("Description")
            <<< TextAreaRow(){
                $0.placeholder = "Enter details..."
                $0.tag = "desctag"
            }
            <<< ButtonRow(){
                $0.title = "Create"
                $0.onCellSelection(self.buttonTapped)
        }
    }
    
    
    
    func buttonTapped(cell: ButtonCellOf<String>, row: ButtonRow){
        let errors = self.form.validate()
        if errors.count > 0 {
            print("fix your errors!")
        } else {
            let nameRow : TextRow! = form.rowBy(tag: "nametag")
            let name = nameRow.value!
            
            // Date info
            let dateRow : DateRow! = form.rowBy(tag: "datetag")
            let date = dateRow.value! as Date
            
            // Time info
            let timeRow : TimeInlineRow! = form.rowBy(tag: "timetag")
            let time = timeRow.value!
            
            // Location info
            let lat = (self.location?.coordinate.latitude)!
            let lon = (self.location?.coordinate.longitude)!
            let loc = (self.location?.name)!
            let id = (self.location?.placeID)!
            
            // Description info
            let descRow : TextAreaRow! = form.rowBy(tag: "desctag")
            let desc = descRow.value!
            
            self.delegate?.set(inputData: EventObject(eventName: name, eventDate: date, eventTime: time, eventType: "", eventLoc: loc, eventDesc: desc, eventLat: lat, eventLon: lon, placeId: id))
            self.dismiss(animated: true, completion: nil)
            print("We got here boii")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}

protocol EventCreateDelegate {
    func set(inputData: EventObject)
}

extension AddEventViewController: GMSAutocompleteViewControllerDelegate {
    
    public func viewController(_ viewController: GMSAutocompleteViewController,
                               didFailAutocompleteWithError error: Error)
    {
        print(error.localizedDescription)
    }
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController,
                        didAutocompleteWith place: GMSPlace)
    {
        
        if let row = form.rowBy(tag: "LocTag") as? LabelRow {
            row.value = place.name
            row.validate()
            self.location = place
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func viewController(viewController: GMSAutocompleteViewController,
                        didFailAutocompleteWithError error: NSError)
    {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController)
    {
        self.dismiss(animated: true, completion: nil)
        let row: LabelRow? = form.rowBy(tag: "LocTag")
        row?.validate()
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController:
        GMSAutocompleteViewController)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController:
        GMSAutocompleteViewController)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

