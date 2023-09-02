//
//  Server.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 24.08.2023.
//

import Foundation
import SwiftData

@Model
final class Config {
    var id: UUID
    var title: String
    var host: String
    var port: Int
    var method: String
    var password: String
    var tag: String?
    var extra: [String: String]
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        host: String,
        port: Int,
        method: String,
        password: String,
        tag: String?,
        extra: [String: String],
        isDefault: Bool
    ) {
        self.id = id
        self.title = title
        self.host = host
        self.port = port
        self.method = method
        self.password = password
        self.tag = tag
        self.extra = extra
        self.isDefault = isDefault
    }
}
