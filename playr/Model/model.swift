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
class Viewed: CustomStringConvertible
{
    var description: String {
        return "{\(URL), \(duration), \(stoppedAt ?? 0), \(poster ?? "N/A")}"
    }
    
    // visible
    var id: Int
    var URL: String
    var duration: Int
    
    // optional
    var stoppedAt: Int?
    var poster: String?
    var title: String?
    

    // METHODS
    init(id: Int, URL: String, duration: Int)
    {
        self.URL = URL
        self.duration = duration
        self.id = id
    }

    func label() -> String
    {
        print("Label not set\n")
        return "N/A"
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
// MOVIE
//----------------------------------------------------------------------
class Movie: Viewed
{
    var desc: String?
    
    init?(json: [String: Any])
    {
        // Unwrap JSON
        guard let id = json["id"] as? Int,
                let URL = json["URL"] as? String,
                let duration = json["duration"] as? Int,
            
                let stopped_at = json["stopped_at"] as? Int?,
                let poster = json["poster"] as? String?,
                let title = json["title"] as? String?,
                let desc = json["description"] as? String?
        else {
                print("Error occured parsing JSON for Movie.\n")
                return nil
        }
        // Unwrap JSON
        
        super.init(id: id, URL: URL, duration: duration)
        
        self.stoppedAt = stopped_at
        self.poster = poster
        self.desc = desc
        self.title = title
    }
    
    // METHODS
    override func label() -> String
    {
        return durationMin()
    }
}

//----------------------------------------------------------------------
// SERIES
//----------------------------------------------------------------------
class Series {
    var series_id: Int
    var numSeasons: Int
    var episodes: [Int: [Episode]] = [:]
    
    
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
        guard let series_id = json["ID"] as? Int,
            
            let title = json["title"] as? String?,
            let desc = json["description"] as? String?,
            let poster = json["poster"] as? String?
        else
        {
            print("Error parsing json for series\n")
            return nil
        }
        
        self.series_id = series_id
        self.numSeasons = 0
        
        self.title = title
        self.desc = desc
        
        if let poster = poster {
            self.poster = State.shared.address + poster
        }
    }
    
    func loadAllEpisodes()
    {
        // TODO: SEND REQUEST TO SERVER
    }
    
    func loadSeason(season: Int)
    {
        guard season<numSeasons else
        {
            return
        }
        
        // TODO: SEND REQUEST TO SERVER
    }
}

//----------------------------------------------------------------------
// EPISODE
//----------------------------------------------------------------------
class Episode: Viewed
{
    var season: Int
    var episode: Int
    var series_id: Int
    
    // optional
    var plot: String?
    var thumbnail: String?
    var mainSeries: Series?

    
    // METHODS
    init(_ id: Int, _ URL: String, _ duration: Int, _ season: Int, _ episode: Int, _ series_id: Int)
    {
        self.season = season
        self.episode = episode
        self.series_id = series_id
        
        super.init(id: id, URL: URL, duration: duration)
    }
    
    
    convenience init?(json: [String: Any])
    {
        // Unwrap JSON  -------------------------------------
        guard let id = json["id"] as? Int,
            let URL = json["URL"] as? String,
            let duration = json["duration"] as? Int,

            let season = json["season"] as? Int,
            let episode = json["episode"] as? Int,
            let series_id = json["series_id"] as? Int,
            
            // OPTIONALS
            let plot = json["plot"] as? String?,
            let thumbnail = json["thumbnail"] as? String?,
            let stopped_at = json["stopped_at"] as? Int?,
            let title = json["title"] as? String?
            else {
                print("Error occured parsing JSON for Movie\n")
                return nil
        }
        // Unwrap JSON  --------------------------------------
        
        self.init(id, URL, duration, season, episode, series_id)
        
        self.stoppedAt = stopped_at
        self.title = title
        self.plot = plot
        self.thumbnail = thumbnail
        
        
        // GET SERIES: OPTIONAL PART -> WILL NOT FAIL INITIALIZATION
        let s = Series(series_id: series_id, numSeasons: 0)
        
        if let poster = json["poster"] as? String {
            s.poster = State.shared.address + poster
        }
        
        s.desc = json["decription"] as? String
        self.mainSeries = s
    }
    
    override func label() -> String
    {
        return "S\(season):E\(episode)" // ex: S1:E2
    }
}



