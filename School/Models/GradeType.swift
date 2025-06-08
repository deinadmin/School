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
    var name: String
    var weight: Int // Debug: in % (percentage)
    var icon: String
    
    // Debug: SwiftData relationship to subject (inverse relationship)
    var subject: Subject?
    
    // Debug: SwiftData relationship to grades
    @Relationship(deleteRule: .cascade) var grades: [Grade] = []
    
    init(name: String, weight: Int, icon: String, subject: Subject? = nil) {
        self.name = name
        self.weight = weight
        self.icon = icon
        self.subject = subject
    }
    
    /// Default grade types for German schools with percentage weights
    /// Debug: These are used as templates when creating new subjects
    static let defaultSchriftlich = (name: "Schriftlich", weight: 40, icon: "pencil")
    static let defaultMuendlich = (name: "Mündlich", weight: 60, icon: "bubble.fill")
    
    static let defaultTypes: [(name: String, weight: Int, icon: String)] = [
        defaultSchriftlich, defaultMuendlich
    ]
}