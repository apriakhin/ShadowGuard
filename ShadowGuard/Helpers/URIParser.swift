//
//  URIParser.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 01.09.2023.
//

import Foundation

protocol URIParsing {
    func parse(uri: String) -> Config?
    func parseLegacyBase64URI(uri: String) -> Config?
    func parseSIP002URI(uri: String) -> Config?
}

struct URIParser: URIParsing {
    func parse(uri: String) -> Config? {
        return parseSIP002URI(uri: uri) ?? parseLegacyBase64URI(uri: uri)
    }
    
    func parseLegacyBase64URI(uri: String) -> Config? {
        let uriPattern = /ss:\/\/(?<configEncoded>.+?)($|#(?<tag>.+?))/
        let configPattern = /(?<method>.+?):(?<password>.+?)@(?<host>.+?):(?<port>\d+)/
    
        guard let uriParams = try? uriPattern.wholeMatch(in: uri),
              let config = String(uriParams.configEncoded).base64Decoded(),
              let configParams = try? configPattern.wholeMatch(in: config),
              let method = Method(rawValue: String(configParams.method)),
              let port = Int(configParams.port)
        else {
            return nil
        }
        
        let host = String(configParams.host)
        let password = String(configParams.password)
        let tag = uriParams.tag != nil ? String(uriParams.tag?.removingPercentEncoding ?? "") : ""
        
        return Config(
            host: host,
            port: port,
            method: method,
            password: password,
            tag: tag,
            extra: [:]
        )
    }
    
    func parseSIP002URI(uri: String) -> Config? {
        let urlString = uri.replacingOccurrences(of: "ss://", with: "http://")
        let userInfoPattern = /(?<method>.+?):(?<password>.+?)/
        
        guard let url = URL(string: urlString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host,
              let port = components.port,
              let userInfoEncoded = components.user,
              let userInfo = userInfoEncoded.base64Decoded(),
              let userInfoParams = try? userInfoPattern.wholeMatch(in: userInfo),
              let method = Method(rawValue: String(userInfoParams.method))
        else {
            return nil
        }
        
        let password = String(userInfoParams.password)
        let tag = components.fragment ?? ""
        let extra = Dictionary(uniqueKeysWithValues: components.queryItems?.compactMap {
            $0.value != nil ? ($0.name, $0.value ?? "") : nil
        } ?? [])

        return Config(
            host: host,
            port: port,
            method: method,
            password: password,
            tag: tag,
            extra: extra
        )
    }
}

fileprivate extension String {
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
