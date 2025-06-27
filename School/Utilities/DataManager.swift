//
//  DataManager.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation
import SwiftData
import WidgetKit

/// DataManager for SwiftData operations
/// Debug: Provides helper methods for working with Subject, GradeType and Grade models
class DataManager {
    
    // MARK: - Subject Operations
    
    /// Get all subjects (subjects are independent of school year/semester)
    static func getAllSubjects(from context: ModelContext) -> [Subject] {
        let descriptor = FetchDescriptor<Subject>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Debug: Error fetching subjects: \(error)")
            return []
        }
    }
    
    /// Create a new subject with default or custom grade types
    static func createSubject(name: String, colorHex: String, icon: String, customGradeTypes: [(name: String, weight: Int, icon: String)]? = nil, in context: ModelContext) {
        let subject = Subject(name: name, colorHex: colorHex, icon: icon)
        context.insert(subject)
        
        // Debug: Create custom grade types if provided, otherwise use defaults
        if let customTypes = customGradeTypes {
            createCustomGradeTypes(customTypes, for: subject, in: context)
        } else {
            createDefaultGradeTypes(for: subject, in: context)
        }
        
        do {
            try context.save()
            let typeDescription = customGradeTypes != nil ? "custom grade types" : "default grade types"
            print("Debug: Subject '\(name)' created successfully with \(typeDescription)")
        } catch {
            print("Debug: Error saving subject: \(error)")
        }
    }
    
    /// Create default grade types for a subject
    static func createDefaultGradeTypes(for subject: Subject, in context: ModelContext) {
        for defaultType in GradeType.defaultTypes {
            let gradeType = GradeType(
                name: defaultType.name,
                weight: defaultType.weight,
                icon: defaultType.icon,
                subject: subject
            )
            context.insert(gradeType)
        }
        print("Debug: Created \(GradeType.defaultTypes.count) default grade types for subject '\(subject.name)'")
    }
    
    /// Create custom grade types for a subject
    static func createCustomGradeTypes(_ customTypes: [(name: String, weight: Int, icon: String)], for subject: Subject, in context: ModelContext) {
        for customType in customTypes {
            let gradeType = GradeType(
                name: customType.name,
                weight: customType.weight,
                icon: customType.icon,
                subject: subject
            )
            context.insert(gradeType)
        }
        print("Debug: Created \(customTypes.count) custom grade types for subject '\(subject.name)': \(customTypes.map { $0.name }.joined(separator: ", "))")
    }
    
    /// Delete a subject and all its grades and grade types
    static func deleteSubject(_ subject: Subject, from context: ModelContext) {
        context.delete(subject)
        
        do {
            try context.save()
            print("Debug: Subject '\(subject.name)' deleted successfully")
        } catch {
            print("Debug: Error deleting subject: \(error)")
        }
    }
    
    // MARK: - Grade Type Operations
    
    /// Get all grade types for a specific subject
    static func getGradeTypes(for subject: Subject, from context: ModelContext) -> [GradeType] {
        // Debug: Fetch all grade types and filter in memory to avoid complex predicate issues
        let descriptor = FetchDescriptor<GradeType>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            let allGradeTypes = try context.fetch(descriptor)
            return allGradeTypes.filter { gradeType in
                // Debug: Use safer comparison to avoid accessing invalidated objects
                guard let gradeTypeSubject = gradeType.subject else { return false }
                return gradeTypeSubject.persistentModelID == subject.persistentModelID
            }
        } catch {
            print("Debug: Error fetching grade types for subject '\(subject.name)': \(error)")
            return []
        }
    }
    
    /// Create a new grade type for a subject
    static func createGradeType(name: String, weight: Int, icon: String, for subject: Subject, in context: ModelContext) {
        let gradeType = GradeType(name: name, weight: weight, icon: icon, subject: subject)
        context.insert(gradeType)
        
        do {
            try context.save()
            print("Debug: Grade type '\(name)' created for subject '\(subject.name)'")
        } catch {
            print("Debug: Error saving grade type: \(error)")
        }
    }
    
    /// Update an existing grade type
    static func updateGradeType(_ gradeType: GradeType, name: String, weight: Int, icon: String, in context: ModelContext) {
        gradeType.name = name
        gradeType.weight = weight
        gradeType.icon = icon
        
        do {
            try context.save()
            print("Debug: Grade type updated: '\(name)'")
        } catch {
            print("Debug: Error updating grade type: \(error)")
        }
    }
    
    /// Delete a grade type and all its grades
    static func deleteGradeType(_ gradeType: GradeType, from context: ModelContext) {
        context.delete(gradeType)
        
        do {
            try context.save()
            print("Debug: Grade type '\(gradeType.name)' deleted successfully")
        } catch {
            print("Debug: Error deleting grade type: \(error)")
        }
    }
    
    // MARK: - Grade Operations
    
    /// Get all grades for a specific subject in a specific school year and semester
    static func getGrades(for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> [Grade] {
        let subjectName = subject.name
        let schoolYearStart = schoolYear.startYear
        
        // Debug: Use simpler predicate and filter in memory to avoid SwiftData schema issues
        let descriptor = FetchDescriptor<Grade>(
            predicate: #Predicate<Grade> { grade in
                grade.schoolYearStartYear == schoolYearStart
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            let allGrades = try context.fetch(descriptor)
            // Debug: Filter by semester and subject in memory to avoid SwiftData predicate issues
            return allGrades.filter { grade in
                guard let gradeSubject = grade.subject else { return false }
                return grade.semester == semester && gradeSubject.persistentModelID == subject.persistentModelID
            }
        } catch {
            print("Debug: Error fetching grades: \(error)")
            return []
        }
    }
    
    /// Get all grades for a school year and semester (across all subjects)
    static func getGrades(for schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> [Grade] {
        let schoolYearStart = schoolYear.startYear
        
        // Debug: Use simpler predicate without enum rawValue to avoid SwiftData schema issues
        let descriptor = FetchDescriptor<Grade>(
            predicate: #Predicate<Grade> { grade in
                grade.schoolYearStartYear == schoolYearStart
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            let allGrades = try context.fetch(descriptor)
            // Debug: Filter by semester in memory to avoid SwiftData enum predicate issues
            return allGrades.filter { grade in
                grade.semester == semester
            }
        } catch {
            print("Debug: Error fetching grades: \(error)")
            return []
        }
    }
    
    /// Create a new grade for a subject in specific school year/semester
    static func createGrade(value: Double, gradeType: GradeType, date: Date? = nil, for subject: Subject, schoolYear: SchoolYear, semester: Semester, in context: ModelContext) {
        let grade = Grade(value: value, gradeType: gradeType, date: date, schoolYearStartYear: schoolYear.startYear, semester: semester, subject: subject)
        context.insert(grade)
        
        do {
            try context.save()
            print("Debug: Grade \(value) created for subject '\(subject.name)' with type '\(gradeType.name)' in \(schoolYear.displayName) \(semester.displayName)")
        } catch {
            print("Debug: Error saving grade: \(error)")
        }
    }
    
    /// Delete a grade
    static func deleteGrade(_ grade: Grade, from context: ModelContext) {
        context.delete(grade)
        
        do {
            try context.save()
            print("Debug: Grade deleted successfully")
            
            // Debug: Update widget after deleting grade
            updateWidgetAfterGradeChange(from: context)
        } catch {
            print("Debug: Error deleting grade: \(error)")
        }
    }
    
    // MARK: - Statistics
    
    /// Calculate weighted average for a subject in specific school year/semester
    /// Debug: Now checks for final grade first, falls back to calculated average
    static func calculateWeightedAverage(for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> Double? {
        // Debug: Check if final grade exists and return it instead of calculated average
        if let finalGrade = getFinalGrade(for: subject, schoolYear: schoolYear, semester: semester, from: context) {
            print("Debug: Using final grade for '\(subject.name)' in \(schoolYear.displayName) \(semester.displayName): \(finalGrade.value)")
            return finalGrade.value
        }
        
        let grades = getGrades(for: subject, schoolYear: schoolYear, semester: semester, from: context)
        
        guard !grades.isEmpty else { return nil }
        
        let totalWeightedPoints = grades.reduce(0.0) { total, grade in
            let weight = grade.gradeType?.weight ?? 0
            return total + (grade.value * Double(weight))
        }
        
        let totalWeight = grades.reduce(0) { total, grade in
            let weight = grade.gradeType?.weight ?? 0
            return total + weight
        }
        
        guard totalWeight > 0 else { return nil }
        
        let average = totalWeightedPoints / Double(totalWeight)
        print("Debug: Calculated average for '\(subject.name)' in \(schoolYear.displayName) \(semester.displayName): \(average)")
        return average
    }
    
    /// Calculate overall weighted average from a collection of grades across all subjects
    /// Debug: This calculates a simple average across all grades, weighted by their individual grade type weights
    static func calculateOverallWeightedAverage(from grades: [Grade]) -> Double? {
        guard !grades.isEmpty else { return nil }
        
        let totalWeightedPoints = grades.reduce(0.0) { total, grade in
            let weight = grade.gradeType?.weight ?? 0
            return total + (grade.value * Double(weight))
        }
        
        let totalWeight = grades.reduce(0) { total, grade in
            let weight = grade.gradeType?.weight ?? 0
            return total + weight
        }
        
        guard totalWeight > 0 else { return nil }
        
        let average = totalWeightedPoints / Double(totalWeight)
        print("Debug: Calculated overall weighted average from \(grades.count) grades: \(average)")
        return average
    }
    
    /// Calculate overall average with final grades for report card calculation
    /// Debug: Uses final grades when set, otherwise calculated averages, for accurate report card grade
    static func calculateOverallAverageWithFinalGrades(for subjects: [Subject], schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> Double? {
        var subjectAverages: [Double] = []
        
        for subject in subjects {
            // Debug: Get the weighted average for this subject (includes final grade override)
            if let average = calculateWeightedAverage(for: subject, schoolYear: schoolYear, semester: semester, from: context) {
                subjectAverages.append(average)
            }
        }
        
        guard !subjectAverages.isEmpty else { return nil }
        
        // Debug: Calculate simple average of all subject averages for overall grade
        let overallAverage = subjectAverages.reduce(0.0, +) / Double(subjectAverages.count)
        print("Debug: Calculated overall average with final grades from \(subjectAverages.count) subjects: \(overallAverage)")
        return overallAverage
    }
    
    /// Get subjects that have grades in a specific school year/semester
    static func getSubjectsWithGrades(for schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> [Subject] {
        let grades = getGrades(for: schoolYear, semester: semester, from: context)
        let subjectNames = Set(grades.compactMap { $0.subject?.name })
        
        let allSubjects = getAllSubjects(from: context)
        return allSubjects.filter { subjectNames.contains($0.name) }
    }
    
    /// Get grades for a specific grade type within a subject/period
    static func getGrades(for subject: Subject, gradeType: GradeType, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> [Grade] {
        let allGrades = getGrades(for: subject, schoolYear: schoolYear, semester: semester, from: context)
        return allGrades.filter { grade in
            guard let gradeGradeType = grade.gradeType,
                  let gradeTypeSubject = gradeGradeType.subject else { return false }
            return gradeGradeType.persistentModelID == gradeType.persistentModelID && 
                   gradeTypeSubject.persistentModelID == subject.persistentModelID
        }
    }
    
    /// Delete all grades of a specific type for a subject in specific period
    static func deleteGradesOfType(_ gradeType: GradeType, for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) {
        let gradesToDelete = getGrades(for: subject, gradeType: gradeType, schoolYear: schoolYear, semester: semester, from: context)
        
        for grade in gradesToDelete {
            context.delete(grade)
        }
        
        do {
            try context.save()
            print("Debug: Deleted \(gradesToDelete.count) grades of type '\(gradeType.name)' for subject '\(subject.name)'")
        } catch {
            print("Debug: Error deleting grades of type: \(error)")
        }
    }
    
    // MARK: - Grading System Conversion
    
    /// Convert all grades and final grades for a school year to a new grading system
    /// Debug: Used when user changes grading system - converts all existing grades and final grades
    static func convertGradingSystem(for schoolYear: SchoolYear, to newSystem: GradingSystem, from context: ModelContext) -> (success: Bool, convertedCount: Int, errorMessage: String?) {
        let grades = getAllGrades(for: schoolYear, from: context)
        let finalGrades = getAllFinalGrades(for: schoolYear, from: context)
        
        guard !grades.isEmpty || !finalGrades.isEmpty else {
            print("Debug: No grades or final grades to convert for school year \(schoolYear.displayName)")
            return (true, 0, nil)
        }
        
        let oldSystem = schoolYear.gradingSystem
        var convertedCount = 0
        
        print("Debug: Converting \(grades.count) grades and \(finalGrades.count) final grades from \(oldSystem.displayName) to \(newSystem.displayName)")
        
        // Debug: Convert regular grades
        for grade in grades {
            let oldValue = grade.value
            let newValue = GradingSystemHelpers.convertGrade(oldValue, from: oldSystem, to: newSystem)
            
            grade.value = newValue
            convertedCount += 1
            
            print("Debug: Converted grade \(oldValue) → \(newValue)")
        }
        
        // Debug: Convert final grades
        for finalGrade in finalGrades {
            let oldValue = finalGrade.value
            let newValue = GradingSystemHelpers.convertGrade(oldValue, from: oldSystem, to: newSystem)
            
            finalGrade.value = newValue
            convertedCount += 1
            
            print("Debug: Converted final grade \(oldValue) → \(newValue)")
        }
        
        do {
            try context.save()
            print("Debug: Successfully converted \(convertedCount) grades and final grades to \(newSystem.displayName)")
            return (true, convertedCount, nil)
        } catch {
            print("Debug: Error saving converted grades and final grades: \(error)")
            return (false, 0, "Fehler beim Speichern der konvertierten Noten: \(error.localizedDescription)")
        }
    }
    
    /// Get all grades for a school year (both semesters)
    /// Debug: Helper method for grade conversion
    private static func getAllGrades(for schoolYear: SchoolYear, from context: ModelContext) -> [Grade] {
        let descriptor = FetchDescriptor<Grade>(
            predicate: #Predicate<Grade> { grade in
                grade.schoolYearStartYear == schoolYear.startYear
            }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Debug: Error fetching grades for conversion: \(error)")
            return []
        }
    }
    
    /// Get all final grades for a school year (both semesters)
    /// Debug: Helper method for final grade conversion
    private static func getAllFinalGrades(for schoolYear: SchoolYear, from context: ModelContext) -> [FinalGrade] {
        let descriptor = FetchDescriptor<FinalGrade>(
            predicate: #Predicate<FinalGrade> { finalGrade in
                finalGrade.schoolYearStartYear == schoolYear.startYear
            }
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Debug: Error fetching final grades for conversion: \(error)")
            return []
        }
    }
    
    /// Check if a school year has any grades or final grades stored (for any semester)
    /// Debug: Used to show conversion preview to user
    static func hasGrades(for schoolYear: SchoolYear, from context: ModelContext) -> Bool {
        let grades = getAllGrades(for: schoolYear, from: context)
        let finalGrades = getAllFinalGrades(for: schoolYear, from: context)
        return !grades.isEmpty || !finalGrades.isEmpty
    }
    
    /// Get count of grades and final grades for a specific school year (for display purposes)
    /// Debug: Used to show user how many grades and final grades will be converted
    static func getGradeCount(for schoolYear: SchoolYear, from context: ModelContext) -> Int {
        let gradeCount = getAllGrades(for: schoolYear, from: context).count
        let finalGradeCount = getAllFinalGrades(for: schoolYear, from: context).count
        return gradeCount + finalGradeCount
    }
    
    // MARK: - Final Grade Operations
    
    /// Get final grade for a subject in specific school year/semester
    /// Debug: Returns manual final grade that overrides calculated average
    static func getFinalGrade(for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> FinalGrade? {
        let descriptor = FetchDescriptor<FinalGrade>(
            predicate: #Predicate<FinalGrade> { finalGrade in
                finalGrade.schoolYearStartYear == schoolYear.startYear
            }
        )
        
        do {
            let allFinalGrades = try context.fetch(descriptor)
            return allFinalGrades.first { finalGrade in
                guard let finalGradeSubject = finalGrade.subject else { return false }
                return finalGrade.semester == semester && finalGradeSubject.persistentModelID == subject.persistentModelID
            }
        } catch {
            print("Debug: Error fetching final grade: \(error)")
            return nil
        }
    }
    
    /// Set final grade for a subject in specific school year/semester
    /// Debug: Creates new final grade or updates existing one
    static func setFinalGrade(value: Double, for subject: Subject, schoolYear: SchoolYear, semester: Semester, in context: ModelContext) {
        // Debug: Check if final grade already exists
        if let existingFinalGrade = getFinalGrade(for: subject, schoolYear: schoolYear, semester: semester, from: context) {
            existingFinalGrade.value = value
            print("Debug: Updated existing final grade for '\(subject.name)' to \(value)")
        } else {
            let finalGrade = FinalGrade(value: value, schoolYearStartYear: schoolYear.startYear, semester: semester, subject: subject)
            context.insert(finalGrade)
            print("Debug: Created new final grade for '\(subject.name)': \(value)")
        }
        
        do {
            try context.save()
            print("Debug: Final grade saved successfully for '\(subject.name)' in \(schoolYear.displayName) \(semester.displayName)")
            
            // Debug: Update widget after setting final grade
            updateWidgetAfterGradeChange(from: context)
        } catch {
            print("Debug: Error saving final grade: \(error)")
        }
    }
    
    /// Remove final grade for a subject in specific school year/semester
    /// Debug: Deletes final grade so calculated average is used again
    static func removeFinalGrade(for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) {
        if let finalGrade = getFinalGrade(for: subject, schoolYear: schoolYear, semester: semester, from: context) {
            context.delete(finalGrade)
            
            do {
                try context.save()
                print("Debug: Removed final grade for '\(subject.name)' in \(schoolYear.displayName) \(semester.displayName)")
            } catch {
                print("Debug: Error removing final grade: \(error)")
            }
        }
    }
    
    /// Check if subject has final grade set for specific period
    /// Debug: Used to determine UI display (final grade vs calculated average)
    static func hasFinalGrade(for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> Bool {
        return getFinalGrade(for: subject, schoolYear: schoolYear, semester: semester, from: context) != nil
    }
    
    /// Get calculated average without final grade override
    /// Debug: Used to show user what the calculated average would be alongside final grade
    static func getCalculatedAverage(for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> Double? {
        let grades = getGrades(for: subject, schoolYear: schoolYear, semester: semester, from: context)
        
        guard !grades.isEmpty else { return nil }
        
        let totalWeightedPoints = grades.reduce(0.0) { total, grade in
            let weight = grade.gradeType?.weight ?? 0
            return total + (grade.value * Double(weight))
        }
        
        let totalWeight = grades.reduce(0) { total, grade in
            let weight = grade.gradeType?.weight ?? 0
            return total + weight
        }
        
        guard totalWeight > 0 else { return nil }
        
        return totalWeightedPoints / Double(totalWeight)
    }
    
    // MARK: - Widget Update Helper
    
    /// Update widget after grade changes
    /// Debug: Uses current user's school year/semester selection from UserDefaults
    private static func updateWidgetAfterGradeChange(from context: ModelContext) {
        // Debug: Load current user selection from UserDefaults
        let currentSchoolYear = loadCurrentSchoolYear()
        let currentSemester = loadCurrentSemester()
        let allSubjects = getAllSubjects(from: context)
        
        WidgetHelper.updateWidget(
            with: allSubjects,
            selectedSchoolYear: currentSchoolYear,
            selectedSemester: currentSemester,
            from: context
        )
    }
    
    /// Load current school year selection from UserDefaults
    /// Debug: Uses same keys as ContentView to get user's current selection
    private static func loadCurrentSchoolYear() -> SchoolYear {
        if let savedSchoolYear = UserDefaults.standard.getStruct(forKey: "selectedSchoolYear", as: SchoolYear.self) {
            return savedSchoolYear
        } else {
            return SchoolYear.current
        }
    }
    
    /// Load current semester selection from UserDefaults
    /// Debug: Uses same keys as ContentView to get user's current selection
    private static func loadCurrentSemester() -> Semester {
        if let savedSemester = UserDefaults.standard.getStruct(forKey: "selectedSemester", as: Semester.self) {
            return savedSemester
        } else {
            return .first
        }
    }
}
