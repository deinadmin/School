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
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var gradeValue: Double = 2.0
    @State private var selectedGradeType: GradeType = GradeType.defaultTypes[0]
    @State private var gradeDate: Date = Date()
    @State private var showingAddGradeType = false
    @State private var customGradeTypes: [GradeType] = []
    
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
            .sheet(isPresented: $showingAddGradeType) {
                AddGradeTypeView { newGradeType in
                    addCustomGradeType(newGradeType)
                }
            }
            .onAppear {
                loadCustomGradeTypes()
            }
        }
    }
    
    // Debug: Function to add new custom grade type
    private func addCustomGradeType(_ gradeType: GradeType) {
        customGradeTypes.append(gradeType)
        selectedGradeType = gradeType
        saveCustomGradeTypes()
    }
    
    // Debug: Function to delete custom grade type
    private func deleteCustomGradeType(at offsets: IndexSet) {
        // Debug: Check if we're trying to delete the currently selected type
        for index in offsets {
            if customGradeTypes[index].id == selectedGradeType.id {
                selectedGradeType = GradeType.defaultTypes[0]
            }
        }
        customGradeTypes.remove(atOffsets: offsets)
        saveCustomGradeTypes()
    }
    
    // Debug: Save custom grade types to UserDefaults
    private func saveCustomGradeTypes() {
        if let data = try? JSONEncoder().encode(customGradeTypes) {
            UserDefaults.standard.set(data, forKey: "customGradeTypes")
        }
    }
    
    // Debug: Load custom grade types from UserDefaults
    private func loadCustomGradeTypes() {
        if let data = UserDefaults.standard.data(forKey: "customGradeTypes"),
           let types = try? JSONDecoder().decode([GradeType].self, from: data) {
            customGradeTypes = types
        }
    }
    
    // Debug: Subject information display
    private var subjectInfoSection: some View {
        Section {
            HStack {
                Image(systemName: subject.icon)
                    .foregroundColor(Color(hex: subject.colorHex))
                    .font(.title2)
                
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
    
    // Debug: Grade type selection with custom types and swipe-to-delete
    private var gradeTypeSection: some View {
        Section("Art der Bewertung") {
            // Debug: Show picker only if we have types to choose from
            if !allGradeTypes.isEmpty {
                Picker("Typ", selection: $selectedGradeType) {
                    ForEach(allGradeTypes, id: \.id) { type in
                        if type.name != "ADD_NEW" {
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
                    
                    // Debug: Add new grade type option in picker
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                        Text("Neuen Notentyp hinzufügen")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .tag(GradeType(name: "ADD_NEW", weight: 0, icon: "plus.circle"))
                }
                .pickerStyle(.navigationLink)
                .onChange(of: selectedGradeType) { _, newValue in
                    if newValue.name == "ADD_NEW" {
                        showingAddGradeType = true
                        // Reset to first available type
                        selectedGradeType = allGradeTypes.first(where: { $0.name != "ADD_NEW" }) ?? GradeType.defaultTypes[0]
                    }
                }
            }
            
            // Debug: Show custom types with swipe-to-delete
            if !customGradeTypes.isEmpty {
                Text("Benutzerdefinierte Notentypen")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                ForEach(customGradeTypes, id: \.id) { customType in
                    HStack {
                        Image(systemName: customType.icon)
                            .foregroundColor(.blue)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(customType.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Gewichtung: \(customType.weight)%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        if selectedGradeType.id == customType.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedGradeType = customType
                    }
                }
                .onDelete(perform: deleteCustomGradeType)
                
                Text("← Nach links wischen zum Löschen")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    // Debug: Computed property to get all available grade types
    private var allGradeTypes: [GradeType] {
        return GradeType.defaultTypes + customGradeTypes
    }
    
    // Debug: Date selection
    private var dateSection: some View {
        Section("Datum") {
            DatePicker("Datum der Bewertung", selection: $gradeDate, displayedComponents: .date)
                .datePickerStyle(.compact)
        }
    }
    
    // Debug: Validation for save button
    private var isValidGrade: Bool {
        return gradeValue >= 0.7 && gradeValue <= 6.0
    }
    
    // Debug: Save the new grade
    private func saveGrade() {
        DataManager.createGrade(
            value: gradeValue,
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