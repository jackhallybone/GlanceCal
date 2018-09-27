//
//  TodayViewController.swift
//  Today Glance
//
//  Created by Jack Hallybone on 27/09/2018.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    // Note: Also connected Table View outlets to Today View Controller
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var data: [Dictionary<String, Any>] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        self.preferredContentSize = CGSize(width: 320, height: CGFloat(data.count)*121 + 44)
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        loadData()
    }
    
    // FIXME: "See More" button expands but not to the size of the content...

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        self.preferredContentSize = (activeDisplayMode == .expanded) ? CGSize(width: 320, height: CGFloat(data.count)*121 + 44) : CGSize(width: maxSize.width, height: 110)
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
        
        for i in 1...6 {
            let eventData = [
                "title": String(format: "Event Title (%d)", i),
                "time": "11:00 to 12:00",
                "location": "123, Any Road, Any Town, 123 XYZ",
                "color": "RED"
                ] as [String : Any]
            data.append(eventData)
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventItem", for: indexPath)

        // Optionals?!?
        let subtitle = String(format: "%@  |  %@", (data[indexPath.row]["time"] as? String)!, (data[indexPath.row]["location"] as? String)!)
        
        cell.textLabel?.text = data[indexPath.row]["title"] as? String
        cell.detailTextLabel?.text = subtitle

        return cell
    }
    
}