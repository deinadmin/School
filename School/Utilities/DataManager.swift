//
//  DataManager.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation
import SwiftData

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
        } catch {
            print("Debug: Error deleting grade: \(error)")
        }
    }
    
    // MARK: - Statistics
    
    /// Calculate weighted average for a subject in specific school year/semester
    static func calculateWeightedAverage(for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> Double? {
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
    
    /// Convert all grades for a school year to a new grading system
    /// Debug: Used when user changes grading system - converts all existing grades
    static func convertGradingSystem(for schoolYear: SchoolYear, to newSystem: GradingSystem, from context: ModelContext) -> (success: Bool, convertedCount: Int, errorMessage: String?) {
        let grades = getAllGrades(for: schoolYear, from: context)
        
        guard !grades.isEmpty else {
            print("Debug: No grades to convert for school year \(schoolYear.displayName)")
            return (true, 0, nil)
        }
        
        let oldSystem = schoolYear.gradingSystem
        var convertedCount = 0
        
        print("Debug: Converting \(grades.count) grades from \(oldSystem.displayName) to \(newSystem.displayName)")
        
        for grade in grades {
            let oldValue = grade.value
            let newValue = GradingSystemHelpers.convertGrade(oldValue, from: oldSystem, to: newSystem)
            
            grade.value = newValue
            convertedCount += 1
            
            print("Debug: Converted grade \(oldValue) → \(newValue)")
        }
        
        do {
            try context.save()
            print("Debug: Successfully converted \(convertedCount) grades to \(newSystem.displayName)")
            return (true, convertedCount, nil)
        } catch {
            print("Debug: Error saving converted grades: \(error)")
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
    
    /// Check if a school year has any grades stored (for any semester)
    /// Debug: Used to show conversion preview to user
    static func hasGrades(for schoolYear: SchoolYear, from context: ModelContext) -> Bool {
        let grades = getAllGrades(for: schoolYear, from: context)
        return !grades.isEmpty
    }
    
    /// Get count of grades for a specific school year (for display purposes)
    /// Debug: Used to show user how many grades will be converted
    static func getGradeCount(for schoolYear: SchoolYear, from context: ModelContext) -> Int {
        return getAllGrades(for: schoolYear, from: context).count
    }
}
