//
//  Error.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 10.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

enum PXError: Error {
    case invalidRequest
    case unexpectedResponse
    case emptyResponse
    case serverError(errorCode: Int)
}
