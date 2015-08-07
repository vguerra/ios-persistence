//
//  Movie.swift
//  TheMovieDB
//
//  Created by Jason on 1/11/15.
//

import UIKit

class Movie : NSObject, NSCoding {
    
    struct Keys {
        static let Title = "title"
        static let PosterPath = "poster_path"
        static let ReleaseDate = "release_date"
    }
    
    var title = ""
    var id = 0
    var posterPath: String? = nil
    var releaseDate: NSDate? = nil
        
    init(dictionary: [String : AnyObject]) {
        title = dictionary[Keys.Title] as! String
        id = dictionary[TheMovieDB.Keys.ID] as! Int
        posterPath = dictionary[Keys.PosterPath] as? String
        
        if let releaseDateString = dictionary[Keys.ReleaseDate] as? String {
            releaseDate = TheMovieDB.sharedDateFormatter.dateFromString(releaseDateString)
        }
    }
    
    
    /**
        posterImage is a computed property. From outside of the class is should look like objects
        have a direct handle to their image. In fact, they store them in an imageCache. The
        cache stores the images into the documents directory, and keeps a resonable number of
        them in memory.
    */
    
    var posterImage: UIImage? {
        
        get {
            return TheMovieDB.Caches.imageCache.imageWithIdentifier(posterPath)
        }
        
        set {
            TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: posterPath!)
        }
    }
    
    // MARK: Conforming to NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: Keys.Title)
        aCoder.encodeObject(posterPath, forKey: Keys.PosterPath)
        aCoder.encodeObject(releaseDate, forKey: Keys.ReleaseDate)
        aCoder.encodeObject(id, forKey: "id")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        title = aDecoder.decodeObjectForKey(Keys.Title) as! String
        posterPath = aDecoder.decodeObjectForKey(Keys.PosterPath) as? String
        releaseDate = aDecoder.decodeObjectForKey(Keys.ReleaseDate) as? NSDate
        aDecoder.decodeObjectForKey("id") as! Int
    }
}



