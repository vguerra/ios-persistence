//
//  FavoriteActorViewController.swift
//  FavoriteActors
//
//  Created by Jason on 1/31/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class FavoriteActorViewController : UITableViewController, ActorPickerViewControllerDelegate {
    
    var actors = [Person]()
    
    var actorsFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("actorsArray").path!
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addActor")
    
        if let actors = NSKeyedUnarchiver.unarchiveObjectWithFile(actorsFilePath) as? [Person] {
            self.actors = actors
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // This method is invoked whenever the view appears, including when
        // it appears after the actor picker is dismissed. That makes it a 
        // good contender for saving the array
    }
    
    // Mark: - Actions
    
    func addActor() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ActorPickerViewController") as! ActorPickerViewController
        
        controller.delegate = self
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: - Actor Picker Delegate
    
    func actorPicker(actorPicker: ActorPickerViewController, didPickActor actor: Person?) {

        if let newActor = actor {
            
            // Check to see if we already have this actor
            for a in actors {
                if a.id == newActor.id {
                    return
                }
            }
            
            // If we didn't find any, then add (and maybe save the array?)
            self.actors.append(newActor)
            println("saving a new actor")
            
            // And reload the table
            self.tableView.reloadData()
            
            NSKeyedArchiver.archiveRootObject(self.actors, toFile: actorsFilePath)
        }
    }
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actors.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let actor = actors[indexPath.row]
        let CellIdentifier = "ActorCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! ActorTableViewCell
        
        cell.nameLabel!.text = actor.name
        cell.frameImageView.image = UIImage(named: "personFrame")
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        if let localImage = actor.image {
            cell.actorImageView.image = localImage
        } else if actor.imagePath == "" {
            cell.actorImageView.image = UIImage(named: "personNoImage")
        }
        
        // If the above cases don't work, then we should download the image
        
        else {
            
            // Set the placeholder
            cell.actorImageView.image = UIImage(named: "personPlaceholder")
            
            let size = TheMovieDB.sharedInstance().config.profileSizes[1]
            let task = TheMovieDB.sharedInstance().taskForImageWithSize(size, filePath: actor.imagePath) { (imageData, error) -> Void in
            
                if let data = imageData {
                    dispatch_async(dispatch_get_main_queue()) {
                        let image = UIImage(data: data)
                        actor.image = image
                        cell.actorImageView.image = image
                    }
                }
            }
            
            cell.taskToCancelifCellIsReused = task
        }
            
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("MovieListViewController") as! MovieListViewController
        
        controller.actor = actors[indexPath.row]
        
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            actors.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            break
        }
    }
}
