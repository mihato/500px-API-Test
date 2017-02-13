//
//  PhotoImage.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 10.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

enum PhotoImageSize: Int {
    case crop70 = 1
    case crop140 = 2
    case crop280 = 3
    case crop100 = 100
    case crop200 = 200
    case crop440 = 440
    case crop600 = 600
    case full900 = 4
    case full1170 = 5
    case full256 = 30
    case full1080 = 1080
    case full1600 = 1600
    case full2048 = 2048
    case high1080 = 6
    case high300 = 20
    case high600 = 21
    case high450 = 31
}

struct PhotoImage {
    var size: PhotoImageSize
    var url: URL
    var secureUrl: URL
    var format: String
    
    init?(data: [String: Any]) {
        guard let sizeNumber = data["size"] as? Int,
            let size = PhotoImageSize(rawValue: sizeNumber),
            let urlString = data["url"] as? String,
            let url = URL(string: urlString),
            let secureUrlString = data["https_url"] as? String,
            let secureUrl = URL(string: secureUrlString),
            let format = data["format"] as? String else {
                return nil
        }
        self.size = size
        self.url = url
        self.secureUrl = secureUrl
        self.format = format
    }
    
}
