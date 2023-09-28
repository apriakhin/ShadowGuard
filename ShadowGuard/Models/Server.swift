//
//  Server.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 24.08.2023.
//

import Foundation
import SwiftData

@Model
final class Server {
    var id: UUID
    var title: String
    var config: Config
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        config: Config,
        isDefault: Bool
    ) {
        self.id = id
        self.title = title
        self.config = config
        self.isDefault = isDefault
    }
}
