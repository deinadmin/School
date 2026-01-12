//
//  Subject.swift (previously Fach.swift)
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation
import SwiftUI
import SwiftData

/// Represents a school subject (German: Fach)
/// Debug: Subject exists independently of school years - only grades are year/semester specific
@Model
final class Subject {
    var name: String = ""
    var colorHex: String = "#007AFF" 
    var icon: String = "book.fill"
    
    // Debug: SwiftData relationship to grades (CloudKit requires optional relationships)
    @Relationship(deleteRule: .cascade, inverse: \Grade.subject) var grades: [Grade]?
    
    // Debug: SwiftData relationship to grade types (CloudKit requires optional relationships with inverse)
    @Relationship(deleteRule: .cascade, inverse: \GradeType.subject) var gradeTypes: [GradeType]?
    
    // Debug: SwiftData relationship to final grades (CloudKit requires optional relationships)
    @Relationship(deleteRule: .cascade, inverse: \FinalGrade.subject) var finalGrades: [FinalGrade]?
    
    init(name: String = "", colorHex: String = "#007AFF", icon: String = "book.fill") {
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.grades = []
        self.gradeTypes = []
        self.finalGrades = []
    }
}

/// Represents a manual final grade for a subject in a specific school year and semester
/// Debug: Overrides calculated average when set, used for report card grade calculation
@Model
final class FinalGrade {
    var value: Double = 0.0
    // Performance: Index for frequent filtering by school year
    @Attribute(.spotlight) var schoolYearStartYear: Int = 0
    var semester: Semester? // Debug: Final grade belongs to specific semester (CloudKit requires optional or no default)
    
    // Debug: SwiftData relationship to subject (CloudKit requires optional relationships)
    var subject: Subject?
    
    init(value: Double = 0.0, schoolYearStartYear: Int = 0, semester: Semester = .first, subject: Subject? = nil) {
        self.value = value
        self.schoolYearStartYear = schoolYearStartYear
        self.semester = semester
        self.subject = subject
    }
    
    // Debug: Computed property to recreate SchoolYear from stored data
    var schoolYear: SchoolYear {
        return SchoolYear(startYear: schoolYearStartYear)
    }
}
