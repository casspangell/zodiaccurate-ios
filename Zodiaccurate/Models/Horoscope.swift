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
    public var audioFilePath: String?
    public let createdAt: Date
    
    public init(title: String, message: String, key: String, audioFilePath: String? = nil, createdAt: Date = Date()) {
        self.title = title
        self.message = message
        self.key = key
        self.audioFilePath = audioFilePath
        self.createdAt = createdAt
    }
}

