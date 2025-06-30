//
//  WidgetHelper.swift
//  School
//
//  Created by Carl on 26.06.25.
//

import Foundation
import SwiftData
import WidgetKit

/// Helper class to manage widget updates from the main app
/// Debug: Provides functions to update widget data when grades change
class WidgetHelper {
    
    /// Update widget with current statistics
    /// Debug: Calculates current overall average and updates shared storage
    static func updateWidget(
        with subjects: [Subject],
        selectedSchoolYear: SchoolYear,
        selectedSemester: Semester,
        from context: ModelContext
    ) {
        // Debug: Calculate current statistics
        let overallAverage = DataManager.calculateOverallAverageWithFinalGrades(
            for: subjects,
            schoolYear: selectedSchoolYear,
            semester: selectedSemester,
            from: context
        )
        
        let subjectCount = subjects.count
        let totalGrades = subjects.reduce(0) { total, subject in
            let grades = subject.grades ?? []
            let filteredGrades = grades.filter { grade in
                grade.schoolYearStartYear == selectedSchoolYear.startYear && (grade.semester ?? .first) == selectedSemester
            }
            return total + filteredGrades.count
        }
        
        print("Debug: Updating widget - Average: \(overallAverage?.description ?? "nil"), Subjects: \(subjectCount), Grades: \(totalGrades)")
        
        // Debug: Save to shared storage
        WidgetDataManager.saveWidgetData(
            overallAverage: overallAverage,
            subjectCount: subjectCount,
            gradeCount: totalGrades,
            selectedSchoolYear: selectedSchoolYear,
            selectedSemester: selectedSemester
        )
    }
    
    /// Update widget when app becomes active
    /// Debug: Ensures widget shows latest data when user opens app
    static func updateWidgetOnAppActive(
        with subjects: [Subject],
        selectedSchoolYear: SchoolYear,
        selectedSemester: Semester,
        from context: ModelContext
    ) {
        updateWidget(
            with: subjects,
            selectedSchoolYear: selectedSchoolYear,
            selectedSemester: selectedSemester,
            from: context
        )
    }
    
    /// Clear widget data
    /// Debug: Used when user logs out or deletes all data
    static func clearWidget() {
        WidgetDataManager.clearWidgetData()
    }
    
    /// Validate widget setup
    /// Debug: Check if App Group is properly configured
    static func validateWidgetSetup() -> Bool {
        return WidgetDataManager.validateAppGroupAccess()
    }
    
    /// Debug widget status
    /// Debug: Print detailed information about widget state for troubleshooting
    static func debugWidgetStatus(
        with subjects: [Subject],
        selectedSchoolYear: SchoolYear,
        selectedSemester: Semester,
        from context: ModelContext
    ) {
        print("\n=== WIDGET DEBUG STATUS ===")
        
        // Debug: App Group access
        let hasAppGroupAccess = WidgetDataManager.validateAppGroupAccess()
        print("1. App Group Access: \(hasAppGroupAccess ? "✅ SUCCESS" : "❌ FAILED")")
        
        if !hasAppGroupAccess {
            print("   → Problem: App Group 'group.de.designedbycarl.School' not accessible")
            print("   → Solution: Enable App Groups capability in both app and widget targets")
        }
        
        // Debug: Current data
        let overallAverage = DataManager.calculateOverallAverageWithFinalGrades(
            for: subjects,
            schoolYear: selectedSchoolYear,
            semester: selectedSemester,
            from: context
        )
        
        let subjectCount = subjects.count
        let totalGrades = subjects.reduce(0) { total, subject in
            let grades = subject.grades ?? []
            let filteredGrades = grades.filter { grade in
                grade.schoolYearStartYear == selectedSchoolYear.startYear && (grade.semester ?? .first) == selectedSemester
            }
            return total + filteredGrades.count
        }
        
        print("2. Current App Data:")
        print("   → School Year: \(selectedSchoolYear.displayName)")
        print("   → Semester: \(selectedSemester.displayName)")
        print("   → Grading System: \(selectedSchoolYear.gradingSystem.displayName)")
        print("   → Subjects: \(subjectCount)")
        print("   → Total Grades: \(totalGrades)")
        print("   → Overall Average: \(overallAverage?.description ?? "nil")")
        
        // Debug: Widget data
        if hasAppGroupAccess {
            let widgetEntry = WidgetDataManager.loadWidgetData()
            print("3. Widget Shared Data:")
            print("   → School Year: \(widgetEntry.selectedSchoolYear.displayName)")
            print("   → Semester: \(widgetEntry.selectedSemester.displayName)")
            print("   → Grading System: \(widgetEntry.gradingSystem.displayName)")
            print("   → Subjects: \(widgetEntry.subjectCount)")
            print("   → Grades: \(widgetEntry.gradeCount)")
            print("   → Average: \(widgetEntry.overallAverage?.description ?? "nil")")
            
            if let lastUpdate = WidgetDataManager.getLastUpdateDate() {
                let timeSinceUpdate = Date().timeIntervalSince(lastUpdate)
                print("   → Last Update: \(Int(timeSinceUpdate))s ago")
            } else {
                print("   → Last Update: Never")
            }
        }
        
        print("4. Recommended Actions:")
        if !hasAppGroupAccess {
            print("   → Configure App Group in both targets in Xcode")
            print("   → Ensure both targets use same Team ID")
        } else if totalGrades == 0 {
            print("   → Add some grades to test widget functionality")
        } else {
            print("   → Widget should be working - check widget on home screen")
        }
        
        print("=== END DEBUG STATUS ===\n")
    }
}

