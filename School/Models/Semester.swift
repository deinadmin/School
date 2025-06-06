//
//  Semester.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation

/// Represents the two halves of a German school year
enum Semester: String, CaseIterable, Identifiable, Codable {
    case first = "1. Halbjahr"
    case second = "2. Halbjahr"
    
    var id: String { rawValue }
    
    /// Display name for UI
    var displayName: String {
        return rawValue
    }
    
    /// Short display name
    var shortName: String {
        switch self {
        case .first: return "1. HJ"
        case .second: return "2. HJ"
        }
    }
} 