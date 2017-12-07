//
//  EventDetailsViewController.swift
//  VenU App
//
//  Created by X Code User on 12/5/17.
//  Copyright © 2017 Nate Benson. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    @IBOutlet weak var googleImageView: UIImageView!
    @IBOutlet weak var EventName: UILabel!
    @IBOutlet weak var EventDandT: UILabel!
    @IBOutlet weak var EventLocation: UILabel!
    @IBOutlet weak var EventType: UILabel!
    @IBOutlet weak var EventDesc: UITextView!
    @IBAction func AttendButtonPressed(_ sender: UIButton) {
        //Attend Event
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
