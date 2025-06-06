//
//  SchoolYear.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation

/// Represents a German school year (e.g., 2024/2025)
struct SchoolYear: Hashable, Codable {
    
    let startYear: Int // 2024
    let endYear: Int   // 2025
    
    init(startYear: Int) {
        self.startYear = startYear
        self.endYear = startYear + 1
    }
    
    /// Display format: "2024/2025"
    var displayName: String {
        return "\(startYear)/\(endYear)"
    }
    
    /// Current school year based on German school calendar (starts in August)
    static var current: SchoolYear {
        let now = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        
        // German school year starts in August/September
        if month >= 8 {
            return SchoolYear(startYear: year)
        } else {
            return SchoolYear(startYear: year - 1)
        }
    }
    
    /// Generate all available school years for picker (2000/2001 to 2099/2100)
    static var allAvailableYears: [SchoolYear] {
        return (Calendar.current.component(.year, from: Date())-10...Calendar.current.component(.year, from: Date())).map { SchoolYear(startYear: $0) }
    }
}

extension SchoolYear: Comparable {
    static func < (lhs: SchoolYear, rhs: SchoolYear) -> Bool {
        return lhs.startYear < rhs.startYear
    }
} 
