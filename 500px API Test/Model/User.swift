//
//  User.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 10.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

struct User {
    var id: Int
    var username: String
    var firstName: String?
    var lastName: String?
    var fullName: String
    
    init?(data: [String: Any]) {
        guard let id = data["id"] as? Int,
            let username = data["username"] as? String,
            let fullName = data["fullname"] as? String else {
                return nil
        }
        self.id = id
        self.username = username
        self.firstName = data["firstname"] as? String
        self.lastName = data["lastname"] as? String
        self.fullName = fullName
    }
}
