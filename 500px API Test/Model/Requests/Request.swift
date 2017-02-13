//
//  Request.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 09.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

protocol Request {
    var method: String { get }
    var params: [String: String] { get }
    var onSuccess: ((_ data: [String: Any]) -> ())? { get set }
    var onError: ((_ error: Error) -> ())? { get set }
}
