//
//  SchoolYear.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation
import SwiftData

/// SwiftData model for storing grading system settings per school year
/// Debug: This replaces UserDefaults storage to enable iCloud sync
@Model
final class SchoolYearGradingSystem {
    // Performance: Index for frequent filtering by school year
    @Attribute(.spotlight) var startYear: Int = 0
    var gradingSystemRawValue: String = "traditional"
    
    init(startYear: Int = 0, gradingSystem: GradingSystem = .traditional) {
        self.startYear = startYear
        self.gradingSystemRawValue = gradingSystem.rawValue
    }
    
    /// Computed property to get the grading system enum
    var gradingSystem: GradingSystem {
        return GradingSystem(rawValue: gradingSystemRawValue) ?? .traditional
    }
}

/// Grading system types used in German schools
/// Debug: Traditional system (1-6, lower is better) vs Points system (0-15, higher is better)
enum GradingSystem: String, Codable, CaseIterable {
    case traditional = "traditional" // Debug: 1-6 system (1+ = 0.7 best, 6 = 6.0 worst)
    case points = "points"           // Debug: 0-15 system (15 = best, 0 = worst)
    
    var displayName: String {
        switch self {
        case .traditional:
            return "Noten (1-6)"
        case .points:
            return "Punkte (0-15)"
        }
    }
    
    var description: String {
        switch self {
        case .traditional:
            return "Traditionelles System: 1+ ist die beste Note, 6 die schlechteste"
        case .points:
            return "Punktesystem: 15 Punkte ist die beste Note, 0 die schlechteste"
        }
    }
    
    /// Minimum grade value for this system
    var minValue: Double {
        switch self {
        case .traditional: return 0.7  // Debug: 1+ in traditional system
        case .points: return 0.0       // Debug: 0 points
        }
    }
    
    /// Maximum grade value for this system  
    var maxValue: Double {
        switch self {
        case .traditional: return 6.0  // Debug: 6 in traditional system
        case .points: return 15.0      // Debug: 15 points
        }
    }
}

/// Represents a German school year (e.g., 2024/2025) with grading system
struct SchoolYear: Hashable, Codable {
    
    let startYear: Int // 2024
    let endYear: Int   // 2025
    let gradingSystem: GradingSystem // Debug: Which grading system this year uses
    
    init(startYear: Int, gradingSystem: GradingSystem = .traditional) {
        self.startYear = startYear
        self.endYear = startYear + 1
        self.gradingSystem = gradingSystem
    }
    
    /// Display format: "2024/2025"
    var displayName: String {
        return "\(startYear)/\(endYear)"
    }
    
    /// Display format with grading system: "2024/2025 (Noten)"
    var displayNameWithSystem: String {
        return "\(displayName) (\(gradingSystem.displayName))"
    }
    
    /// Current school year based on German school calendar (starts in August)
    static var current: SchoolYear {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        // German school year starts in August/September
        if month >= 8 {
            return SchoolYear(startYear: year)
        } else {
            return SchoolYear(startYear: year - 1)
        }
    }
    
    /// Generate all available school years for picker (current-20 to current+5)
    /// Debug: Now requires ModelContext to load saved grading systems from SwiftData
    static func allAvailableYears(from context: ModelContext) -> [SchoolYear] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (currentYear-20...currentYear+5).map { year in
            let savedSystem = SchoolYearGradingSystemManager.getGradingSystem(forSchoolYear: year, from: context) ?? .traditional
            return SchoolYear(startYear: year, gradingSystem: savedSystem)
        }
    }
    
    /// Legacy method for backwards compatibility - requires context now
    /// Debug: This method is deprecated, use allAvailableYears(from:) instead
    static var allAvailableYears: [SchoolYear] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (currentYear-20...currentYear+5).map { year in
            // Debug: Fallback to traditional system when no context available
            return SchoolYear(startYear: year, gradingSystem: .traditional)
        }
    }
}

extension SchoolYear: Comparable {
    static func < (lhs: SchoolYear, rhs: SchoolYear) -> Bool {
        return lhs.startYear < rhs.startYear
    }
}

// MARK: - SwiftData Manager for Grading System Settings

/// Manager for SwiftData operations on grading system settings
/// Debug: Replaces UserDefaults-based storage for iCloud sync compatibility
class SchoolYearGradingSystemManager {
    
    /// Get grading system for a specific school year from SwiftData
    /// Debug: Replaces UserDefaults.gradingSystem(forSchoolYear:)
    static func getGradingSystem(forSchoolYear startYear: Int, from context: ModelContext) -> GradingSystem? {
        let descriptor = FetchDescriptor<SchoolYearGradingSystem>(
            predicate: #Predicate<SchoolYearGradingSystem> { setting in
                setting.startYear == startYear
            }
        )
        
