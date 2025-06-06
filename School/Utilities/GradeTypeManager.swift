//
//  GradeTypeManager.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation

/// Centralized manager for grade types storage and management
/// Debug: Seeds user types with defaults on first launch, then treats all types equally
class GradeTypeManager {
    
    private static let userGradeTypesKey = "app_user_grade_types"
    private static let hasSeededDefaultsKey = "app_has_seeded_defaults"
    
    /// Get all available grade types (user types only, seeded with defaults on first launch)
    static func getAllGradeTypes() -> [GradeType] {
        ensureDefaultsSeeded()
        return getUserGradeTypes()
    }
    
    /// Ensure default grade types are seeded on first launch
    private static func ensureDefaultsSeeded() {
        guard !UserDefaults.standard.bool(forKey: hasSeededDefaultsKey) else {
            return // Already seeded
        }
        
        print("Debug: First launch detected - seeding user grade types with defaults")
        saveUserGradeTypes(GradeType.defaultTypes)
        UserDefaults.standard.set(true, forKey: hasSeededDefaultsKey)
        print("Debug: Seeded \(GradeType.defaultTypes.count) default grade types to user storage")
    }
    
    /// Get user grade types from UserDefaults
    static func getUserGradeTypes() -> [GradeType] {
        guard let data = UserDefaults.standard.data(forKey: userGradeTypesKey),
              let types = try? JSONDecoder().decode([GradeType].self, from: data) else {
            print("Debug: No user grade types found or failed to decode")
            return []
        }
        
        print("Debug: Loaded \(types.count) user grade types from UserDefaults")
        return types
    }
    
    /// Save user grade types to UserDefaults
    static func saveUserGradeTypes(_ types: [GradeType]) {
        do {
            let data = try JSONEncoder().encode(types)
            UserDefaults.standard.set(data, forKey: userGradeTypesKey)
            print("Debug: Saved \(types.count) user grade types to UserDefaults")
        } catch {
            print("Debug: Error saving user grade types: \(error)")
        }
    }
    
    /// Add a new grade type
    static func addGradeType(_ gradeType: GradeType) {
        var userTypes = getUserGradeTypes()
        userTypes.append(gradeType)
        saveUserGradeTypes(userTypes)
        print("Debug: Added new grade type: '\(gradeType.name)'")
    }
    
    /// Update an existing grade type
    static func updateGradeType(_ updatedType: GradeType) {
        var userTypes = getUserGradeTypes()
        
        if let index = userTypes.firstIndex(where: { $0.id == updatedType.id }) {
            userTypes[index] = updatedType
            saveUserGradeTypes(userTypes)
            print("Debug: Updated grade type: '\(updatedType.name)'")
        } else {
            print("Debug: Grade type with ID \(updatedType.id) not found for update")
        }
    }
    
    /// Delete a grade type
    static func deleteGradeType(_ gradeType: GradeType) {
        var userTypes = getUserGradeTypes()
        userTypes.removeAll { $0.id == gradeType.id }
        saveUserGradeTypes(userTypes)
        print("Debug: Deleted grade type: '\(gradeType.name)'")
    }
    
    /// Legacy method for backwards compatibility
    static func addCustomGradeType(_ gradeType: GradeType) {
        addGradeType(gradeType)
    }
    
    /// Legacy method for backwards compatibility
    static func updateCustomGradeType(_ updatedType: GradeType) {
        updateGradeType(updatedType)
    }
    
    /// Legacy method for backwards compatibility
    static func deleteCustomGradeType(_ gradeType: GradeType) {
        deleteGradeType(gradeType)
    }
    
    /// Check if a grade type was originally a default type (for UI badges)
    static func isOriginallyDefaultGradeType(_ gradeType: GradeType) -> Bool {
        return GradeType.defaultTypes.contains { $0.id == gradeType.id }
    }
    
    /// Legacy method for backwards compatibility
    static func isCustomGradeType(_ gradeType: GradeType) -> Bool {
        return !isOriginallyDefaultGradeType(gradeType)
    }
    
    /// Legacy method for backwards compatibility
    static func isDefaultGradeType(_ gradeType: GradeType) -> Bool {
        return isOriginallyDefaultGradeType(gradeType)
    }
    
    /// Get grade type by ID from all available types
    static func getGradeType(by id: UUID) -> GradeType? {
        return getAllGradeTypes().first { $0.id == id }
    }
} 