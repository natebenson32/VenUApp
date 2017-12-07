//
//  EventTableViewCell.swift
//  VenU App
//
//  Created by X Code User on 11/30/17.
//  Copyright © 2017 Nate Benson. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eName: UILabel!
    @IBOutlet weak var eTime: UILabel!
    @IBOutlet weak var eDate: UILabel!
    @IBOutlet weak var eType: UILabel!
    @IBOutlet weak var transView: UIView!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    var entry : EventObject?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setValues(entry: EventObject) {
        self.entry = entry
        self.eName.text = entry.eventName
        self.eTime.text = entry.eventTime?.short
        self.eDate.text = entry.eventDate?.short
        self.eType.text = entry.eventType
    }

}
