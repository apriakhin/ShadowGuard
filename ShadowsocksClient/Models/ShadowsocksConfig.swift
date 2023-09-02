//
//  ShadowsocksConfig.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 01.09.2023.
//

import Foundation

struct ShadowsocksConfig {
    let host: String
    let port: Int
    let method: ShadowsocksMethod
    let password: String
    let tag: String?
    let extra: [String: String]
}
