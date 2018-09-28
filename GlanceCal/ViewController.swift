//
//  ViewController.swift
//  GlanceCal
//
//  Created by Jack Hallybone on 26/09/2018.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var goToSettings: UIButton!

    var eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Begin app process by querying Calendar access privacy access
        evaluateEventKitAccess()
    }

    func evaluateEventKitAccess() {

        // NOTE: Is the the best way to do this? iOS only allows one access request anyway?

        let authorizationStatus = EKEventStore.authorizationStatus(for: .event)

        switch authorizationStatus {
            case .authorized:
                accessGranted()
            case .notDetermined:
                requestEventKitAccess()
            case .restricted:
                accessDenied()
            case .denied:
                accessDenied()
            // NOTE: Do I need a default? (see style guide?)
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
        requestLabel.alpha = 1
        goToSettings.alpha = 1
    }

    @IBAction func goToSettings(_ sender: Any) {
        // Open system app settings to allow user to grant calendar access
        if let openSettingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(openSettingsUrl, options: [:], completionHandler: nil)
        }
    }

    func accessGranted() {
        print("Calendar Access Granted")

        // Display prompt for user to use the extensions not the host app itself
        requestLabel.text = "See Today View Widget"
        requestLabel.alpha = 1

        // NOTE: For now, get event data and print to console for testing
        printDataForDay(daysFromToday: 0) // today
        printDataForDay(daysFromToday: 1) // tomorrow
    }

    func printDataForDay(daysFromToday: Int) {

        // Fetch all events on target day
        let (date, events) = fetchEventData(daysFromToday: daysFromToday)

        print("TARGET DAY:", date)

        if events.count == 0 {
            // If no events, display this
            print("No Events Scheduled")
        } else {
            // Else, format and display event list
            print(events.count, "Event(s) Scheduled:")
            for event in events {
                var eventData = formatEventData(event: event)
                print("\t", eventData["title"]!, "(", eventData["time"]!, ")") // loc, color
            }
        }
    }

// --------------------------------------------------------

    func fetchEventData(daysFromToday: Int) -> (Date, Array<EKEvent>) {

        // Get the current datetime and calendar
        let date = Date()
        let calendar = Calendar.current

        // Create a starting date component at the current time on the target day
        var startDateComponents = DateComponents()
        startDateComponents.day = daysFromToday
        var startDate: Date? = nil
        startDate = calendar.date(byAdding: startDateComponents, to: date, wrappingComponents: false)

        // If target date is not today, starting datetime should be the start of the day
        let startOfTargetDay = Calendar.current.startOfDay(for: startDate!)
        if !(daysFromToday == 0) {
            startDate = startOfTargetDay
        }

        // Create an ending datetime component at the end of the target day
        var endDateComponents = DateComponents()
        endDateComponents.day = daysFromToday + 1 // Add a day to the target day then...
        endDateComponents.second = -1 // ...remove one second to return to that day
        let endDate = calendar.date(byAdding: endDateComponents, to: startOfTargetDay, wrappingComponents: false)

        // Create a predicate with the required start and end datetimes, for all calendars
        var predicateEvent: NSPredicate? = nil
        if let sDate = startDate, let eDate = endDate {
            predicateEvent = eventStore.predicateForEvents(withStart: sDate, end: eDate, calendars: nil)
        }

        // Fetch all events that match this predicate
        var events: [EKEvent]? = nil
        if let aPredicate = predicateEvent {
            events = eventStore.events(matching: aPredicate)
        }

        // Return the actual start date and the list of events
        return (startDate!, events!)

    }


    func formatEventData(event: EKEvent) -> Dictionary<String, Any> {

        // NOTE: Strange things with optionals?

        // Extract the event data we are interested in
        let eventTitle = event.title ?? "Unnamed Event"
        let eventLocation = event.location ?? "Unknown Location"
        let eventCalCol = UIColor.init(cgColor: event.calendar.cgColor)

        // Format time into a clean and descriptive string: "All Day" or "HH:MM to HH:MM"
        var eventTime = "Unknown Time"
        if event.isAllDay {
            eventTime = "All Day"
        } else {
            let eventStartH = Calendar.current.component(.hour, from: event.startDate)
            let eventStartM = Calendar.current.component(.minute, from: event.startDate)

            let eventEndH = Calendar.current.component(.hour, from: event.endDate)
            let eventEndM = Calendar.current.component(.minute, from: event.endDate)

            // Form "HH:MM to HH:MM"
            eventTime = String(format: "%02d:%02d to %02d:%02d", eventStartH, eventStartM, eventEndH, eventEndM)

        }

        // Build a dictionary of event data
        let eventData = [
            "title": eventTitle,
            "time": eventTime,
            "location": eventLocation,
            "color": eventCalCol
            ] as [String : Any]

        return eventData

    }

}
