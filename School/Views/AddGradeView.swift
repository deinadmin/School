//
//  AddGradeView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData

struct AddGradeView: View {
    let subject: Subject
    let schoolYear: SchoolYear
    let semester: Semester
    let preselectedGradeType: GradeType?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gradeValue: Double? = nil // Debug: No grade selected by default
    @State private var selectedGradeType: GradeType = GradeType.defaultTypes[0]
    @State private var gradeDate: Date = Date()
    
    // Debug: Computed property to get all available grade types
    private var allGradeTypes: [GradeType] {
        return GradeTypeManager.getAllGradeTypes()
    }
    
    // Debug: Default initializer for backwards compatibility
    init(subject: Subject, schoolYear: SchoolYear, semester: Semester, preselectedGradeType: GradeType? = nil) {
        self.subject = subject
        self.schoolYear = schoolYear
        self.semester = semester
        self.preselectedGradeType = preselectedGradeType
    }
    
    // Debug: Predefined grade values with German plus/minus system (+ = better/lower, - = worse/higher)
    private let predefinedGrades: [(value: Double, display: String)] = [
        (0.7, "1+"), (1.0, "1"), (1.3, "1-"),
        (1.7, "2+"), (2.0, "2"), (2.3, "2-"),
        (2.7, "3+"), (3.0, "3"), (3.3, "3-"),
        (3.7, "4+"), (4.0, "4"), (4.3, "4-"),
        (4.7, "5+"), (5.0, "5"), (5.3, "5-"),
        (5.7, "6+"), (6.0, "6")
    ]
    
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
                    .disabled(!isValidGrade)
                }
            }
            .onAppear {
                // Debug: Set preselected grade type if provided and available
                if let preselectedType = preselectedGradeType,
                   allGradeTypes.contains(where: { $0.id == preselectedType.id }) {
                    selectedGradeType = preselectedType
                } else if !allGradeTypes.isEmpty {
                    // Debug: Fallback to first available grade type
                    selectedGradeType = allGradeTypes[0]
                }
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
    
    // Debug: Grade value selection with German plus/minus notation
    private var gradeValueSection: some View {
        Section("Notenwert") {
            // Debug: Grid of predefined grade buttons with plus/minus display
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(predefinedGrades, id: \.value) { gradeItem in
                    Button(action: {
                        gradeValue = gradeItem.value
                    }) {
                        Text(gradeItem.display)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(gradeValue == gradeItem.value ? .white : gradeColor(for: gradeItem.value))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(gradeValue == gradeItem.value ? gradeColor(for: gradeItem.value) : gradeColor(for: gradeItem.value).opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // Debug: Grade type selection
    private var gradeTypeSection: some View {
        Section("Art der Bewertung") {
            if !allGradeTypes.isEmpty {
                Picker("Typ", selection: $selectedGradeType) {
                    ForEach(allGradeTypes, id: \.id) { type in
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
        guard let value = gradeValue else { return false } // Debug: No grade selected
        return value >= 0.7 && value <= 6.0 && !allGradeTypes.isEmpty
    }
    
    // Debug: Save the new grade
    private func saveGrade() {
        guard let value = gradeValue else { return } // Debug: Should not happen due to validation
        
        DataManager.createGrade(
            value: value,
            type: selectedGradeType,
            date: gradeDate,
            for: subject,
            schoolYear: schoolYear,
            semester: semester,
            in: modelContext
        )
        
        dismiss()
    }
    
    // Debug: Color coding for grades (German system: 0.7 = best, 6.0 = worst)
    private func gradeColor(for grade: Double) -> Color {
        switch grade {
        case 0.0..<2.0: return .green
        case 2.0..<3.0: return .blue
        case 3.0..<4.0: return .orange
        case 4.0..<5.0: return .red
        default: return .red
        }
    }
} 