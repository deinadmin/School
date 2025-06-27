//
//  WidgetDataManager.swift
//  SchoolWidget
//
//  Created by Carl on 26.06.25.
//

import Foundation
import WidgetKit

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
        
        print("Debug: Widget data saved - Average: \(overallAverage?.description ?? "nil"), Subjects: \(subjectCount), Grades: \(gradeCount)")
        
        // Debug: Trigger widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Load Data (from widget)
    
    /// Load widget data for display in widget
    /// Debug: Called by widget timeline provider to get current data
    static func loadWidgetData() -> SchoolWidgetEntry {
        guard let defaults = sharedDefaults else {
            print("Debug: Widget - Could not access shared UserDefaults - App Group 'group.de.designedbycarl.School' not configured")
            print("Debug: Widget - Please ensure App Group is enabled in both app and widget targets")
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
        
        let updateTime = lastUpdate?.timeIntervalSinceNow ?? 0
        print("Debug: Widget data loaded - Average: \(overallAverage?.description ?? "nil"), Subjects: \(subjectCount), Grades: \(gradeCount), Last Update: \(Int(-updateTime))s ago")
        return entry
    }
    
    // MARK: - Utility Functions
    
    /// Check when widget data was last updated
    /// Debug: Used to determine if data is stale
    static func getLastUpdateDate() -> Date? {
        return sharedDefaults?.object(forKey: lastUpdateKey) as? Date
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
}

// MARK: - Extensions for shared models

extension SchoolYear {
    /// Initialize from shared storage with fallback
    static func fromSharedStorage(startYear: Int, gradingSystemRaw: String) -> SchoolYear {
        let gradingSystem = GradingSystem(rawValue: gradingSystemRaw) ?? .traditional
        return startYear > 0 ? SchoolYear(startYear: startYear, gradingSystem: gradingSystem) : .current
    }
}

extension Semester {
    /// Initialize from shared storage with fallback
    static func fromSharedStorage(rawValue: String) -> Semester {
        return Semester(rawValue: rawValue) ?? .first
    }
}

extension GradingSystem {
    /// Initialize from shared storage with fallback
    static func fromSharedStorage(rawValue: String) -> GradingSystem {
        return GradingSystem(rawValue: rawValue) ?? .traditional
    }
} 