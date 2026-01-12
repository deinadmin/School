//
//  GradeTypeManager.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation
import SwiftData

/// Centralized manager for grade types storage and management using SwiftData
/// Debug: Grade types are now stored per subject in SwiftData instead of UserDefaults
class GradeTypeManager {
    
    /// Get all grade types for a specific subject
    static func getGradeTypes(for subject: Subject, from context: ModelContext) -> [GradeType] {
        return DataManager.getGradeTypes(for: subject, from: context)
    }
    
    /// Add a new grade type to a subject
    static func addGradeType(name: String, weight: Int, icon: String, for subject: Subject, in context: ModelContext) {
        DataManager.createGradeType(name: name, weight: weight, icon: icon, for: subject, in: context)
        debugLog(" Added new grade type: '\(name)' to subject '\(subject.name)'")
    }
    
    /// Update an existing grade type
    static func updateGradeType(_ gradeType: GradeType, name: String, weight: Int, icon: String, in context: ModelContext) {
        DataManager.updateGradeType(gradeType, name: name, weight: weight, icon: icon, in: context)
        debugLog(" Updated grade type: '\(name)'")
    }
    
    /// Delete a grade type
    static func deleteGradeType(_ gradeType: GradeType, from context: ModelContext) {
        DataManager.deleteGradeType(gradeType, from: context)
        debugLog(" Deleted grade type: '\(gradeType.name)'")
    }
    
    // MARK: - Legacy methods for backwards compatibility
    
    /// Legacy method for backwards compatibility
    static func addCustomGradeType(_ gradeType: GradeType) {
        // Debug: This method can no longer work without context and subject
        debugLog(" addCustomGradeType is deprecated - use addGradeType(name:weight:icon:for:in:) instead")
    }
    
    /// Legacy method for backwards compatibility  
    static func updateCustomGradeType(_ updatedType: GradeType) {
        // Debug: This method can no longer work without context
        debugLog(" updateCustomGradeType is deprecated - use updateGradeType(_:name:weight:icon:in:) instead")
    }
    
    /// Legacy method for backwards compatibility
    static func deleteCustomGradeType(_ gradeType: GradeType) {
        // Debug: This method can no longer work without context
        debugLog(" deleteCustomGradeType is deprecated - use deleteGradeType(_:from:) instead")
    }
    
    /// Legacy method for backwards compatibility
    static func getAllGradeTypes() -> [GradeType] {
        // Debug: This method can no longer work without context and subject
        debugLog(" getAllGradeTypes is deprecated - use getGradeTypes(for:from:) instead")
        return []
    }
    
    /// Check if a grade type was originally a default grade type (for UI badges)
    static func isOriginallyDefaultGradeType(_ gradeType: GradeType) -> Bool {
        return GradeType.defaultTypes.contains { $0.name == gradeType.name && $0.weight == gradeType.weight }
    }
    
    /// Legacy method for backwards compatibility
    static func isCustomGradeType(_ gradeType: GradeType) -> Bool {
        return !isOriginallyDefaultGradeType(gradeType)
    }
    
    /// Legacy method for backwards compatibility
    static func isDefaultGradeType(_ gradeType: GradeType) -> Bool {
        return isOriginallyDefaultGradeType(gradeType)
    }
} 