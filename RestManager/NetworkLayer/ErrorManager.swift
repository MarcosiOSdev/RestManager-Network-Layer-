//
//  ErrorManager.swift
//  RestManager
//
//  Created by Marcos Felipe Souza on 25/04/19.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation

enum CustomError: Error {
    case failedToCreateRequest
}
extension CustomError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .failedToCreateRequest: return NSLocalizedString("Unable to create the URLRequest object", comment: "")
        }
    }
}
