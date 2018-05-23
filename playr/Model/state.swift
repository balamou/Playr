//
//  state.swift
//  playr
//
//  Created by Michel Balamou on 5/15/18.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation

// SINGLETON
class State{
    
    static let shared = State()
    
    var address = "http://192.168.15.108/"
    var language = "EN"
    var user_id = 1
    var user_hash = "1"
    
    private init()
    {
        loadPreferences()
        
        // get hash from preferences
        // load user id based on hash
    }
    
    // Load settings user has saved
    // & load user_id and hash
    func loadPreferences()
    {
        
    }
}
