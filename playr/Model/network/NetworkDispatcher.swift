//
//  http.swift
//  playr
//
//  Created by Michel Balamou on 2018-08-28.
//  Copyright © 2018 Michel Balamou. All rights reserved.
//

import PromiseKit

public enum NetworkErrors: Error
{
    case badInput
    case noData
}

public class NetworkDispatcher: Dispatcher
{
    // Attributes 
    private var environment: Environment
    private var session: URLSession
    
    
    //--------------------------------------------------------------
    // Methods
    //--------------------------------------------------------------
    required public init(environment: Environment)
    {
        self.environment = environment
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    public func execute(request: Request) throws -> Promise<Response>
    {
        let rq = try self.prepareURLRequest(for: request)
        
        return Promise<Response>(in: .background,
        { resolve, _ in
            
            let d = self.session.dataTask(with: rq, completionHandler:
                { (data, urlResponse, error) in
                    
                    let response = Response( (urlResponse as? HTTPURLResponse, data, error), for: request)
                    resolve(response)
                })
            d.resume()
        })
    }
    
    private func prepareURLRequest(for request: Request) throws -> URLRequest
    {
        // Compose the url
        let full_url = "\(environment.host)/\(request.path)"
        var url_request = URLRequest(url: URL(string: full_url)!)
        
        // Working with parameters
        switch request.parameters {
        case .body(let params):
            // Parameters are part of the body
            if let params = params as? [String: String] { // just to simplify
                url_request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init(rawValue: 0))
            } else {
                throw NetworkErrors.badInput
            }
        case .url(let params):
            // Parameters are part of the url
            if let params = params as? [String: String] { // just to simplify
                let query_params = params.map({ (element) -> URLQueryItem in
                    return URLQueryItem(name: element.key, value: element.value)
                })
                guard var components = URLComponents(string: full_url) else {
                    throw NetworkErrors.badInput
                }
                components.queryItems = query_params
                url_request.url = components.url
            } else {
                throw NetworkErrors.badInput
            }
        }
        
        // Add headers from enviornment and request
        environment.headers.forEach { url_request.addValue($0.value as! String, forHTTPHeaderField: $0.key) }
        request.headers?.forEach { url_request.addValue($0.value as! String, forHTTPHeaderField: $0.key) }
        
        // Setup HTTP method
        url_request.httpMethod = request.method.rawValue
        
        return url_request
    }
}
