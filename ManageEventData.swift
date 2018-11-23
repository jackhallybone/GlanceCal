//
//  ManageEventData.swift
//  GlanceCal
//
//  Created by Jack Hallybone on 03/10/2018.
//

import Foundation

import UIKit
import EventKit

var eventStore = EKEventStore()

class ManageEventData {

    class func hasCalendarAccess() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)

        var hasAccess: Bool = false
        switch status {
            case .authorized:
                hasAccess = true
            default: // .notDetermined .restricted, .denied
                hasAccess = false // FIXME: for now you must open the app first anyway
        }

        return hasAccess
    }

    class func fetchEventData(daysFromToday: Int) -> (Date, Array<EKEvent>) {

        // Get the current datetime and calendar
        let date = Date()
        let calendar = Calendar.current

        // Create a starting date component at the current time on the target day
        var startDateComponents = DateComponents()
        startDateComponents.day = daysFromToday
        var startDate: Date? = nil
        startDate = calendar.date(byAdding: startDateComponents, to: date, wrappingComponents: false)

        // We need start of day to help us get the end of day
        let startOfTargetDay = calendar.startOfDay(for: startDate!)

        // If target date is not today, starting datetime should be the start of the day
        if !(daysFromToday == 0) {
            startDate = startOfTargetDay
        }

        // Create an ending datetime component at the end of the target day
        var endDateComponents = DateComponents()
        endDateComponents.day = 1 // Add a day, then...
        endDateComponents.second = -1 // ...remove one second to return to that day
        var endDate: Date? = nil
        endDate = calendar.date(byAdding: endDateComponents, to: startOfTargetDay, wrappingComponents: false)

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

    class func formatAllEvents(daysFromToday: Int, events: Array<EKEvent>) -> [Dictionary<String, Any>] {

        var data: [Dictionary<String, Any>] = []

        for event in events {
            let eventData = formatEventData(daysFromToday: daysFromToday, event: event)
            data.append(eventData)
        }

        return data
    }

    class func formatEventData(daysFromToday: Int, event: EKEvent) -> Dictionary<String, Any> {

        // NOTE: Strange things with optionals?

        // Extract and format the event data we are interested in
        let eventTitle = event.title ?? "Unnamed Event"
        let eventTime = formatEventTime(daysFromToday: daysFromToday, event: event)
        let eventLocation = event.location ?? "Unknown Location"
        let eventCalCol = UIColor.init(cgColor: event.calendar.cgColor)
        let eventSubtitle = formatSubtitleText(time: eventTime, location: eventLocation)

        // Build a dictionary of event data
        let eventData = [
            "title": eventTitle,
            "subtitle": eventSubtitle,
            "time": eventTime,
            "location": eventLocation,
            "color": eventCalCol
        ] as [String : Any]

        return eventData

    }

    class func formatEventTime(daysFromToday: Int, event: EKEvent) -> String {
        // Format time into a clean and descriptive string: "All Day" or "HH:MM to HH:MM"


        // NOTE: This is not very nicely done. It requires `daysFromToday` to trickle
        // down through several functions just to be used here and ruins their single action
        // functionality. Additionally, --:-- and ++:++ are not great... FIXME ASAP


        var eventTime = "All Day"
        if !(event.isAllDay) {

            // Get the current datetime and calendar
            let date = Date()
            let calendar = Calendar.current

            // Create a starting date component at the current time on the target day
            var startDateComponents = DateComponents()
            startDateComponents.day = daysFromToday
            var temp: Date? = nil
            temp = calendar.date(byAdding: startDateComponents, to: date, wrappingComponents: false)
            let targetDay = Calendar.current.component(.day, from: temp!)

            let eventStart = Calendar.current.component(.day, from: event.startDate)
            let eventEnd = Calendar.current.component(.day, from: event.endDate)

            let diffStart = eventStart - targetDay;
            let diffEnd = eventEnd - targetDay;

            let eventStartH = Calendar.current.component(.hour, from: event.startDate)
            let eventStartM = Calendar.current.component(.minute, from: event.startDate)

            let eventEndH = Calendar.current.component(.hour, from: event.endDate)
            let eventEndM = Calendar.current.component(.minute, from: event.endDate)

            // Form "HH:MM to HH:MM"
            eventTime = String(format: "%02d:%02d to %02d:%02d", eventStartH, eventStartM, eventEndH, eventEndM)

            var timeStart: String
            if (diffStart < 0) {
                timeStart = "--:--"
            } else if (diffStart > 0) {
                timeStart = "++:++"
            } else {
                timeStart = String(format: "%02d:%02d", eventStartH, eventStartM)
            }

            var timeEnd: String
            if (diffEnd < 0) {
                timeEnd = "--:--"
            } else if (diffEnd > 0) {
                timeEnd = "++:++"
            } else {
                timeEnd = String(format: "%02d:%02d", eventEndH, eventEndM)
            }

            if (diffStart < 0 && diffEnd > 0) {
                eventTime = "All Day"
            } else {
                // Form "HH:MM to HH:MM"
                eventTime = String(format: "%@ to %@", timeStart, timeEnd)
            }

        }

        return eventTime

    }

    class func formatSubtitleText(time: String, location: String) -> String {
        // Generate the subtitle as either "time | location" or just "time"

        var subtitle = String(format: "%@", time)
        if !(location.isEmpty) {
            subtitle = String(format: "%@  |  %@", time, location)
        }

        return subtitle

    }

}
