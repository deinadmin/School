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
    var name: String
    var colorHex: String
    var icon: String
    
    // Debug: SwiftData relationship to grades
    @Relationship(deleteRule: .cascade) var grades: [Grade] = []
    
    // Debug: SwiftData relationship to grade types (each subject has its own grade types)
    @Relationship(deleteRule: .cascade) var gradeTypes: [GradeType] = []
    
    // Debug: SwiftData relationship to final grades (manual end-of-semester grades)
    @Relationship(deleteRule: .cascade) var finalGrades: [FinalGrade] = []
    
    init(name: String, colorHex: String, icon: String) {
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
    }
}

/// Represents a manual final grade for a subject in a specific school year and semester
/// Debug: Overrides calculated average when set, used for report card grade calculation
@Model
final class FinalGrade {
    var value: Double
    var schoolYearStartYear: Int // Debug: Final grade belongs to specific school year
    var semester: Semester       // Debug: Final grade belongs to specific semester
    
    // Debug: SwiftData relationship to subject (inverse relationship)
    var subject: Subject?
    
    init(value: Double, schoolYearStartYear: Int, semester: Semester, subject: Subject) {
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
