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


class Viewed: ModelNetwork, CustomStringConvertible {
    
    var description: String {
        return "Viewed: \(id), \(type), \(URL), \(duration), \(stoppedAt), \(self.label())"
    }
    
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
    var desc: String?
    
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
    
    
    //----------------------------------------------------------------------
    // NERWORK
    //----------------------------------------------------------------------
    override init()
    {
        // mandatory
        self.id = 0
        self.type = .series
        self.URL = ""
        self.duration = 0
        self.stoppedAt = 0
    }
    
    override func json(_ response: JSONDictionary?)
    {
        guard let array = response!["viewed"] as? [Any] else
        {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        var index = 0
        for returnedDictionary in array
        {
            if let dict = returnedDictionary as? JSONDictionary,
                let sid = dict["Series_id"] as? String, let Series_id = Int(sid),
                let seas = dict["Season"] as? String, let Season = Int(seas),
                let ep = dict["Episode"] as? String, let Episode = Int(ep),
                let Poster = dict["Poster"] as? String,
                let dur = dict["Duration"] as? String, let Duration = Int(dur),
                let stp = dict["StoppedAt"] as? String, let StoppedAt = Int(stp),
                let URL = dict["URL"] as? String,
                let desc = dict["Description"] as? String
            {
                let item = Viewed(Series_id, ofType: .series, State.address + URL, Duration, StoppedAt)
                item.season = Season
                item.episode = Episode
                item.poster = State.address + Poster
                item.desc = desc
                
                self.results.append(item)
                index += 1
            }
            else
            {
                errorMessage += "Problem parsing dictionary\n"
            }
        }
    }
    
    func load(userid: Int, completion: @escaping QueryResult)
    {
        self.urlPath = State.address + "requests/get_viewed.php"
        self.query = "user_id=\(userid)"
        
        self.getSearchResults(completion: completion)
    }
}




class Movie: ModelNetwork, CustomStringConvertible {
    
    var description: String {
        return "Movie: \(id), \(type), \(language), \(title), \(desc ?? "nil"), \(poster ?? "nil"), \(URL ?? "nil")"
    }
    
    //----------------------------------------------------------------------
    // MANDATORY ATTRIBUTES
    //----------------------------------------------------------------------
    var id: Int
    var type: FilmType
    var language: String = "En" // default is english
    var title: String
    
    //----------------------------------------------------------------------
    // OPTIONAL ATTRIBUTES
    //----------------------------------------------------------------------
    var desc: String?       // nil if not found on the server
    var poster: String?     // nil if not found on the server ~> use default
    var URL: String?        // nil if it is a tv series
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    init(_ id: Int, withType type: FilmType, title: String)
    {
        self.id = id
        self.type = type
        self.title = title
    }
    
    //----------------------------------------------------------------------
    // NERWORK
    //----------------------------------------------------------------------
    override init()
    {
        self.id = 0
        self.type = .series
        self.title = "N/A"
    }
    
    override func json(_ response: JSONDictionary?)
    {
        guard let array = response!["movies"] as? [Any] else
        {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        var index = 0
        for returnedDictionary in array
        {
            if let dict = returnedDictionary as? JSONDictionary,
                let id = dict["ID"] as? String,
                let Title = dict["Title"] as? String,
                let Desc = dict["Description"] as? String,
                let Poster = dict["Poster"] as? String
             {
                let item = Movie(Int(id) ?? 0, withType: .series, title: Title)
                item.desc = Desc
                item.poster = State.address + Poster
                self.results.append(item)
                index += 1
            }
            else
            {
                errorMessage += "Problem parsing dictionary\n"
            }
        }
    }
    
    func load(completion: @escaping QueryResult)
    {
        self.urlPath = State.address + "requests/get_movies.php"
        self.query = "FilmType=series&language=\(State.language)"
        
        self.getSearchResults(completion: completion)
    }
}



//--------------------------------------------------------------------------
// CLASSES WITH MORE TV-Series INFORMATION
//--------------------------------------------------------------------------

class Show: ModelNetwork {
    //----------------------------------------------------------------------
    // MANDATORY ATTRIBUTES
    //----------------------------------------------------------------------
    var id: Int
    var season: Int
    var episodes: [Episode] = []
    
    //----------------------------------------------------------------------
    // OPTIONAL ATTRIBUTES
    //----------------------------------------------------------------------
    var poster: String?
    var description: String?
    
    //----------------------------------------------------------------------
    // METHODS
    //----------------------------------------------------------------------
    init(_ id: Int, onSeason season: Int)
    {
        self.id = id
        self.season = season
    }
    
    //----------------------------------------------------------------------
    // NERWORK
    //----------------------------------------------------------------------
    
    override func json(_ response: JSONDictionary?)
    {
        guard let array = response!["episodes"] as? [Any] else
        {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        var index = 0
        for returnedDictionary in array
        {
            if let dict = returnedDictionary as? JSONDictionary,
                let id_ = dict["ID"] as? String,
                let Title = dict["Title"] as? String,
                let EpisodeNum = dict["Episode"] as? String,
                let Desc = dict["Description"] as? String,
                let url = dict["URL"] as? String,
                let Thumbnail = dict["Thumbnail"] as? String,
                let Duration = dict["Duration"] as? String,
                let StoppedAt = dict["StoppedAt"] as? String
            {
                let item = Episode(Int(id_) ?? 0, episodeNum: Int(EpisodeNum) ?? 0, withTitle: Title, atURL: State.address + url, Int(Duration) ?? 1)
                item.stoppedAt = Int(StoppedAt)
                item.thumbnail = State.address + Thumbnail
                item.description = Desc
                
                self.results.append(item)
                index += 1
            }
            else
            {
                errorMessage += "Problem parsing dictionary\n"
            }
        }
    }
    
    func load(completion: @escaping QueryResult)
    {
        self.urlPath = State.address + "requests/get_episodes.php"
        self.query = "user_id=\(State.user_id)&series_id=\(self.id)&season=\(self.season)"
        
        self.getSearchResults(completion: completion)
    }
}

class Episode {
    //----------------------------------------------------------------------
    // MANDATORY ATTRIBUTES
    //----------------------------------------------------------------------
    var id: Int
    var episodeNum: Int
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
    init(_ id: Int, episodeNum epNum: Int, withTitle title: String, atURL URL: String, _ duration: Int)
    {
        self.id = id
        self.title = title
        self.duration = duration
        self.URL = URL
        self.episodeNum = epNum
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


//----------------------------------------------------------------------------
//
//                           NETWRORK PARSING
//                       ~~~~~~~~~~~~~~~~~~~~~~~
//
//----------------------------------------------------------------------------



