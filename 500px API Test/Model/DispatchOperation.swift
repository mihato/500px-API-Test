//
//  DispatchOperation.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 09.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit

class DispatchOperation: Operation {

    override var isAsynchronous: Bool {
        return true
    }
    
    fileprivate var _executing: Bool = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    override var isExecuting: Bool {
        return self._executing
    }
    
    fileprivate var _finished: Bool = false {
        willSet {
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isFinished")
        }
    }
    override var isFinished: Bool {
        return self._finished
    }
    
    fileprivate var url: URL
    
    fileprivate var sessionTask: URLSessionTask?
    
    fileprivate var callback: (_ data: Data?, _ error: Error?) -> ()
    
    init(url: URL, callback: @escaping (_ data: Data?, _ error: Error?) -> ()) {
        self.url = url
        self.callback = callback
    }
    
    override func start() {
        self._executing = true
        let session = URLSession(configuration: .default)
        self.sessionTask = session.dataTask(with: self.url, completionHandler: { (data, urlResponse, error) in
            guard let data = data,
                data.count > 0 else {
                    self._executing = false
                    self._finished = true
                    self.callback(nil, PXError.emptyResponse)
                    return
            }
            guard let response = urlResponse as? HTTPURLResponse else {
                self.callback(data, PXError.unexpectedResponse)
                return 
            }
            self._executing = false
            self._finished = true
            if response.statusCode >= 300 {
                self.callback(data, PXError.serverError(errorCode: response.statusCode))
            } else {
                self.callback(data, nil)
            }
        })
        self.sessionTask?.resume()
    }
    
    override func cancel() {
        guard let task = self.sessionTask else {
            super.cancel()
            return
        }
        task.cancel()
        super.cancel()
    }
}
