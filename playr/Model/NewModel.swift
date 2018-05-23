//
//  NewModel.swift
//  playr
//
//  Created by Michel Balamou on 5/19/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation

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
    
    func displayInfo() // displays all the info about series/movie
    {
        print("Display info not set\n")
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
    

    // displays all the info about series/movie
    override func displayInfo()
    {
        
    }
    
}

//----------------------------------------------------------------------
// SERIES
//----------------------------------------------------------------------
class Series {
    var series_id: Int
    var numSeasons: Int
    var displaySeason: Int = 1
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
    
    // displays all the info about series/movie
    override func displayInfo()
    {
        
    }
}



//----------------------------------------------------------------------------
//
//                           NETWRORK MODEL
//                       ~~~~~~~~~~~~~~~~~~~~~~~
//
//----------------------------------------------------------------------------
class NetworkModel
{
    var viewed: [Viewed] = []       // ??
    var movies: [Movie] = []         // 10 at a time
    var series: [Series] = []       // 10 at a time
    var seriesOpened: [Series] = [] // check this array before loading a series
    
    // METHODS
    func loadViewed(completion: @escaping (String) -> ())
    {
        let url = State.shared.address + "requests/get_viewed.php"
        let query = "user_id=\(State.shared.user_id)"
        let rNet = RawNet()
        rNet.getSearchResults(urlPath: url, query: query, jsonParser: jsonView, completion: completion)
    }
    
    func loadMovies(completion: @escaping (String) -> ())
    {
        let url = State.shared.address + "requests/get_movies.php"
        let query = "type=movies&lan=\(State.shared.language)"
        let rNet = RawNet()
        rNet.getSearchResults(urlPath: url, query: query, jsonParser: jsonMovies, completion: completion)
    }
    
    func loadSeries(completion: @escaping (String) -> ()) // uses seriesOpened
    {
        let url = State.shared.address + "requests/get_movies.php"
        let query = "type=series&lan=\(State.shared.language)"
        let rNet = RawNet()
        rNet.getSearchResults(urlPath: url, query: query, jsonParser: jsonSeries, completion: completion)
    }
    
    // PARSER
    func jsonView(_ response: JSONDictionary?)
    {
        guard let array = response!["viewed"] as? [Any] else
        {
            print("Dictionary does not contain 'viewed' key\n")
            return
        }

        for viewed in array
        {
            if let dict = viewed as? [String: Any],
                let type = dict["type"] as? String
            {
                var item: Viewed?
                
                if type == "Movie" {
                    item = Movie(json: dict)
                }
                else if type == "Series" {
                    item = Episode(json: dict)
                }

                self.viewed.append(item!)
           
            }
            else
            {
                print("Problem parsing dictionary\n")
            }
        }
    }
    
    
    //
    // JSON MOVIES
    //
    func jsonMovies(_ response: JSONDictionary?)
    {
        guard let array = response!["movies"] as? [Any] else
        {
            print("Dictionary does not contain 'movies' key\n")
            return
        }
        
        for returnedDictionary in array
        {
            guard let dict = returnedDictionary as? JSONDictionary,
                let item = Movie(json: dict)
                else
            {
                print("Problem parsing movies dictionary\n")
                break
            }
            
            movies.append(item)
        }
    }
    
    //
    // JSON SERIES
    //
    func jsonSeries(_ response: JSONDictionary?)
    {
        guard let array = response!["series"] as? [Any] else
        {
            print("Dictionary does not contain 'series' key\n")
            return
        }
     
        for returnedDictionary in array
        {
            guard let dict = returnedDictionary as? JSONDictionary,
                  let item = Series(json: dict)
            else
            {
                print("Problem parsing series dictionary\n")
                break
            }
            
            series.append(item)
        }
    }

    
}








public class RawNet
{
    var errorMessage = ""
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    
    func getSearchResults(urlPath: String, query: String, jsonParser: @escaping (JSONDictionary?) -> (), completion: @escaping (String) -> () ) {
        // 1
        dataTask?.cancel()
        // 2
        if var urlComponents = URLComponents(string: urlPath) {
            urlComponents.query = query
            // 3
            guard let url = urlComponents.url else { return }
            // 4
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { self.dataTask = nil }
                // 5
                if let error = error
                {
                    self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                }
                else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200
                {
                    self.parser(jsonParser, data) // FETCH DATA
                    // 6
                    DispatchQueue.main.async {
                        completion(self.errorMessage)
                    }
                }
            }
            // 7
            dataTask?.resume()
        }
    }
    
    
    
    fileprivate func parser(_ jsonParser: (JSONDictionary?) -> (),_ data: Data)
    {
        var response: JSONDictionary?
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        // PARSE JSON
        jsonParser(response)
    }
    
}
