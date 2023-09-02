//
//  ConfigMapper.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 02.09.2023.
//

import Foundation

protocol ConfigMapping {
    func map(config: Config) -> ShadowsocksConfig
    func map(title: String, shadowsocksConfig: ShadowsocksConfig, isDefault: Bool) -> Config
}

struct ConfigMapper: ConfigMapping {
    func map(config: Config) -> ShadowsocksConfig {
        return ShadowsocksConfig(
            host: config.host,
            port: config.port,
            method: ShadowsocksMethod(rawValue: config.method) ?? .rc4Md5,
            password: config.password,
            tag: config.tag,
            extra: config.extra
        )
    }
    
    func map(title: String, shadowsocksConfig: ShadowsocksConfig, isDefault: Bool) -> Config {
        return Config(
            title: title,
            host: shadowsocksConfig.host,
            port: shadowsocksConfig.port,
            method: shadowsocksConfig.method.rawValue,
            password: shadowsocksConfig.password,
            tag: shadowsocksConfig.tag,
            extra: shadowsocksConfig.extra,
            isDefault: isDefault
        )
    }
}
