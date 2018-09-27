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
        
        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            // Fallback on earlier versions
        }
        
        loadData()
    }
    
    // For iOS 10
    @available(iOS 10.0, *)
    @available(iOSApplicationExtension 10.0, *)
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
        
        for i in 1...10 {
            let eventData = [
                "title": String(format: "Title %d", i),
                "time": Date(),
                "location": "",
                "color": "RED"
                ] as [String : Any]
            data.append(eventData)
        }
        
        print("created", data.count, "events")
        
        //            self.tableView.reloadData()
        
        print("after reload call")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Table sees", data.count, "events")
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventItem", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]["title"] as! String?
        return cell
    }
    
}