        do {
            let settings = try context.fetch(descriptor)
            let setting = settings.first
            let system = setting?.gradingSystem
            if let system = system {
                debugLog(" Loaded grading system '\(system.displayName)' for school year \(startYear)/\(startYear + 1)")
            }
            return system
        } catch {
            debugLog(" Error fetching grading system for school year \(startYear): \(error)")
            return nil
        }
    }
    
    /// Set grading system for a specific school year in SwiftData
    /// Debug: Replaces UserDefaults.setGradingSystem(_:forSchoolYear:)
    static func setGradingSystem(_ system: GradingSystem, forSchoolYear startYear: Int, in context: ModelContext) {
        // Debug: Check if setting already exists
        if let existingSetting = getSchoolYearGradingSystemModel(forSchoolYear: startYear, from: context) {
            existingSetting.gradingSystemRawValue = system.rawValue
            debugLog(" Updated existing grading system for school year \(startYear)/\(startYear + 1) to '\(system.displayName)'")
        } else {
            let newSetting = SchoolYearGradingSystem(startYear: startYear, gradingSystem: system)
            context.insert(newSetting)
            debugLog(" Created new grading system setting for school year \(startYear)/\(startYear + 1): '\(system.displayName)'")
        }
        
        do {
            try context.save()
            debugLog(" Saved grading system '\(system.displayName)' for school year \(startYear)/\(startYear + 1)")
        } catch {
            debugLog(" Error saving grading system: \(error)")
        }
    }
    
    /// Check if a school year has any saved grading system setting in SwiftData
    /// Debug: Replaces UserDefaults.hasGradingSystemSetting(forSchoolYear:)
    static func hasGradingSystemSetting(forSchoolYear startYear: Int, from context: ModelContext) -> Bool {
        return getSchoolYearGradingSystemModel(forSchoolYear: startYear, from: context) != nil
    }
    
    /// Get the SchoolYearGradingSystem model for a specific year
    /// Debug: Helper method for internal use
    private static func getSchoolYearGradingSystemModel(forSchoolYear startYear: Int, from context: ModelContext) -> SchoolYearGradingSystem? {
        let descriptor = FetchDescriptor<SchoolYearGradingSystem>(
            predicate: #Predicate<SchoolYearGradingSystem> { setting in
                setting.startYear == startYear
            }
        )
        
        do {
            let settings = try context.fetch(descriptor)
            return settings.first
        } catch {
            debugLog(" Error fetching grading system setting: \(error)")
            return nil
        }
    }
    
    /// Migrate existing UserDefaults grading system settings to SwiftData
    /// Debug: One-time migration helper for existing users
    static func migrateFromUserDefaults(to context: ModelContext) {
        let currentYear = Calendar.current.component(.year, from: Date())
        var migratedCount = 0
        
        debugLog(" Starting migration of grading system settings from UserDefaults to SwiftData")
        
        // Debug: Check years from current-20 to current+5 for existing settings
        for year in (currentYear-20)...(currentYear+5) {
            if let system = UserDefaults.standard.gradingSystem(forSchoolYear: year) {
                // Debug: Only migrate if not already in SwiftData
                if !hasGradingSystemSetting(forSchoolYear: year, from: context) {
                    setGradingSystem(system, forSchoolYear: year, in: context)
                    migratedCount += 1
                }
            }
        }
        
        if migratedCount > 0 {
            debugLog(" Successfully migrated \(migratedCount) grading system settings from UserDefaults to SwiftData")
        } else {
            debugLog(" No grading system settings found in UserDefaults to migrate")
        }
    }
    
    /// Clean up UserDefaults after successful migration
    /// Debug: Removes old UserDefaults keys after migration
    static func cleanupUserDefaultsAfterMigration() {
        let currentYear = Calendar.current.component(.year, from: Date())
        var cleanedCount = 0
        
        for year in (currentYear-20)...(currentYear+5) {
            let key = "gradingSystem_\(year)"
            if UserDefaults.standard.object(forKey: key) != nil {
                UserDefaults.standard.removeObject(forKey: key)
                cleanedCount += 1
            }
        }
        
        if cleanedCount > 0 {
            debugLog(" Cleaned up \(cleanedCount) UserDefaults keys after migration")
        }
    }
}

// MARK: - Legacy UserDefaults Extensions (deprecated)

extension UserDefaults {
    
    /// Get grading system for a specific school year (DEPRECATED)
    /// Debug: This method is deprecated - use SchoolYearGradingSystemManager instead
    func gradingSystem(forSchoolYear startYear: Int) -> GradingSystem? {
        let key = "gradingSystem_\(startYear)"
        guard let systemString = string(forKey: key) else { return nil }
        return GradingSystem(rawValue: systemString)
    }
    
    /// Set grading system for a specific school year (DEPRECATED)
    /// Debug: This method is deprecated - use SchoolYearGradingSystemManager instead
    func setGradingSystem(_ system: GradingSystem, forSchoolYear startYear: Int) {
        let key = "gradingSystem_\(startYear)"
        set(system.rawValue, forKey: key)
        debugLog(" (DEPRECATED) Saved grading system '\(system.displayName)' for school year \(startYear)/\(startYear + 1) to UserDefaults")
    }
    
    /// Check if a school year has any saved grading system setting (DEPRECATED)
    /// Debug: This method is deprecated - use SchoolYearGradingSystemManager instead
    func hasGradingSystemSetting(forSchoolYear startYear: Int) -> Bool {
        let key = "gradingSystem_\(startYear)"
        return object(forKey: key) != nil
    }
} 
