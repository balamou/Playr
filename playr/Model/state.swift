//
//  state.swift
//  playr
//
//  Created by Michel Balamou on 5/15/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation

class State{
    static var address = "http://192.168.15.108/"
    static var language = "EN"
    static var user_id = 1
    static var user_hash = "1"
    
    var viewedList: [Viewed]? = nil
    var movieList: [Movie]? = nil
     
    
    init()
    {
        
    }
    
    // Load settings user has saved
    // & load user_id and hash
    func loadPreferences()
    {
        
    }
}
