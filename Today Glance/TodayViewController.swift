//
//  TodayViewController.swift
//  Today Glance
//
//  Created by Jack Hallybone on 27/09/2018.
//

// TODAY

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {

    let TARGET_DAY = 0 // TODAY

    // Note: Also connected Table View outlets to Today View Controller
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displayLabel: UILabel!

    fileprivate var data: [Dictionary<String, Any>] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.

        loadData()
        setWidgetShowMore()
    }

    func setWidgetShowMore() {
        // 2 or less events do not need a "show more" button
        if data.count <= 2 {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        } else {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            // Custom cells set to a height of 55
            preferredContentSize = CGSize(width: 0.0, height: 55 * CGFloat(data.count))
        } else {
            preferredContentSize = maxSize
        }
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        loadData()

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        completionHandler(NCUpdateResult.newData)
    }

    func loadData() {

        data.removeAll()

        if ManageEventData.hasCalendarAccess() {
            // Fetch all events on target day and process them if there are any
            let (_, events) = ManageEventData.fetchEventData(daysFromToday: TARGET_DAY)
            if events.count == 0 {
                noEvents()
            } else {
                data = ManageEventData.formatAllEvents(daysFromToday: TARGET_DAY, events: events) // Overwrite event data
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

        let cell:TodayCustomCell = self.tableView.dequeueReusableCell(withIdentifier: "eventItem") as! TodayCustomCell

        cell.cellColorView.backgroundColor = data[indexPath.row]["color"] as? UIColor
        cell.cellColorView.layer.cornerRadius = 2.0
        cell.cellColorView.clipsToBounds = true

        cell.cellTitleLabel.text = data[indexPath.row]["title"] as? String
        cell.cellSubtitleLabel.text = data[indexPath.row]["subtitle"] as? String

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Create a starting date component at the current time on the target day
        var dateComponents = DateComponents()
        dateComponents.day = TARGET_DAY
        let date = Calendar.current.date(byAdding: dateComponents, to: Date(), wrappingComponents: false)

        let interval = date!.timeIntervalSinceReferenceDate
        if let url = URL(string: "calshow:\(interval)") {
            extensionContext?.open(url)
        }

    }

}
