//
//  SecondViewController.swift
//  VenU App
//
//  Created by X Code User on 11/28/17.
//  Copyright © 2017 Nate Benson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class DashboardViewController: UITableViewController, UINavigationControllerDelegate {
    var entry : EventObject!
    var userId : String!
    var entries : [EventObject] = []
    var entryToEdit : EventObject?
    var tableViewData : [(sectionHeader: String, entries: [EventObject])]?
    
    fileprivate var ref : DatabaseReference?
    fileprivate var storageRef : StorageReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        //self.clearsSelectionOnViewWillAppear = true
        let model = EventObjectModel()
        self.entries = model.getEventObjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.ref = Database.database().reference().child(self.userId).child(self.entry.key!)
        self.configureStorage()
        self.registerForFireBaseUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let r = self.ref {
            r.removeAllObservers()
        }
    }
    
    func configureStorage() {
        let storageURL = FirebaseApp.app()?.options.storageBucket
        self.storageRef = Storage.storage().reference(forURL: "gs://" + storageURL!)
    }
    
    func registerForFireBaseUpdates()
    {
        
        self.ref!.child("entries").observe(.value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }
            if let postDict = snapshot.value as? [String : AnyObject] {
                var tmpItems = [EventObject]()
                for (key,val) in postDict.enumerated() {
                    print("key = \(key) and val = \(val)")
                    let entry = val.1 as! Dictionary<String,AnyObject>
                    print ("entry=\(entry)")
                    let key = val.0
                    let name : String? = entry["name"] as! String?
                    let date : Date? = entry["date"] as! Date?
                    let time : Date? = entry["time"] as! Date?
                    let type : String? = entry["type"] as! String?
                    let loc : String? = entry["loc"] as! String?
                    let desc : String? = entry["desc"] as! String?
                    let lat : Double? = entry["lat"] as! Double?
                    let lon : Double? = entry["lon"] as! Double?
                    let pub : Bool? = entry["pub"] as! Bool?
                    let id : String? = entry["id"] as! String?

                    tmpItems.append(EventObject(key: key, eventName: name, eventDate: date, eventTime: time, eventType: type, eventLoc: loc, eventDesc: desc, eventLat: lat, eventLon: lon, eventPub: pub, placeId: id))
                }
                strongSelf.entries = tmpItems
                //strongSelf.entries.sort {$0.date! > $1.date! }
                //strongSelf.partitionIntoDailySections(entries: tmpItems)
            }
        })
    }
    
    @IBAction func addEntryButtonPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: "Would you like to add an event?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // Do nothing
        }
        alertController.addAction(cancelAction)
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { (action) in
            self.performSegue(withIdentifier: "createSegue", sender: self)
        }
        alertController.addAction(continueAction)
        
        self.present(alertController, animated: true) {
            self.entryToEdit = nil
        }
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.tableViewData {
            return data[section].entries.count
        } else {
            return 0
        }
    }
    
    //override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //}
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FancyCell", for: indexPath) as! EventTableViewCell

        let entry = (self.tableViewData?[indexPath.section].entries[indexPath.row])!

        
//        cell.eName?.text = entry.eventName
//        cell.eTime?.text = entry.eventTime?.short
//        cell.eDate?.text = entry.eventDate?.short
//        cell.eType?.text = entry.eventType
        
        cell.setValues(entry: entry)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Prepares for segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createSegue" {
            if let dest = segue.destination as? AddEventViewController {
                dest.entry = self.entryToEdit
                //dest.delegate = self
            }
        }
    }


}
//Add Event set function
extension DashboardViewController : EventCreateDelegate {
    func set(inputData: EventObject) {
        let vals = self.toDictionary(vals: inputData)
        _ = self.saveEntryToFirebase(key: inputData.key, ref: self.ref, vals: vals)
    }
    
    func saveEntryToFirebase(key: String?, ref: DatabaseReference?, vals: NSMutableDictionary) -> DatabaseReference? {
        var child : DatabaseReference?
    
        if let k = key {
            child = ref?.child("entries").child(k)
            child?.setValue(vals)
        } else {
            child = ref?.child("entries").childByAutoId()
            child?.setValue(vals)
        }
    
        return child
    }
    
    func toDictionary(vals: EventObject) -> NSMutableDictionary {
        return [
            "name": vals.eventName! as NSString,
            "date": vals.eventDate! as NSDate,
            "time": vals.eventTime! as NSDate,
            "type" : vals.eventType! as NSString,
            "loc" : vals.eventLoc! as NSString,
            "desc" : vals.eventDesc! as NSString,
            "lat" : vals.eventLat! as NSNumber,
            "lon" : vals.eventLon! as NSNumber,
            "pub" : vals.eventPub! as NSNumber,
            "id" : vals.placeId! as NSString
        ]
    }
}

extension Date {
    struct Formatter {
        static let short: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyy"
            return formatter
        }()
    }
    
    var short: String {
        return Formatter.short.string(from: self)
    }
}

extension String {
    var dateFromShort: Date? {
        return Date.Formatter.short.date(from: self)
    }
}
