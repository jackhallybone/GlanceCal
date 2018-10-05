//
//  TodayViewController.swift
//  Tomorrow Glance
//
//  Created by Jack Hallybone on 28/09/2018.
//

// TOMORROW

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {

    // Note: Also connected Table View outlets to Today View Controller
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displayLabel: UILabel!

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

        if ManageEventData.hasCalendarAccess() {
            // Fetch all events on target day and process them if there are any
            let (_, events) = ManageEventData.fetchEventData(daysFromToday: 1) // = TOMORROW
            if events.count == 0 {
                noEvents()
            } else {
                data = ManageEventData.formatAllEvents(events: events) // Overwrite event data
            }
        } else {
            accessDenied()
        }

    }

    func accessDenied() {
        // If no events on target day, hide the event table and show the no event label instead
        tableView.alpha = 0
        displayLabel.text = "Calendar Access is Required"
        displayLabel.alpha = 1
    }

    func noEvents() {
        // If no events on target day, hide the event table and show the no event label instead
        tableView.alpha = 0
        displayLabel.text = "No Events Scheduled"
        displayLabel.alpha = 0.5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventItem", for: indexPath)

        cell.textLabel?.text = data[indexPath.row]["title"] as? String
        cell.detailTextLabel?.text = data[indexPath.row]["subtitle"] as? String

        return cell
    }

}
