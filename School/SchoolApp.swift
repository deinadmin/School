//
//  SchoolApp.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct SchoolApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          // Debug: Perform one-time migration from UserDefaults to SwiftData
          performMigrationIfNeeded()
        }
    }
    .modelContainer(createModelContainer())
  }
  
  /// Create ModelContainer with CloudKit configuration for iCloud sync
  /// Debug: Enables iCloud sync for all SwiftData models
  private func createModelContainer() -> ModelContainer {
    let schema = Schema([
      Subject.self,
      Grade.self,
      GradeType.self,
      FinalGrade.self,
      SchoolYearGradingSystem.self
    ])
    
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false,
      cloudKitDatabase: .automatic // Debug: Enable CloudKit sync
    )
    
    do {
      let container = try ModelContainer(
        for: schema,
        configurations: [modelConfiguration]
      )
      
      print("Debug: ModelContainer created successfully with CloudKit sync enabled")
      return container
    } catch {
      print("Debug: Failed to create ModelContainer with CloudKit: \(error)")
      
      // Debug: Fallback to local-only storage if CloudKit fails
      let fallbackConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        cloudKitDatabase: .none
      )
      
      do {
        let fallbackContainer = try ModelContainer(
          for: schema,
          configurations: [fallbackConfiguration]
        )
        print("Debug: Created fallback ModelContainer without CloudKit")
        return fallbackContainer
      } catch {
        fatalError("Debug: Failed to create fallback ModelContainer: \(error)")
      }
    }
  }
  
  /// Perform one-time migration of grading system settings from UserDefaults to SwiftData
  /// Debug: This ensures existing users don't lose their grading system configurations
  private func performMigrationIfNeeded() {
    // Debug: Create a temporary context for migration
    let config = ModelConfiguration(isStoredInMemoryOnly: false)
    
    do {
      let container = try ModelContainer(for: Subject.self, Grade.self, GradeType.self, FinalGrade.self, SchoolYearGradingSystem.self, configurations: config)
      let context = ModelContext(container)
      
      // Debug: Check if migration has already been performed
      let migrationKey = "gradingSystemMigrationCompleted"
      if !UserDefaults.standard.bool(forKey: migrationKey) {
        SchoolYearGradingSystemManager.migrateFromUserDefaults(to: context)
        
        // Debug: Mark migration as completed
        UserDefaults.standard.set(true, forKey: migrationKey)
        print("Debug: Grading system migration completed and marked in UserDefaults")
      } else {
        print("Debug: Grading system migration already completed, skipping")
      }
    } catch {
      print("Debug: Error during grading system migration: \(error)")
    }
  }
}
