//
//  Item.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 23.08.2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
