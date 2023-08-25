//
//  Server.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 24.08.2023.
//

import Foundation
import SwiftData

@Model
final class Server {
    var id: UUID
    var title: String
    var accessKey: String
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        accessKey: String,
        isDefault: Bool
    ) {
        self.id = id
        self.title = title
        self.accessKey = accessKey
        self.isDefault = isDefault
    }
}
