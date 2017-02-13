//
//  ImageLoader.swift
//
//  Created by Michail Grebionkin on 25.01.16.
//  Copyright © 2016 Capitan. All rights reserved.
//

import UIKit
import AVFoundation

class ImageLoader: NSObject {
    
    static private let loadingQueue = OperationQueue()
    static private let cache = FileCache()
    
    override init() {
        super.init()
        type(of: self).loadingQueue.maxConcurrentOperationCount = 2
    }
    
    private func cacheFilename(forPhoto photo: PhotoImage) -> String {
        return "\(photo.secureUrl.lastPathComponent)_\(photo.size.rawValue)"
    }
    
    func pictureFromCache(photo: PhotoImage) -> UIImage? {
        if let data = type(of: self).cache.getData(filename: self.cacheFilename(forPhoto: photo)) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func cancelLoading(urls: [URL]) {
        type(of: self).loadingQueue.operations.forEach { (operation) in
            if let operation = operation as? ImageLoadOperation, urls.contains(operation.url) {
                operation.cancel()
            }
        }
    }
    
    func load(photo: PhotoImage, completionHandler: @escaping (_ photo: PhotoImage, _ image: UIImage?, _ error: Error?) -> Void) {
        if let image = self.pictureFromCache(photo: photo) {
            OperationQueue.current?.addOperation({ () -> Void in
                completionHandler(photo, image, nil)
            })
            return
        }
        let currentQueue = OperationQueue.current
        let operation = ImageLoadOperation(url: photo.secureUrl) { (data, error) -> Void in
            var image : UIImage?
            if let data = data {
                type(of: self).cache.writeData(data: data, filename: self.cacheFilename(forPhoto: photo))
                image = UIImage(data: data)
            }
            currentQueue?.addOperation({ () -> Void in
                completionHandler(photo, image, error)
            })
        }
        type(of: self).loadingQueue.addOperation(operation)
    }
    
    // MARK: Loading operation
    
    private class ImageLoadOperation : BlockOperation {
        
        var url: URL
        
        var sessionTask: URLSessionTask?
        
        init(url: URL, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> Void ) {
            self.url = url
            super.init()
            addExecutionBlock { () -> Void in
                    let request = URLRequest(url: self.url)
                    let sessionConfiguration = URLSessionConfiguration.default
                    sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
                    let session = URLSession(configuration: sessionConfiguration)
                    self.sessionTask = session.dataTask(with: request, completionHandler: { (data, URLResponse, error) -> Void in
                        if error != nil {
                            completionHandler(nil, error)
                        } else if URLResponse == nil {
                            completionHandler(nil, PXError.unexpectedResponse)
                        } else if let HTTPURLResponse = URLResponse as? HTTPURLResponse, HTTPURLResponse.statusCode != 200 {
                            completionHandler(nil, PXError.unexpectedResponse)
                        } else {
                            completionHandler(data, nil)
                        }
                    })
                    self.sessionTask?.resume()
            }
        }
        
        override func cancel() {
            self.sessionTask?.cancel()
            super.cancel()
        }
    }
    
    // MARK: File cache
    
    fileprivate class FileCache {
        
        let cache = NSCache<NSString, NSData>()
        static let CachedFileTTL : TimeInterval = 86400 * 3 // 3 days
        
        init() {
            NotificationCenter.default.addObserver(self, selector: #selector(memoryWarningHandler(notification:)), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: .UIApplicationDidReceiveMemoryWarning, object: nil)
        }
        
        @objc fileprivate func memoryWarningHandler(notification: Notification) {
            self.cache.removeAllObjects()
        }
        
        fileprivate func cacheDirectoryURL() -> URL? {
            let fileManager = FileManager.default
            let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            if let url = paths.first {
                let cacheDirectoryURL = url.appendingPathComponent("500px", isDirectory: true)
                var isDirectory : ObjCBool = false
                if fileManager.fileExists(atPath: cacheDirectoryURL.absoluteString, isDirectory: &isDirectory) {
                    if !isDirectory.boolValue {
                        return nil
                    }
                } else {
                    do {
                        try fileManager.createDirectory(at: cacheDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                    } catch _ {
                        return nil
                    }
                }
                return cacheDirectoryURL
            }
            return nil
        }
        
        func clearCache() {
            if let cacheDirectoryURL = self.cacheDirectoryURL() {
                if let enumerator = FileManager.default.enumerator(at: cacheDirectoryURL, includingPropertiesForKeys: [.creationDateKey], options: [], errorHandler: nil) {
                    let edge = Date(timeInterval: FileCache.CachedFileTTL, since: Date())
                    for url in (enumerator.allObjects as! [URL]) {
                        do {
                            let resourceValues = try url.resourceValues(forKeys: [.creationDateKey])
                            if let creationDate = resourceValues.creationDate, creationDate.compare(edge) == .orderedAscending {
                                try FileManager.default.removeItem(at: url)
                            }
                        } catch _ {
                            // do nothing
                        }
                    }
                }
            }
        }
        
        func writeData(data: Data, filename: String) {
            if let URL = self.cacheDirectoryURL()?.appendingPathComponent(filename) {
                do {
                    try data.write(to: URL, options: [.noFileProtection])
                } catch _ {
                    // do nothing
                }
            }
            cache.setObject((data as NSData), forKey: (filename as NSString))
        }
        
        func getData(filename: String) -> Data? {
            if let data = cache.object(forKey: (filename as NSString)) as? Data {
                return data
            }
            if let URL = self.cacheDirectoryURL()?.appendingPathComponent(filename) {
                do {
                    let data = try Data(contentsOf: URL)
                    cache.setObject((data as NSData), forKey: (filename as NSString))
                    return data
                } catch _ {
                    return nil
                }
            }
            return nil
        }
    }
}
