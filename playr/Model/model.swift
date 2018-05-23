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
//        guard let array = response!["episodes"] as? [Any] else
//        {
//            errorMessage += "Dictionary does not contain results key\n"
//            return
//        }
//
//        var index = 0
//        for returnedDictionary in array
//        {
//            if let dict = returnedDictionary as? JSONDictionary,
//                let id_ = dict["ID"] as? String,
//                let Title = dict["Title"] as? String,
//                let EpisodeNum = dict["Episode"] as? String,
//                let Desc = dict["Description"] as? String,
//                let url = dict["URL"] as? String,
//                let Thumbnail = dict["Thumbnail"] as? String,
//                let Duration = dict["Duration"] as? String,
//                let StoppedAt = dict["StoppedAt"] as? String
//            {
//                let item = Episode(Int(id_) ?? 0, episodeNum: Int(EpisodeNum) ?? 0, withTitle: Title, atURL: State.address + url, Int(Duration) ?? 1)
//                item.stoppedAt = Int(StoppedAt)
//                item.thumbnail = State.address + Thumbnail
//                item.description = Desc
//
//                self.results.append(item)
//                index += 1
//            }
//            else
//            {
//                errorMessage += "Problem parsing dictionary\n"
//            }
//        }
    }
    
    func load(completion: @escaping QueryResult)
    {
       // self.urlPath = State.address + "requests/get_episodes.php"
       // self.query = "user_id=\(State.user_id)&series_id=\(self.id)&season=\(self.season)"
        
        self.getSearchResults(completion: completion)
    }
}


//----------------------------------------------------------------------------
//
//                           NETWRORK PARSING
//                       ~~~~~~~~~~~~~~~~~~~~~~~
//
//----------------------------------------------------------------------------



