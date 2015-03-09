//
//  MasterViewController.swift
//  MasterDetail-CoreData-1
//
//  Created by Jason on 3/9/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var events = [Event]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        /**
         * Step 3: initialize the events array by invoking fetchAllEvents. 
         */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {

        /**
         * Step 4 - insert a new Event into the shared context. See actorPicker(:didPickActor) for an example
         */
        
        tableView.reloadData()
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showDetail" {

            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = events[indexPath.row]
                (segue.destinationViewController as DetailViewController).detailItem = object
            }
        }
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let event = events[indexPath.row]
        
        cell.textLabel!.text = event.timeStamp.description
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
                // How do we delete a managed object? An interesting, open question.
        }
    }

    // MARK: - Core Data Fetch Helpers
    
    /**
     * Step 1: Add the sharedContext convenience property. See the FavoriteActorsViewController.swift for an example.
     */
    
    /**
     * Step 2: Add the fetchAllEvents. See fetchAllActors() FavoriteActorsViewController.swift for an example.
     */
}

