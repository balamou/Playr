//
//  QueryService.swift
//  playr
//
//  Created by Michel Balamou on 5/10/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation

// Runs query data task, and stores results in array of Tracks
class QueryService {
    
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([String]?, String) -> () // returns a function with array results and an error
    
    // 1
    let defaultSession = URLSession(configuration: .default)
    // 2
    var dataTask: URLSessionDataTask?
    var tracks: [String] = []
    var errorMessage = ""
    
    func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
        // 1
        dataTask?.cancel()
        // 2
        if var urlComponents = URLComponents(string: "http://192.168.15.108/search.php") {
            urlComponents.query = "current_dir=\(searchTerm)"
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
                else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200
                {
                    self.updateSearchResults(data) // FETCH DATA
                    // 6
                    DispatchQueue.main.async {
                        completion(self.tracks, self.errorMessage)
                    }
                }
            }
            // 7
            dataTask?.resume()
        }
    }
    
    fileprivate func updateSearchResults(_ data: Data)
    {
        var response: JSONDictionary?
        tracks.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let array = response!["results"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        // PARSE JSON
        var index = 0
        for trackDictionary in array
        {
            if let path = trackDictionary as? String
            {
            tracks.append(path)
            index += 1
            }
//
//            if let trackDictionary = trackDictionary as? JSONDictionary, let path = trackDictionary["trackName"] as? String
//            {
//                tracks.append(path)
//                index += 1
//            }
//            else
//            {
//                errorMessage += "Problem parsing trackDictionary\n"
//            }
        }
    }
    
}
