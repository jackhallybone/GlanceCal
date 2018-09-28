//
//  TodayViewController.swift
//  Today Glance
//
//  Created by Jack Hallybone on 27/09/2018.
//

import UIKit
import NotificationCenter
import EventKit

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    // Note: Also connected Table View outlets to Today View Controller
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventsLabel: UILabel!
    
    var eventStore = EKEventStore()
    
    fileprivate var data: [Dictionary<String, Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        loadData()
    }
    
    // FIXME: "See More" button expands but not to the size of the content...
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        if activeDisplayMode == .expanded
        {
            preferredContentSize = CGSize(width: 0.0, height: 60 * CGFloat(data.count))
        }
        else
        {
            preferredContentSize = maxSize
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        loadData()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func loadData() {
        
        data.removeAll()
        
        //        for i in 1...5 {
        //            let eventData = [
        //                "title": String(format: "Event Title (%d)", i),
        //                "time": "11:00 to 12:00",
        //                "location": "123, Any Road, Any Town, 123 XYZ",
        //                "color": "RED"
        //                ] as [String : Any]
        //            data.append(eventData)
        //        }
        //
        //        if data.count == 0{
        //            noEvents()
        //        }
        
        let (_, events) = fetchEventData(daysFromToday: 0) // 0 days from today = today
        
        if events.count == 0 {
            noEvents()
        } else {
            for event in events {
                let eventData = formatEventData(event: event)
                data.append(eventData)
            }
        }
        
    }
    
    func noEvents() {
        tableView.alpha = 0
        noEventsLabel.alpha = 0.5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventItem", for: indexPath)
        
        // Optionals?!?
        
        var subtitle: String? = nil

        if ((data[indexPath.row]["location"] as? String)!).isEmpty {
            subtitle = String(format: "%@", (data[indexPath.row]["time"] as? String)!)
        } else {
            subtitle = String(format: "%@  |  %@", (data[indexPath.row]["time"] as? String)!, (data[indexPath.row]["location"] as? String)!)
        }
        
        cell.textLabel?.text = data[indexPath.row]["title"] as? String
        cell.detailTextLabel?.text = subtitle
        
        return cell
    }
    
    
    
    
    
    
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
        
        // Format time into a clean and descriptive string
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
        
        // Build a dictonary of event data
        let eventData = [
            "title": eventTitle,
            "time": eventTime,
            "location": eventLocation,
            "color": eventCalCol
            ] as [String : Any]
        
        return eventData
        
    }
    
    
}
