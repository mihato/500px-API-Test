//
//  GetPhotoRequest.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 13.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

struct GetPhotoRequest: Request {
    
    public var method: String {
        return "/photos/\(String(self.id))"
    }
    
    var params: [String: String] {
        return ["image_size": String(self.size.rawValue)]
    }
    
    var onSuccess: ((_ data: [String: Any]) -> ())?
    
    var onError: ((_ error: Error) -> ())?
    
    var id: Int
    
    var size: PhotoImageSize = .full900
    
    init(id: Int, size: PhotoImageSize = .full900) {
        self.id = id
        self.size = size
    }
    
}
