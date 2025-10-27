//
//  VeteransApp.swift
//  Veterans
//
//  Created by Dagger4 on 10/24/25.
//

import SwiftUI
import SwiftData

@main
struct VeteransApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            // Try with explicit schema configuration
            let schema = Schema([
                Veteran.self,
                Claim.self,
                Document.self,
                ClaimActivity.self,
                MedicalCondition.self,
                MedicalConditionCategory.self,
                ConditionRelationship.self,
                EmailLog.self,
                ChatSession.self,
                ChatMessage.self,
                ChatDocument.self,
                PromptTemplate.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            print("SwiftData Error: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            // Clear existing database and start fresh
            do {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let storeURL = documentsPath.appendingPathComponent("default.store")
                
                // Remove existing store if it exists
                if FileManager.default.fileExists(atPath: storeURL.path) {
                    try FileManager.default.removeItem(at: storeURL)
                    print("Removed existing database to resolve migration issues")
                }
                
                // Create fresh database
                let schema = Schema([
                    Veteran.self,
                    Claim.self,
                    Document.self,
                    ClaimActivity.self,
                    MedicalCondition.self,
                    MedicalConditionCategory.self,
                    ConditionRelationship.self,
                    EmailLog.self,
                    ChatSession.self,
                    ChatMessage.self,
                    ChatDocument.self,
                    PromptTemplate.self
                ])
                
                let modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false
                )
                
                return try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            } catch {
                print("Failed to create fresh database, falling back to in-memory storage")
                
                // Final fallback to in-memory storage
                do {
                    return try ModelContainer(
                        for: Veteran.self, Claim.self, Document.self, ClaimActivity.self, MedicalCondition.self, MedicalConditionCategory.self, ConditionRelationship.self, EmailLog.self, ChatSession.self, ChatMessage.self, ChatDocument.self, PromptTemplate.self,
                        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                    )
                } catch {
                    fatalError("Could not create ModelContainer: \(error)")
                }
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
