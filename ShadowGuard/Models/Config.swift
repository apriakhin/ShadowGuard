//
//  Config.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 01.09.2023.
//

import Foundation

struct Config: Codable {
    let host: String
    let port: Int
    let method: Method
    let password: String
    let tag: String
    let extra: [String: String]
}
