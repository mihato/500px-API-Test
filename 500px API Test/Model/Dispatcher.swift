//
//  Dispatcher.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 09.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

struct Dispatcher {
    
    static private(set) var `default` = Dispatcher(authKey: "")
    
    static func configureDefaultDispatcher(authKey: String) {
        assert(authKey != "")
        Dispatcher.default = Dispatcher(authKey: authKey)
    }
    
    fileprivate var authKey: String
    
    fileprivate var queue = OperationQueue()
    
    init(authKey: String) {
        self.authKey = authKey
    }
    
    func perform(request: Request) {
        guard let url = URLComponents(request: request, authKey: self.authKey)?.url else {
            request.onError?(PXError.invalidRequest)
            return
        }
        self.queue.addOperation(DispatchOperation(url: url, callback: { (data, error) in
            if let data = data {
                do {
                    let object = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                    if let object = object as? [String: Any] {
                        request.onSuccess?(object)
                    }
                } catch _ {
                    request.onError?(PXError.unexpectedResponse)
                }
            }
        }))
    }
}
