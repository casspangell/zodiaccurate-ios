//
//  Horoscope.swift
//  Zodiaccurate
//
//  Created by Cass Pangell on 8/8/25.
//

import Foundation
import SwiftData

// MARK: - Horoscope Model
@Model
public class Horoscope {
    public var title: String
    public var message: String
    public var key: String
    public let createdAt: Date
    
    public init(title: String, message: String, key: String, createdAt: Date = Date()) {
        self.title = title
        self.message = message
        self.key = key
        self.createdAt = createdAt
    }
}

