//
//  DoMate_macOSApp.swift
//  DoMate_macOS
//
//  Created by SepineTam on 2025/3/7.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct DoMate_macOSApp: App {
    var body: some Scene {
        DocumentGroup(editing: .itemDocument, migrationPlan: DoMate_macOSMigrationPlan.self) {
            ContentView()
        }
    }
}

extension UTType {
    static var itemDocument: UTType {
        UTType(importedAs: "com.example.item-document")
    }
}

struct DoMate_macOSMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        DoMate_macOSVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct DoMate_macOSVersionedSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}
