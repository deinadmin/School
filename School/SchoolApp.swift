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
    // Debug: Global theme manager for dynamic accent colors
    @State private var themeManager = ThemeManager.shared
    
  // Debug: Create ModelContainer once as stored property to prevent duplicate CloudKit registrations
  private let container: ModelContainer
  
  init() {
    // Debug: Create schema with all models
    let schema = Schema([
      Subject.self,
      Grade.self,
      GradeType.self,
      FinalGrade.self,
      SchoolYearGradingSystem.self
    ])
    
    // Debug: Configure CloudKit sync with explicit container identifier matching entitlements
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false,
      cloudKitDatabase: .automatic
    )
    
    do {
      // Debug: Create single ModelContainer instance
      let modelContainer = try ModelContainer(
        for: schema,
        configurations: [modelConfiguration]
      )
      
      self.container = modelContainer
      print("Debug: ModelContainer created successfully with CloudKit sync enabled")
      
      // Debug: Perform migration using the same container
      self.performMigrationIfNeeded(with: modelContainer)
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
        self.container = fallbackContainer
        print("Debug: Created fallback ModelContainer without CloudKit")
        
        // Debug: Perform migration using fallback container
        self.performMigrationIfNeeded(with: fallbackContainer)
      } catch {
        fatalError("Debug: Failed to create fallback ModelContainer: \(error)")
      }
    }
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .withToastOverlay() // Debug: Enable toast notifications throughout the entire app
        .environment(themeManager)
        .tint(themeManager.accentColor)
    }
    .modelContainer(container)
  }
  
  /// Perform one-time migration of grading system settings from UserDefaults to SwiftData
  /// Debug: This ensures existing users don't lose their grading system configurations
  private func performMigrationIfNeeded(with container: ModelContainer) {
    // Debug: Check if migration has already been performed
    let migrationKey = "gradingSystemMigrationCompleted"
    guard !UserDefaults.standard.bool(forKey: migrationKey) else {
      print("Debug: Grading system migration already completed, skipping")
      return
    }
    
    // Debug: Use the provided container's context for migration
    let context = ModelContext(container)
    
    SchoolYearGradingSystemManager.migrateFromUserDefaults(to: context)
    
    // Debug: Mark migration as completed
    UserDefaults.standard.set(true, forKey: migrationKey)
    print("Debug: Grading system migration completed and marked in UserDefaults")
  }
}
