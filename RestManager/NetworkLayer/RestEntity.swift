//
//  RestEntity.swift
//  RestManager
//
//  Created by Marcos Felipe Souza on 25/04/19.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation

struct RestEntity {
    private var values: [String: String] = [:]
    
    mutating func add(value: String, forKey key: String) {
        values[key] = value
    }
    
    func value(forKey key: String) -> String? {
        return values[key]
    }
    
    func allValues() -> [String: String] {
        return values
    }
    
    func totalItems() -> Int {
        return values.count
    }
}
