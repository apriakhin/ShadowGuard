//
//  DatabaseService.swift
//  ShadowGuard
//
//  Created by Anton Priakhin on 07.09.2023.
//

import Foundation
import SwiftData

protocol DatabaseServicing {
    var modelContainer: ModelContainer { get }
    var modelContext: ModelContext { get }
    var defaultServer: Server? { get }
    var isNotExistServers: Bool { get }
}

final class DatabaseService: DatabaseServicing {
    var modelContainer: ModelContainer = {
        let schema = Schema([Server.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private(set) lazy var modelContext = ModelContext(modelContainer)
    
    var defaultServer: Server? {
        let descriptor = FetchDescriptor<Server>(predicate: #Predicate<Server> { $0.isDefault })
        
        return try? modelContext.fetch(descriptor).first
    }
    
    var isNotExistServers: Bool {
        let countServers = (try? modelContext.fetchCount(FetchDescriptor<Server>())) ?? 0
        
        return countServers < 1
    }
}
