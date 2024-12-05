//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Vishal More on 02/12/24.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import CTNotificationContent

class NotificationViewController: CTNotificationViewController {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
        
        
    }

}
