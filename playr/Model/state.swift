//
//  state.swift
//  playr
//
//  Created by Michel Balamou on 5/15/18.
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

// SINGLETON
class State: CustomStringConvertible
{
    var description: String {
        var t = "----------\n"
        t+="State:\n"
        t+="Lan: \(language)\n"
        t+="User id: \(user_id)\n"
        t+="Hash: \(hash)\n"
        t+="Name: \(name ?? "")\n"
        t+="----------"
        return t
    }
 
    var load: () -> () = {}
    
    
    static let shared = State()
    
    //var address = "http://192.168.15.108/"
    var address = "http://192.168.0.121/"
    var language = "EN"
    var user_id = 1
    
    var hash = "1"
    var name: String?
    var started = false
    
    private init()
    {
        loadPreferences()
        print(self)
    }
    
    // Load settings user has saved
    // & load user_id and hash
    func loadPreferences()
    {
        let defaults = UserDefaults.standard
        if let language = defaults.string(forKey: "Language")
        {
           self.language = language
        }
        
        self.user_id = defaults.integer(forKey: "UserID")
        self.name = defaults.string(forKey: "Name")
        
        if let hash = defaults.string(forKey: "Hash")
        {
            self.hash = hash
        }
    }
    
    // resets all saved parameters
    func cleanUp()
    {
         let defaults = UserDefaults.standard
         defaults.removeObject(forKey: "islogged")
         defaults.removeObject(forKey: "UserID")
         defaults.removeObject(forKey: "Language")
         defaults.removeObject(forKey: "Name")
         defaults.removeObject(forKey: "Hash")
    }
    
    func save()
    {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "islogged")
        defaults.set(user_id, forKey: "UserID")
        defaults.set(language, forKey: "Language")
        defaults.set(name ?? "", forKey: "Name")
        defaults.set(hash, forKey: "Hash")
    }
    
    func isLogged() -> Bool
    {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "islogged")
    }
    
    
    func randomString(length: Int) -> String
    {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func register(_ completion: @escaping () -> () )
    {
        guard started == false else {
            print("Already started")
            return
        }
        
        hash = randomString(length: 20) // generate hash
        
        let url = address + "requests/add_user.php"
        let query = "name=\(name ?? "")&hash=\(hash)"
        let rNet = RawNet()
        
        // Send request to register user
        rNet.getInt(urlPath: url, query: query) {
            id in
            
            self.user_id = id // save returned ID from the database
            self.save()
            
            print(State.shared)
            completion()
        }
    }
}



