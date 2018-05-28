//
//  network.swift
//  playr
//
//  Created by Michel Balamou on 5/23/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//
//----------------------------------------------------------------------------
//
//                           NETWRORK MODEL
//                       ~~~~~~~~~~~~~~~~~~~~~~~
//
//----------------------------------------------------------------------------

import Foundation


class NetworkModel
{
    var viewed: [Viewed] = []       // ??
    var movies: [Movie] = []         // 10 at a time
    var series: [Series] = []       // 10 at a time
    var seriesOpened: [Series] = [] // check this array before loading a series
    
    
    var play: (Viewed) -> () = {_ in}
    var displayInfo: (Any) -> () = {_ in}
    
    // ------------------------------------------------------------------------------
    // MARK: METHODS
    // ------------------------------------------------------------------------------
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
    
    // ------------------------------------------------------------------------------
    // MARK: PARSERS
    // ------------------------------------------------------------------------------
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
    
    // ------------------------------------------------------------------------------
    // LOAD SERIES
    // ------------------------------------------------------------------------------
    
    func loadFullSeries(series_id: Int, completion: @escaping (Series) -> () )
    {
        for item in seriesOpened {
            if item.series_id == series_id
            {
                completion(item)
            }
        }
        
        
        // LOAD
        let url = State.shared.address + "requests/get_series.php"
        let query = "user_id=\(State.shared.user_id)&series_id=\(series_id)"
        let rNet = RawNet()
        rNet.quickQuery(url, query, jsonFullSeries) {
            data in

            if let series = data as? Series {
                completion(series)
            }
        }
    }
    
    func jsonFullSeries(_ response: JSONDictionary?) -> Series?
    {
        guard let seriesDict = response!["series"] as? [String: Any],
              let s = Series(json: seriesDict)
        else
        {
            print("Dictionary does not contain 'series' key\n")
            return nil
        }

        // EPISODES
        guard let episodes = response!["episodes"] as? [Any] else
        {
            print("Dictionary does not contain 'episodes' key\n")
            return s
        }
        
        var i = 0
        for episodeDict in episodes
        {
            if let dict = episodeDict as? JSONDictionary,
                let item = Episode(json: dict)
            {
                item.mainSeries = s // Point back
                
                if s.episodes[item.season] != nil {
                    s.episodes[item.season]?.append(item)
                }
                else {
                    s.episodes[item.season] = [item]
                }
                
                
            }
            else {
                print(" \(i). Problem parsing episodes dictionary\n")
                i+=1
            }

        }
        
        return s
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
    
    

    func quickQuery(_ urlPath: String, _ query: String, _ jsonParser: @escaping ([String: Any]) -> (Any), _ completion: @escaping (Any?) -> Void)
    {
        guard var searchURLComponents = URLComponents(string: urlPath) else
        {
            print("Error")
            return
        }
        searchURLComponents.query = query
        let searchURL = searchURLComponents.url!
        
        URLSession.shared.dataTask(with: searchURL, completionHandler: { data, _ ,_ in
            var tmp: Any?
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            {
                tmp = jsonParser(json!)
            }
            
           
            DispatchQueue.main.async {
                 completion(tmp)
            }
        }).resume()
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
