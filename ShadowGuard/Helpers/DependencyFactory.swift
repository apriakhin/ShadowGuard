//
//  DependencyFactory.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 25.09.2023.
//

import Foundation

protocol DependencyFactoring {
    var databaseService: DatabaseServicing { get }
    var tunnelService: TunnelServicing { get }
    var statusMapper: StatusMapping { get }
    var uriParser: URIParsing { get }
}

final class DependencyFactory: DependencyFactoring {
    let databaseService: DatabaseServicing = DatabaseService()
    let tunnelService: TunnelServicing = TunnelService()
    let statusMapper: StatusMapping = StatusMapper()
    let uriParser: URIParsing = URIParser()
}
