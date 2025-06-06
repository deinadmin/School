//
//  GradeType.swift (previously NotenType.swift)
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation

/// Represents different types of grades (German: NotenType)
struct GradeType: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var weight: Int // Debug: in % (percentage)
    var icon: String
    
    init(name: String, weight: Int, icon: String) {
        self.id = UUID()
        self.name = name
        self.weight = weight
        self.icon = icon
    }
    
    // Debug: Init with existing ID for updates
    init(id: UUID, name: String, weight: Int, icon: String) {
        self.id = id
        self.name = name
        self.weight = weight
        self.icon = icon
    }
    
    /// Common grade types for German schools with percentage weights
    static let homework = GradeType(name: "Hausaufgabe", weight: 10, icon: "house")
    static let exam = GradeType(name: "Klassenarbeit", weight: 50, icon: "doc.text")
    static let oralParticipation = GradeType(name: "Mündliche Mitarbeit", weight: 20, icon: "mic")
    static let test = GradeType(name: "Test", weight: 30, icon: "questionmark.circle")
    
    static let defaultTypes: [GradeType] = [
        .homework, .exam, .oralParticipation, .test
    ]
}