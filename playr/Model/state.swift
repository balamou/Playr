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



// SOURCE: https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
extension UIImageView {
    
    func loadCache(link: String, contentMode mode: UIViewContentMode)
    {
        let url = URL(string: link)!
        self.contentMode = mode
        self.kf.setImage(with: url)
    }
    
    
    func getImgFromUrl(link: String, contentMode mode: UIViewContentMode) {
        let url = URL(string: link)
        self.contentMode = mode
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            
            DispatchQueue.main.async {
                if let d = data {
                    self.image = UIImage(data: d)
                }
            }
        }
    }
}

extension CGRect {
    
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        
        self.init(x:x, y:y, width:w, height:h)
    }
}
