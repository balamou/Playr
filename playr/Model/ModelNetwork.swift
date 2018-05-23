//
//  ModelNetwork.swift
//  playr
//
//  Created by Michel Balamou on 5/17/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation


typealias JSONDictionary = [String: Any]
typealias QueryResult = ([Any]?, String) -> () // returns a function with array results and an error
typealias JsonParser = (Data) -> ()

// Runs query data task, and stores results in array of Tracks
public class ModelNetwork
{
    // DATA
    var urlPath: String? // user has to specify
    var query: String? // user has to specify
    var results: [Any] = []
    var errorMessage = ""
    
    // NETWORK
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
 

    init()
    {
        
    }
    
    func getSearchResults(completion: @escaping QueryResult) {
        // 1
        dataTask?.cancel()
        // 2
        if var urlComponents = URLComponents(string: urlPath!) {
            urlComponents.query = query!
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
                    self.parser(data) // FETCH DATA
                    // 6
                    DispatchQueue.main.async {
                        completion(self.results, self.errorMessage)
                    }
                }
            }
            // 7
            dataTask?.resume()
        }
    }
    
    
 
    fileprivate func parser(_ data: Data)
    {
        var response: JSONDictionary?
        results.removeAll()

        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }

        // PARSE JSON
        self.json(response)
    }
    
    
    func json(_ response: JSONDictionary?)
    {
//        guard let array = response!["viewed"] as? [Any] else
//        {
//            errorMessage += "Dictionary does not contain results key\n"
//            return
//        }
//
//        var index = 0
//        for returnedDictionary in array
//        {
//            if let dict = returnedDictionary as? JSONDictionary,
//                //let id = dict["ID"] as? String,
//                let Series_id = dict["Series_id"] as? String,
//                let Season = dict["Season"] as? String,
//                let Episode = dict["Episode"] as? String,
//                let Thumbnail = dict["Thumbnail"] as? String,
//                let Duration = dict["Duration"] as? String,
//                let StoppedAt = dict["StoppedAt"] as? String,
//                let URL = dict["URL"] as? String
//            {
//                //let item = Viewed(Int(Series_id) ?? 1, ofType: .series, URL, Int(Duration) ?? 0, Int(StoppedAt) ?? 0)
//                item.season = Int(Season)
//                item.episode = Int(Episode)
//                item.poster = Thumbnail
//                results.append(item)
//                index += 1
//            }
//            else
//            {
//                errorMessage += "Problem parsing dictionary\n"
//            }
//        }
    }
    
}
