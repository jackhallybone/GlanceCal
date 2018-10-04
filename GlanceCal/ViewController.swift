//
//  ViewController.swift
//  GlanceCal
//
//  Created by Jack Hallybone on 26/09/2018.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var goToSettingsButton: UIButton!

    var eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Begin app process by querying Calendar access privacy access
        evaluateEventKitAccess()
    }

    func evaluateEventKitAccess() {

        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
            case .authorized:
                accessGranted()
            case .notDetermined:
                requestEventKitAccess()
            case .restricted:
                accessDenied()
            case .denied:
                accessDenied()
        }
    }

    func requestEventKitAccess() {

        // Fire (async) calendar privacy access request
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGrantedCalendar: Bool, error: Error?) in

            // Return to main thread and perform action based on response
            if accessGrantedCalendar {
                DispatchQueue.main.async {
                    self.accessGranted()
                }
            } else {
                DispatchQueue.main.async {
                    self.accessDenied()
                }
            }
        })
    }

    func accessDenied() {
        print("Calendar Access Denied")

        // Display prompt for user to change their settings to allow access
        displayLabel.text = "Calendar Access is Required"
        displayLabel.alpha = 1
        goToSettingsButton.alpha = 1
    }

    @IBAction func goToSettingsButton(_ sender: Any) {
        // Open system app settings to allow user to grant calendar access
        if let openSettingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(openSettingsUrl, options: [:], completionHandler: nil)
        }
    }

    func accessGranted() {
        print("Calendar Access Granted")

        // Display prompt for user to use the extensions not the host app itself
        displayLabel.text = "See Today View Widget(s)"
        displayLabel.alpha = 1
        goToSettingsButton.alpha = 0
    }

}
