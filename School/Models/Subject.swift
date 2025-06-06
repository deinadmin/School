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
    
    init(name: String, colorHex: String, icon: String) {
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
    }
}
