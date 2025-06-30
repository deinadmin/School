//
//  GradeType.swift (previously NotenType.swift)
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation
import SwiftData

/// Represents different types of grades (German: NotenType)
/// Debug: Now stored in SwiftData and connected to subjects on a per-subject basis
@Model
final class GradeType {
    var name: String = ""
    var weight: Int = 0 // Debug: in % (percentage)
    var icon: String = "tag.fill"
    
    // Debug: SwiftData relationship to subject (CloudKit requires optional relationships)
    var subject: Subject?
    
    // Debug: SwiftData relationship to grades (CloudKit requires optional relationships)
    @Relationship(deleteRule: .cascade, inverse: \Grade.gradeType) var grades: [Grade]?
    
    init(name: String = "", weight: Int = 0, icon: String = "tag.fill", subject: Subject? = nil) {
        self.name = name
        self.weight = weight
        self.icon = icon
        self.subject = subject
        self.grades = []
    }
    
    /// Default grade types for German schools with percentage weights
    /// Debug: These are used as templates when creating new subjects
    static let defaultSchriftlich = (name: "Schriftlich", weight: 40, icon: "pencil")
    static let defaultMuendlich = (name: "Mündlich", weight: 60, icon: "bubble.fill")
    
    static let defaultTypes: [(name: String, weight: Int, icon: String)] = [
        defaultSchriftlich, defaultMuendlich
    ]
}