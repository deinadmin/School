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
    @State private var selectedGradeType: GradeType = GradeType(name: "Schriftlich", weight: 40, icon: "pencil")
    @State private var gradeDate: Date = Date()
    
    // Debug: Computed property to get all available grade types for this subject
    private var allGradeTypes: [GradeType] {
        return GradeTypeManager.getGradeTypes(for: subject, from: modelContext)
    }
    
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
                    .disabled(!isValidGrade)
                }
            }
            .onAppear {
                // Debug: Set preselected grade type if provided and available
                if let preselectedType = preselectedGradeType,
                   allGradeTypes.contains(where: { $0.name == preselectedType.name }) {
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
    
    // Debug: Improved grade value selection with 3 per row and distinct colors
    private var gradeValueSection: some View {
        Section("Notenwert") {
            VStack(spacing: 12) {
                // Debug: Organized grade rows (+ grade, grade, - grade)
                ForEach(gradeRows, id: \.0) { row in
                    HStack(spacing: 12) {
                        ForEach(row.1, id: \.value) { gradeItem in
                            gradeButton(for: gradeItem, rowColor: row.2)
                        }
                        
                        // Debug: Add empty space for last row (6+, 6, empty)
                        if row.1.count < 3 {
                            Spacer()
                                .frame(maxWidth: .infinity)
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
    }
    
    // Debug: Organized grade rows with unique colors per row matching updated SubjectDetailView
    private var gradeRows: [(Int, [(value: Double, display: String)], Color)] {
        [
            (1, [(0.7, "1+"), (1.0, "1"), (1.3, "1-")], .green),    // Debug: 0.7-1.3 = green (best)
            (2, [(1.7, "2+"), (2.0, "2"), (2.3, "2-")], .blue),     // Debug: 1.7-2.3 = blue (good)
            (3, [(2.7, "3+"), (3.0, "3"), (3.3, "3-")], .cyan),     // Debug: 2.7-3.3 = cyan (okay)
            (4, [(3.7, "4+"), (4.0, "4"), (4.3, "4-")], .orange),   // Debug: 3.7-4.3 = orange (poor)
            (5, [(4.7, "5+"), (5.0, "5"), (5.3, "5-")], .red),      // Debug: 4.7-5.3 = red (bad)
            (6, [(5.7, "6+"), (6.0, "6")], .pink) // Debug: 5.7-6.0 = pink (worst), only 2 grades
        ]
    }
    
    // Debug: Color coding function with unique colors per grade range (German system: 0.7 = best, 6.0 = worst)
    private func gradeColor(for grade: Double) -> Color {
        switch grade {
        case 0.7..<1.7: return .green    // Debug: Grade 1 range
        case 1.7..<2.7: return .blue     // Debug: Grade 2 range
        case 2.7..<3.7: return .cyan     // Debug: Grade 3 range
        case 3.7..<4.7: return .orange   // Debug: Grade 4 range
        case 4.7..<5.7: return .red      // Debug: Grade 5 range
        case 5.7...6.0: return .pink     // Debug: Grade 6 range
        default: return .gray
        }
    }
    
    // Debug: Grade type selection
    private var gradeTypeSection: some View {
        Section("Art der Bewertung") {
            if !allGradeTypes.isEmpty {
                Picker("Typ", selection: $selectedGradeType) {
                    ForEach(allGradeTypes, id: \.name) { type in
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
            gradeType: selectedGradeType,
            date: gradeDate,
            for: subject,
            schoolYear: schoolYear,
            semester: semester,
            in: modelContext
        )
        
        dismiss()
    }
    

} 