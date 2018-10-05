//
//  LoadViewed.swift
//  playr
//
//  Created by Michel Balamou on 2018-09-03.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation


class LoadViewed<User>: Operation {
    
    var userID: String
    var request: Request {
        return UserRequests.login(username: self.username, password: self.password)
    }
    
    
    init(userID: String) {
        self.userID = user
    }
    
    
    func execute(in dispatcher: Dispatcher) -> Promise<User> {
        return Promise<User>({ resolve, reject in
            do {
                try dispatcher.execute(request: self.request).then({ response in
                    let user = User(response as! JSON)
                    resolve(user)
                }).catch(reject)
            } catch {
                reject(error)
            }
        })
    }
}
