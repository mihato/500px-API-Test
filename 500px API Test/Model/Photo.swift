//
//  Photo.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 10.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

struct Photo {
    var id: Int
    var name: String
    var description: String?
    var images: [PhotoImage]
    var user: User
    
    init?(data: [String: Any]) {
        guard let id = data["id"] as? Int,
            let name = data["name"] as? String,
            let imagesData = data["images"] as? [[String: Any]],
            imagesData.count > 0,
            let userData = data["user"] as? [String: Any],
            let user = User(data: userData) else {
                return nil
        }
        self.id = id
        self.name = name
        self.description = data["description"] as? String
        self.user = user
        self.images = [PhotoImage]()
        for imageData in imagesData {
            if let image = PhotoImage(data: imageData) {
                self.images.append(image)
            }
        }
        if self.images.count == 0 {
            return nil
        }
    }
}
