//
//  AddGradeView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct AddGradeView: View {
    let subject: Subject
    let schoolYear: SchoolYear
    let semester: Semester
    let preselectedGradeType: GradeType?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gradeValue: Double? = nil // Debug: No grade selected by default
    @State private var selectedGradeType: GradeType? = nil // Debug: Will be set in onAppear 
    @State private var gradeDate: Date = Date()
    @State private var allGradeTypes: [GradeType] = [] // Debug: Cached grade types for stable identity
    @State private var hasInitialized = false // Debug: Track if we've already initialized to avoid resetting on navigation
    
    // Debug: Default initializer for backwards compatibility
    init(subject: Subject, schoolYear: SchoolYear, semester: Semester, preselectedGradeType: GradeType? = nil) {
        self.subject = subject
        self.schoolYear = schoolYear
        self.semester = semester
        self.preselectedGradeType = preselectedGradeType
    }
    

    
    var body: some View {
        NavigationStack {
            Form {
                // Debug: Subject info section
                subjectInfoSection
                
                // Debug: Grade value selection
                gradeValueSection
                
                // Debug: Grade type selection
                gradeTypeSection
                
                // Debug: Date selection
                dateSection
            }
            .navigationTitle("Note hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveGrade()
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValidGrade)
                }
            }
            .onAppear {
                // Debug: Only initialize once to prevent resetting when navigating back from picker
                guard !hasInitialized else {
                    print("Debug: onAppear called but already initialized, skipping to preserve user selection")
                    return
                }
                
                print("Debug: onAppear called - first initialization")
                
                // Debug: Load grade types from context and cache them for stable identity
                allGradeTypes = GradeTypeManager.getGradeTypes(for: subject, from: modelContext)
                
                print("Debug: preselectedGradeType: \(preselectedGradeType?.name ?? "nil")")
                print("Debug: Available grade types: \(allGradeTypes.map { $0.name }.joined(separator: ", "))")
                
                if let preselectedType = preselectedGradeType {
                    print("Debug: Looking for match with ID: \(preselectedType.persistentModelID)")
                    
                    // Debug: Print all available IDs
                    for gradeType in allGradeTypes {
                        print("Debug: Available ID: \(gradeType.persistentModelID) (\(gradeType.name))")
                    }
                    
                    if let matchingType = allGradeTypes.first(where: { $0.persistentModelID == preselectedType.persistentModelID }) {
                        selectedGradeType = matchingType
                        print("Debug: ✅ Successfully matched and preselected: \(matchingType.name)")
                    } else {
                        print("Debug: ❌ No matching ID found, checking by name...")
                        // Debug: Fallback to name matching
                        if let matchingByName = allGradeTypes.first(where: { $0.name == preselectedType.name }) {
                            selectedGradeType = matchingByName
                            print("Debug: ✅ Matched by name: \(matchingByName.name)")
                        } else {
                            selectedGradeType = allGradeTypes.first
                            print("Debug: ❌ No match found, fallback to first: \(allGradeTypes.first?.name ?? "none")")
                        }
                    }
                } else if !allGradeTypes.isEmpty {
                    // Debug: Fallback to first available grade type
                    selectedGradeType = allGradeTypes[0]
                    print("Debug: No preselection provided, fallback to first grade type: \(allGradeTypes[0].name)")
                }
                
                // Debug: Mark as initialized so we don't reset on subsequent onAppear calls
                hasInitialized = true
            }
        }
    }
    

    
    // Debug: Subject information display
    private var subjectInfoSection: some View {
        Section {
            HStack {
                Image(systemName: subject.icon)
                    .foregroundColor(Color(hex: subject.colorHex))
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: subject.colorHex).opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(subject.name)
                        .font(.headline)
                    
                    Text("\(schoolYear.displayName) • \(semester.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
    
    // Debug: Improved grade value selection with 3 per row and distinct colors
    private var gradeValueSection: some View {
        Section("Notenwert") {
            VStack(spacing: 12) {
                // Debug: Organized grade rows based on grading system
                ForEach(gradeRows, id: \.0) { row in
                    HStack(spacing: 12) {
                        ForEach(row.1, id: \.value) { gradeItem in
                            gradeButton(for: gradeItem, rowColor: row.2)
                        }
                        
                        // Debug: Add empty space for rows with fewer items
                        let itemsInRow = row.1.count
                        let maxItemsPerRow = schoolYear.gradingSystem == .traditional ? 3 : 4
                        if itemsInRow < maxItemsPerRow {
                            ForEach(0..<(maxItemsPerRow - itemsInRow), id: \.self) { _ in
                                Spacer()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // Debug: Individual grade button with animations
    private func gradeButton(for gradeItem: (value: Double, display: String), rowColor: Color) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                gradeValue = gradeItem.value
            }
        }) {
            Text(gradeItem.display)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(gradeValue == gradeItem.value ? .white : rowColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Group {
                        if gradeValue == gradeItem.value {
                            rowColor
                        } else {
                            rowColor.opacity(0.12)
                        }
                    }
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(rowColor.opacity(gradeValue == gradeItem.value ? 0 : 0.3), lineWidth: 1)
                )
                .scaleEffect(gradeValue == gradeItem.value ? 1.05 : 1.0)
                .shadow(
                    color: gradeValue == gradeItem.value ? rowColor.opacity(0.3) : .clear,
                    radius: gradeValue == gradeItem.value ? 8 : 0,
                    x: 0, y: 4
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: gradeValue)
        .sensoryFeedback(.increase, trigger: gradeValue)
    }
    
    // Debug: Get grade rows based on the school year's grading system
    private var gradeRows: [(Int, [(value: Double, display: String)], Color)] {
        return GradingSystemHelpers.getGradeRows(for: schoolYear.gradingSystem)
    }
    
    // Debug: Grade type selection
    private var gradeTypeSection: some View {
        Section("Art der Bewertung") {
            if !allGradeTypes.isEmpty {
                Picker("Typ", selection: Binding(
                    get: { selectedGradeType ?? allGradeTypes.first! },
                    set: { 
                        print("Debug: Picker selection changed to: \($0.name)")
                        selectedGradeType = $0 
                    }
                )) {
                    ForEach(allGradeTypes, id: \.persistentModelID) { type in
                        HStack {
                            Image(systemName: type.icon)
                            Text(type.name)
                            Spacer()
                            Text("Gewichtung: \(type.weight)%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .tag(type)
                    }
                }
                .pickerStyle(.navigationLink)
            } else {
                Text("Keine Notentypen verfügbar. Füge welche in der Fachansicht hinzu.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // Debug: Date selection
    private var dateSection: some View {
        Section("Datum") {
            DatePicker("Datum der Bewertung", selection: $gradeDate, displayedComponents: .date)
                .datePickerStyle(.compact)
        }
    }
    
    // Debug: Validation for save button - requires grade to be selected
    private var isValidGrade: Bool {
        return GradingSystemHelpers.isValidGrade(gradeValue, for: schoolYear.gradingSystem) && 
               selectedGradeType != nil && 
               !allGradeTypes.isEmpty
    }
    
    // Debug: Save the new grade
    private func saveGrade() {
        guard let value = gradeValue,
              let gradeType = selectedGradeType else { 
            print("Debug: Cannot save grade - missing value or grade type")
            return 
        }
        
        DataManager.createGrade(
            value: value,
            gradeType: gradeType,
            date: gradeDate,
            for: subject,
            schoolYear: schoolYear,
            semester: semester,
            in: modelContext
        )
        
        print("Debug: Saved grade \(value) for type '\(gradeType.name)'")
        
        // Debug: Update widget after adding new grade
        updateWidget()
        
        dismiss()
    }
    
    /// Update widget with current data
    /// Debug: Triggers widget refresh with latest grade statistics
    private func updateWidget() {
        let allSubjects = DataManager.getAllSubjects(from: modelContext)
        WidgetHelper.updateWidget(
            with: allSubjects,
            selectedSchoolYear: schoolYear,
            selectedSemester: semester,
            from: modelContext
        )
    }
    

} 