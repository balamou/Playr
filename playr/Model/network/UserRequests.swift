//
//  UserRequests.swift
//  playr
//
//  Created by Michel Balamou on 2018-09-03.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation

public enum UserRequests: Request
{
    case viewed(userID: Int)
    case avatar(username: String)
    
    public var path: String {
        switch self {
        case .viewed(_):
            return "/users/login"
        case .avatar(_):
            return "/usets/avatar"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .viewed(_):
            return .get
        case .avatar(_):
            return .get
        }
    }
    
    public var parameters: RequestParams {
        switch self {
        case .viewed(let userID):
            return .url(["userID" : userID])
        case .avatar(let username):
            return .url(["username" : username])
        }
    }
    
    public var headers: [String : Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    public var dataType: DataType {
        switch self {
        case .viewed(_):
            return .JSON
        case .avatar(_):
            return .Data
        }
    }
}
