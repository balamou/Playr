//
//  NewModel.swift
//  playr
//
//  Created by Michel Balamou on 5/19/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]

//----------------------------------------------------------------------
// VIEWED
//----------------------------------------------------------------------
protocol Viewed
{
    // visible
    var id: Int {get set}
    var URL: String {get set}
    var duration: Int {get set}
    
    // optional
    var stoppedAt: Int? {get set}
    var poster: String? {get set}
    var title: String? {get set}
    

    func label() -> String
    func durationMin() -> String
}


//----------------------------------------------------------------------
// MOVIE
//----------------------------------------------------------------------
class Movie: Viewed
{
    var id: Int
    var URL: String
    var duration: Int
    
    // optional
    var stoppedAt: Int?
    var poster: String?
    var title: String?
    var desc: String?
    
    init?(json: [String: Any])
    {
        // Unwrap JSON
        guard let id = json["id"] as? Int,
                let URL = json["URL"] as? String,
                let duration = json["duration"] as? Int
        else {
                print("Error occured parsing JSON for Movie.\n")
                return nil
        }
        // Unwrap JSON
        
        self.id = id
        self.URL = State.shared.address + URL
        self.duration = duration
        
        // OPTIONAL
        self.stoppedAt = json["stopped_at"] as? Int
        self.poster = json["poster"] as? String
        self.desc = json["description"] as? String
        self.title = json["title"] as? String
    }
    
    // METHODS
    func label() -> String
    {
        return durationMin()
    }
    
    
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

//----------------------------------------------------------------------
// SERIES
//----------------------------------------------------------------------
class Series
{
    var series_id: Int
    var numSeasons: Int
    var episodes: [Int: [Episode]] = [:]
    var openSeason = 1
    
    var title: String?
    var desc: String?
    var poster: String?
    
     // METHODS
    init(series_id: Int, numSeasons: Int)
    {
        self.series_id = series_id
        self.numSeasons = numSeasons
    }
    
    init?(json: [String: Any])
    {
        guard let series_id = json["id"] as? Int,
              let num_seasons = json["num_seasons"] as? Int
        else
        {
            print("Error parsing json for series\n")
            return nil
        }
        
        self.series_id = series_id
        self.numSeasons = num_seasons
        
        
        // optional
        self.openSeason = json["open_season"] as? Int ?? 1
        self.title = json["title"] as? String
        self.desc = json["description"] as? String
        
        if let poster = json["poster"] as? String {
            self.poster = State.shared.address + poster
        }
    }
}

//----------------------------------------------------------------------
// EPISODE
//----------------------------------------------------------------------
class Episode: Viewed
{
    // VIEWED
    var id: Int
    var URL: String
    var duration: Int
    
    var stoppedAt: Int?
    var poster: String?
    var title: String?
    
    // SERIES
    var season: Int
    var episode: Int
    var plot: String?
    var thumbnail: String?
    
    var series_id: Int
    var mainSeries: Series?

    
    
    // METHODS
    init(_ id: Int, _ URL: String, _ duration: Int, _ season: Int, _ episode: Int, _ series_id: Int)
    {
        self.season = season
        self.episode = episode
        self.series_id = series_id
        
        self.id = id
        self.URL = URL
        self.duration = duration
    }
    
    
    convenience init?(json: [String: Any])
    {
        // UNWRAP JSON
        guard let id = json["id"] as? Int,
            let URL = json["URL"] as? String,
            let duration = json["duration"] as? Int,

            let season = json["season"] as? Int,
            let episode = json["episode"] as? Int,
            let series_id = json["series_id"] as? Int
            else
        {
                print("Ex1: Error occured parsing JSON for Movie\n")
                return nil
        }
        self.init(id, State.shared.address + URL, duration, season, episode, series_id)
        
        
        // OPTIONAL
        self.stoppedAt = json["stopped_at"] as? Int
        self.title =  json["title"] as? String
        self.plot = json["plot"] as? String
        if let t = json["thumbnail"] as? String {
            self.thumbnail = State.shared.address + t
        }
        
        
        // GET SERIES: OPTIONAL PART -> WILL NOT FAIL INITIALIZATION
        let s = Series(series_id: series_id, numSeasons: 0)
        
        if let poster = json["poster"] as? String {
            s.poster = State.shared.address + poster
        }
        
        s.desc = json["decription"] as? String
        self.mainSeries = s
    }
    
    func label() -> String
    {
        return "S\(season):E\(episode)" // ex: S1:E2
    }
    
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



