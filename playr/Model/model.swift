//
//  model.swift
//  playr
//
//  Created by Michel Balamou on 5/13/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation


class User {
    var name: String
    var hash: String    // unique identifier
    
    init(withName name: String, _ hash: String)
    {
        self.name = name
        self.hash = hash
    }
}


enum FilmType {
    case series     // TV Show -> has episodes and season
    case movie      // Movie has a single video playing
}


class Viewed {
    //----------------------------------------------------------------------
    // MANDATORY ATTRIBUTES
    //----------------------------------------------------------------------
    var id: Int                 // id of the movie in the database
    var type: FilmType          // show or movie
    var URL: String = ""        // URL to play the episode/movie on click
    var duration: Int           // duration in seconds
    var stoppedAt: Int          // stopped at in seconds
    
    //----------------------------------------------------------------------
    // OPTIONAL ATTRIBUTES
    //----------------------------------------------------------------------
    var poster: String?         // url path to the image <- could be no poster uploaded yet
    
    // Not applicable for a movie --------
    var season: Int?
    var episode: Int?
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    init(_ id: Int, ofType type: FilmType, _ URL: String, _ duration: Int, _ stoppedAt: Int)
    {
        // mandatory
        self.id = id
        self.type = type
        self.URL = URL
        self.duration = duration
        self.stoppedAt = stoppedAt
    }
    
    // Generates a label:
    // ------------------------
    // Hours & minutes if movie
    // Season & episode if show
    func label() -> String
    {
        switch(type)
        {
        case .series:
            return "S\(season!):E\(episode!)" // ex: S1:E2
        case .movie:
            let info = sec2hours(duration) // convert seconds to hours & minutes
            return "\(info.hour) h \(info.minutes) min" // 2 h 8 min
        }
    }
    
    // Converts seconds to hours & minutes
    internal func sec2hours(_ seconds: Int) -> (hour: Int, minutes: Int)
    {
        let hours: Int = seconds / 3600
        let minutes: Int = (seconds % 3600) / 60
        
        return (hours, minutes)
    }
}




class Movie {
    //----------------------------------------------------------------------
    // MANDATORY ATTRIBUTES
    //----------------------------------------------------------------------
    var id: Int
    var type: FilmType
    var language: String = "En" // default is english
    
    //----------------------------------------------------------------------
    // OPTIONAL ATTRIBUTES
    //----------------------------------------------------------------------
    var desc: String?       // nil if not found on the server
    var poster: String?     // nil if not found on the server ~> use default
    var URL: String?        // nil if it is a tv series
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    init(_ id: Int, withType type: FilmType)
    {
        self.id = id
        self.type = type
    }
}



//--------------------------------------------------------------------------
// CLASSES WITH MORE TV-Series INFORMATION
//--------------------------------------------------------------------------

class Show {
    //----------------------------------------------------------------------
    // MANDATORY ATTRIBUTES
    //----------------------------------------------------------------------
    var id: Int
    var season: Int
    var episodes: [Episode]
    
    //----------------------------------------------------------------------
    // OPTIONAL ATTRIBUTES
    //----------------------------------------------------------------------
    var poster: String?
    var description: String?
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    init(_ id: Int, onSeason season: Int, withEpisodes episodes: [Episode])
    {
        self.id = id
        self.season = season
        self.episodes = episodes
    }
}

class Episode {
    //----------------------------------------------------------------------
    // MANDATORY ATTRIBUTES
    //----------------------------------------------------------------------
    var id: Int
    var title: String
    var duration: Int          // duration (in seconds)
    var URL: String
    
    //----------------------------------------------------------------------
    // OPTIONAL ATTRIBUTES
    //----------------------------------------------------------------------
    var stoppedAt: Int?        // nil if not viewed; stopped at (in seconds)
    var thumbnail: String?
    var description: String?
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    init(_ id: Int, withTitle title: String, atURL URL: String, _ duration: Int)
    {
        self.id = id
        self.title = title
        self.duration = duration
        self.URL = URL
    }
    
    
    // Return formatted duration for display
    func durationMin() -> String
    {
        let info = sec2hours(duration)
        
        if info.hour == 0 {
            return "\(info.minutes) min" // show only minutes
        } else {
            return "\(info.hour) h \(info.minutes) min"
        }
    }
    
    // Converts seconds to hours & minutes
    internal func sec2hours(_ seconds: Int) -> (hour: Int, minutes: Int)
    {
        let hours: Int = seconds / 3600
        let minutes: Int = (seconds % 3600) / 60
        
        return (hours, minutes)
    }
}



