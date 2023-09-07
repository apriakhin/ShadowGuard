//
//  DatabaseService.swift
//  ShadowsocksClient
//
//  Created by Anton Priakhin on 07.09.2023.
//

import Foundation
import SwiftData

class DatabaseService {
    static var shared = DatabaseService()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Config.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private lazy var context = ModelContext(sharedModelContainer)
    
    func getDefautConfig() throws -> Config? {
        let descriptor = FetchDescriptor<Config>(predicate: #Predicate<Config> { $0.isDefault })
        
        return try context.fetch(descriptor).first
    }
}
