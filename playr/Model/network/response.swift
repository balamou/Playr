//
//  response.swift
//  playr
//
//  Created by Michel Balamou on 2018-08-28.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum Response
{
    case json(_: JSON)
    case data(_: Data)
    case error(_: Int?, _: Error?)
    
    /// Init response
    /// * note: could've made response into 3 different arguments
    ///
    /// - Parameter response: a tuple w/ URL data, Data, and Errors
    /// - Parameter request: original request that was sent
    init(_ response: (r: HTTPURLResponse?, data: Data?, error: Error?), for request: Request)
    {
        // Check if the response was received
        guard response.r?.statusCode == 200, response.error == nil else {
            self = .error(response.r?.statusCode, response.error) // return error
            return
        }
        
        // Check if the data is nill
        guard let data = response.data else {
            self = .error(response.r?.statusCode, NetworkErrors.noData) // return error
            return
        }
        
        // Return correspoding data type
        switch request.dataType
        {
            case .Data:
                self = .data(data)
            case .JSON:
                self = .json(try! JSON(data: data))
        }
    }
}
