//
//  Grade.swift (previously Note.swift)
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation
import SwiftData

/// Represents a grade/mark (German: Note)
/// Debug: Grades are specific to school year and semester, but subjects are general
@Model
final class Grade {
    var value: Double = 0.0
    var date: Date?
    var schoolYearStartYear: Int = 0 // Debug: Grade belongs to specific school year
    var semester: Semester? // Debug: Grade belongs to specific semester (CloudKit requires optional or no default)
    
    // Debug: SwiftData relationship to subject (CloudKit requires optional relationships)
    var subject: Subject?
    
    // Debug: SwiftData relationship to grade type (CloudKit requires optional relationships)
    var gradeType: GradeType?
    
    init(value: Double = 0.0, gradeType: GradeType? = nil, date: Date? = nil, schoolYearStartYear: Int = 0, semester: Semester = .first, subject: Subject? = nil) {
        self.value = value
        self.gradeType = gradeType
        self.date = date
        self.schoolYearStartYear = schoolYearStartYear
        self.semester = semester
        self.subject = subject
    }
    
    // Debug: Computed property to recreate SchoolYear from stored data
    var schoolYear: SchoolYear {
        return SchoolYear(startYear: schoolYearStartYear)
    }
    
    // Debug: Backward compatibility property for accessing grade type
    var type: GradeType? {
        return gradeType
    }
}