// MARK: - Widget Data Manager (Shared)

/// Manages data sharing between the main app and widget
/// Debug: Uses shared UserDefaults (App Group) to transfer widget data
class WidgetDataManager {
    
    // Debug: App Group identifier - this needs to be configured in both targets
    static let appGroupIdentifier = "group.de.designedbycarl.School"
    
    // Debug: UserDefaults keys for widget data
    private static let overallAverageKey = "widget_overall_average"
    private static let subjectCountKey = "widget_subject_count"
    private static let gradeCountKey = "widget_grade_count"
    private static let selectedSchoolYearKey = "widget_selected_school_year"
    private static let selectedSemesterKey = "widget_selected_semester"
    private static let gradingSystemKey = "widget_grading_system"
    private static let lastUpdateKey = "widget_last_update"
    
    /// Shared UserDefaults for App Group communication
    /// Debug: This allows both app and widget to access the same data
    private static var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // MARK: - Save Data (from main app)
    
    /// Save current widget data from the main app
    /// Debug: Called whenever the app wants to update widget data
    static func saveWidgetData(
        overallAverage: Double?,
        subjectCount: Int,
        gradeCount: Int,
        selectedSchoolYear: SchoolYear,
        selectedSemester: Semester
    ) {
        guard let defaults = sharedDefaults else {
            print("Debug: Widget - Could not access shared UserDefaults")
            return
        }
        
        // Debug: Save all widget-relevant data
        if let average = overallAverage {
            defaults.set(average, forKey: overallAverageKey)
        } else {
            defaults.removeObject(forKey: overallAverageKey)
        }
        
        defaults.set(subjectCount, forKey: subjectCountKey)
        defaults.set(gradeCount, forKey: gradeCountKey)
        defaults.set(selectedSchoolYear.startYear, forKey: selectedSchoolYearKey)
        defaults.set(selectedSemester.rawValue, forKey: selectedSemesterKey)
        defaults.set(selectedSchoolYear.gradingSystem.rawValue, forKey: gradingSystemKey)
        defaults.set(Date(), forKey: lastUpdateKey)
        
        // Debug: Also sync user settings to App Group for widget access
        syncUserSettingsToAppGroup()
        
        print("Debug: Widget data saved - Average: \(overallAverage?.description ?? "nil"), Subjects: \(subjectCount), Grades: \(gradeCount)")
        
        // Debug: Trigger widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Clear all widget data
    /// Debug: Used for debugging or when user logs out
    static func clearWidgetData() {
        guard let defaults = sharedDefaults else { return }
        
        defaults.removeObject(forKey: overallAverageKey)
        defaults.removeObject(forKey: subjectCountKey)
        defaults.removeObject(forKey: gradeCountKey)
        defaults.removeObject(forKey: selectedSchoolYearKey)
        defaults.removeObject(forKey: selectedSemesterKey)
        defaults.removeObject(forKey: gradingSystemKey)
        defaults.removeObject(forKey: lastUpdateKey)
        
        print("Debug: Widget data cleared")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Check if app group is properly configured
    /// Debug: Validation function for setup
    static func validateAppGroupAccess() -> Bool {
        guard let defaults = sharedDefaults else {
            print("Debug: Widget - App Group '\(appGroupIdentifier)' not accessible")
            return false
        }
        
        // Debug: Test write/read access
        let testKey = "widget_test_key"
        let testValue = "test_value"
        
        defaults.set(testValue, forKey: testKey)
        let readValue = defaults.string(forKey: testKey)
        defaults.removeObject(forKey: testKey)
        
        let isWorking = readValue == testValue
        print("Debug: Widget - App Group access test: \(isWorking ? "SUCCESS" : "FAILED")")
        return isWorking
    }
    
    // MARK: - Load Data (for debugging)
    
    /// Load widget data for debugging purposes
    /// Debug: Called by debug function to show what widget sees
    static func loadWidgetData() -> SchoolWidgetEntry {
        guard let defaults = sharedDefaults else {
            print("Debug: Widget - Could not access shared UserDefaults - App Group not configured")
            return SchoolWidgetEntry.emptyEntry
        }
        
        // Debug: Check if any data exists in shared storage
        let lastUpdate = defaults.object(forKey: lastUpdateKey) as? Date
        if lastUpdate == nil {
            print("Debug: Widget - No widget data found in shared storage, app hasn't updated widget yet")
            return SchoolWidgetEntry.emptyEntry
        }
        
        // Debug: Load all data from shared storage
        let overallAverage = defaults.object(forKey: overallAverageKey) as? Double
        let subjectCount = defaults.integer(forKey: subjectCountKey)
        let gradeCount = defaults.integer(forKey: gradeCountKey)
        let schoolYearStart = defaults.integer(forKey: selectedSchoolYearKey)
        let semesterRaw = defaults.string(forKey: selectedSemesterKey) ?? Semester.first.rawValue
        let gradingSystemRaw = defaults.string(forKey: gradingSystemKey) ?? GradingSystem.traditional.rawValue
        
        // Debug: Reconstruct objects from stored data
        let semester = Semester(rawValue: semesterRaw) ?? .first
        let gradingSystem = GradingSystem(rawValue: gradingSystemRaw) ?? .traditional
        let schoolYear = schoolYearStart > 0 ? 
            SchoolYear(startYear: schoolYearStart, gradingSystem: gradingSystem) : 
            SchoolYear.current
        
        let entry = SchoolWidgetEntry(
            date: Date(),
            overallAverage: overallAverage,
            subjectCount: subjectCount,
            gradeCount: gradeCount,
            selectedSchoolYear: schoolYear,
            selectedSemester: semester,
            gradingSystem: gradingSystem
        )
        
        return entry
    }
    
    /// Check when widget data was last updated
    /// Debug: Used to determine if data is stale
    static func getLastUpdateDate() -> Date? {
        return sharedDefaults?.object(forKey: lastUpdateKey) as? Date
    }
    
    /// Sync user settings from main UserDefaults to App Group for widget access
    /// Debug: This ensures widgets can access user preferences like rounding settings
    private static func syncUserSettingsToAppGroup() {
        guard let sharedDefaults = sharedDefaults else { return }
        
        // Debug: Sync rounding setting
        let roundPointAverages = UserDefaults.standard.object(forKey: "roundPointAverages") as? Bool ?? true
        sharedDefaults.set(roundPointAverages, forKey: "roundPointAverages")
        
        // Debug: Sync character setting (widget doesn't need this, but for completeness)
        let showMotivationalCharacter = UserDefaults.standard.object(forKey: "showMotivationalCharacter") as? Bool ?? false
        sharedDefaults.set(showMotivationalCharacter, forKey: "showMotivationalCharacter")
        
        print("Debug: Synced user settings to App Group - Round points: \(roundPointAverages)")
    }
}

// MARK: - Shared Widget Entry Structure

/// Widget Timeline Entry containing the data to display
/// Debug: Shared between main app and widget for debugging
struct SchoolWidgetEntry {
    let date: Date
    let overallAverage: Double?
    let subjectCount: Int
    let gradeCount: Int
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    let gradingSystem: GradingSystem
    
    // Debug: Sample data for previews
    static let sampleEntry = SchoolWidgetEntry(
        date: Date(),
        overallAverage: 2.1,
        subjectCount: 8,
        gradeCount: 24,
        selectedSchoolYear: SchoolYear.current,
        selectedSemester: .first,
        gradingSystem: .traditional
    )
    
    static let emptyEntry = SchoolWidgetEntry(
        date: Date(),
        overallAverage: nil,
        subjectCount: 0,
        gradeCount: 0,
        selectedSchoolYear: SchoolYear.current,
        selectedSemester: .first,
        gradingSystem: .traditional
    )
} 