//
//  DataManager.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation
import SwiftData

/// DataManager for SwiftData operations
/// Debug: Provides helper methods for working with Subject and Grade models
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
    
    /// Create a new subject (without school year/semester)
    static func createSubject(name: String, colorHex: String, icon: String, in context: ModelContext) {
        let subject = Subject(name: name, colorHex: colorHex, icon: icon)
        context.insert(subject)
        
        do {
            try context.save()
            print("Debug: Subject '\(name)' created successfully")
        } catch {
            print("Debug: Error saving subject: \(error)")
        }
    }
    
    /// Delete a subject and all its grades
    static func deleteSubject(_ subject: Subject, from context: ModelContext) {
        context.delete(subject)
        
        do {
            try context.save()
            print("Debug: Subject '\(subject.name)' deleted successfully")
        } catch {
            print("Debug: Error deleting subject: \(error)")
        }
    }
    
    // MARK: - Grade Operations
    
    /// Get all grades for a specific subject in a specific school year and semester
    static func getGrades(for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> [Grade] {
        let subjectName = subject.name
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
            // Debug: Filter by semester and subject in memory to avoid SwiftData enum predicate issues
            return allGrades.filter { grade in
                grade.semester == semester && grade.subject?.name == subjectName
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
    static func createGrade(value: Double, type: GradeType, date: Date? = nil, for subject: Subject, schoolYear: SchoolYear, semester: Semester, in context: ModelContext) {
        let grade = Grade(value: value, type: type, date: date, schoolYearStartYear: schoolYear.startYear, semester: semester, subject: subject)
        context.insert(grade)
        
        do {
            try context.save()
            print("Debug: Grade \(value) created for subject '\(subject.name)' in \(schoolYear.displayName) \(semester.displayName)")
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
            total + (grade.value * Double(grade.type.weight))
        }
        
        let totalWeight = grades.reduce(0) { total, grade in
            total + grade.type.weight
        }
        
        guard totalWeight > 0 else { return nil }
        
        let average = totalWeightedPoints / Double(totalWeight)
        print("Debug: Calculated average for '\(subject.name)' in \(schoolYear.displayName) \(semester.displayName): \(average)")
        return average
    }
    
    /// Get subjects that have grades in a specific school year/semester
    static func getSubjectsWithGrades(for schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> [Subject] {
        let grades = getGrades(for: schoolYear, semester: semester, from: context)
        let subjectNames = Set(grades.compactMap { $0.subject?.name })
        
        let allSubjects = getAllSubjects(from: context)
        return allSubjects.filter { subjectNames.contains($0.name) }
    }
    
    // MARK: - Grade Type Operations
    
    /// Get unique grade types used by a subject in specific school year/semester
    static func getGradeTypes(for subject: Subject, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> [GradeType] {
        let grades = getGrades(for: subject, schoolYear: schoolYear, semester: semester, from: context)
        let uniqueTypes = Dictionary(grouping: grades, by: { $0.type.id })
            .compactMapValues { $0.first?.type }
            .values
        
        print("Debug: Found \(uniqueTypes.count) unique grade types for '\(subject.name)' in \(schoolYear.displayName) \(semester.displayName)")
        return Array(uniqueTypes).sorted { $0.name < $1.name }
    }
    
    /// Get grades for a specific grade type within a subject/period
    static func getGrades(for subject: Subject, gradeType: GradeType, schoolYear: SchoolYear, semester: Semester, from context: ModelContext) -> [Grade] {
        let allGrades = getGrades(for: subject, schoolYear: schoolYear, semester: semester, from: context)
        return allGrades.filter { $0.type.id == gradeType.id }
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
} 