//
//  URLComponents.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 09.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

extension URLComponents {
    
    init?(request: Request, authKey: String) {
        let domain = "https://api.500px.com/"
        self.init(string: domain)
        self.path = "/v1" + request.method
        var queryItems = [URLQueryItem(name: "consumer_key", value: authKey)]
        for (key, value) in request.params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        self.queryItems = queryItems
    }
    
}
