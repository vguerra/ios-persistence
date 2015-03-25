// MasterViewController.swift
//
//  MasterViewController.swift
//  FetchResultsControllerMasterDetail
//
//  Created by Jason on 3/24/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import CoreData

/**
* This MasterViewController conforms to the NSFetchedResultsControllerDelegate protocol. As a delegate
* it will be receiving invocations from an object. That object is a helper controller: the Fetch Results
* Controller.
*
* Visualize the MasterViewController when it is on the screen for a moment (or run the app and take a look)
* You will recall that it displays a table full of time stamps.
*
* In the versions of this code that we have seen so far these time stamps were stored in an array, and the
* array was used to populate the table. But if you look below you will see that there is no array in this class.
*
* How does the table get populated? What is this Fetch Results Controller? What are the delegate methods that we
* will use to hear from this controller? Those are the key questions to hold onto as you approach the code.
*/

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // The viewDidLoad method has two jobs in this view controller:
    // 1. Set the left and right navigation buttons. This is the same as last time we used MasterDetail
    // 2. Start up the fetchedResultsController. This is new.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the buttons
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        // Perform the fetch. This gets the machine rolling
        // We check for an error, but we don't expect one.
        var error: NSError? = nil
        
        fetchedResultsController.performFetch(&error)
        
        if let error = error? {
            println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }
    
    // MARK: - Insert new object
    
    // Create a new event, save the context.
    // This may be the most interesting method in the code. Notice the array is conspicuously missing.
    // How will this event end up in the table?
    
    func insertNewObject(sender: AnyObject) {
        let event = Event(context: context)
        
        event.timeStamp = NSDate()
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Our typical lazy context var, for convenient access to the shared Managed Object Context
    
    lazy var context: NSManagedObjectContext = {
            CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    // MARK: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
            let fetchRequest = NSFetchRequest()
            
            // Set the entity
            fetchRequest.entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.context)
            
            // Edit the sort key as appropriate.
            let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
            let sortDescriptors = [sortDescriptor]
            
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Create the Fetched Results Controller
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: "Master")
            
            // Set ourself as the delegate. This is the key relationship between this view conttoller, and
            // the fetched results controller
            fetchedResultsController.delegate = self
            
            // Return the fetched results controller. It will be the value of the lazy variable
            return fetchedResultsController
        } ()
    
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!)!
            let event = fetchedResultsController.objectAtIndexPath(indexPath!) as Event
            cell.textLabel!.text = event.timeStamp.description
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    // MARK: - Table View
    
    // These are fairly different that table view data source methods we have written before. 
    // Notice how heavily they lean on the Fetched Results Controller.
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        let event = self.fetchedResultsController.objectAtIndexPath(indexPath) as Event
        
        cell.textLabel!.text = event.timeStamp.description
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            let event = self.fetchedResultsController.objectAtIndexPath(indexPath) as Event
            context.deleteObject(event)
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    // MARK: - Segues
    
    // This is a fairly typical for a Master Detail type app. But is makes an interesting use of the
    // Fetched Results Controller. Check it out.
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
                (segue.destinationViewController as DetailViewController).detailItem = object
            }
        }
    }
}