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
    var value: Double
    var type: GradeType
    var date: Date?
    var schoolYearStartYear: Int // Debug: Grade belongs to specific school year
    var semester: Semester       // Debug: Grade belongs to specific semester
    
    // Debug: SwiftData relationship to subject (inverse relationship)
    var subject: Subject?
    
    init(value: Double, type: GradeType, date: Date? = nil, schoolYearStartYear: Int, semester: Semester, subject: Subject) {
        self.value = value
        self.type = type
        self.date = date
        self.schoolYearStartYear = schoolYearStartYear
        self.semester = semester
        self.subject = subject
    }
    
    // Debug: Computed property to recreate SchoolYear from stored data
    var schoolYear: SchoolYear {
        return SchoolYear(startYear: schoolYearStartYear)
    }
}