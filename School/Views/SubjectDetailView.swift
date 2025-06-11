//
//  SubjectDetailView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData

struct SubjectDetailView: View {
    let subject: Subject
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddGrade = false
    @State private var showingAddGradeType = false
    @State private var gradeTypeToEdit: GradeType?
    @State private var showingDeleteGradeTypeAlert = false
    @State private var gradeTypeToDelete: GradeType?
    @State private var selectedGradeTypeForNewGrade: GradeType?
    @State private var gradeTypesUpdateTrigger = UUID() // Debug: Trigger view refresh when grade types change
    @State private var showingFixWeights = false // Debug: Show weight fixing sheet
    
    // Debug: Get grades for this subject in the selected period
    private var grades: [Grade] {
        DataManager.getGrades(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
    }
    
    // Debug: Get all available grade types for this subject - reactive to changes
    private var allAvailableGradeTypes: [GradeType] {
        _ = gradeTypesUpdateTrigger // Debug: Force dependency on update trigger
        return GradeTypeManager.getGradeTypes(for: subject, from: modelContext)
    }
    
    // Debug: Calculate average for selected period
    private var averageGrade: Double? {
        DataManager.calculateWeightedAverage(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Debug: Subject header with icon and info
                    subjectHeaderView
                    
                    // Debug: Statistics section
                    statisticsView
                    
                    // Debug: Grades section with all grade types
                    gradesSection
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) // Debug: Hide default back button to use custom colored one
            .accentColor(Color(hex: subject.colorHex)) // Debug: Use subject color as accent color for entire view and all sheets
            .interactiveDismissDisabled(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .fontWeight(.medium)
                            Text("Fächer")
                                .font(.body)
                        }
                        .foregroundColor(Color(hex: subject.colorHex))
                    }
                }
            }
            .sheet(isPresented: $showingAddGrade) {
                AddGradeView(
                    subject: subject, 
                    schoolYear: selectedSchoolYear, 
                    semester: selectedSemester,
                    preselectedGradeType: selectedGradeTypeForNewGrade
                )
            }
            .sheet(isPresented: $showingAddGradeType) {
                AddGradeTypeView { newGradeType in
                    GradeTypeManager.addGradeType(name: newGradeType.name, weight: newGradeType.weight, icon: newGradeType.icon, for: subject, in: modelContext)
                    gradeTypesUpdateTrigger = UUID() // Debug: Trigger view refresh
                }
            }
            .sheet(item: $gradeTypeToEdit) { gradeType in
                EditGradeTypeView(gradeType: gradeType) { updatedGradeType in
                    print("Debug: Saving updated grade type: \(updatedGradeType.name)")
                    GradeTypeManager.updateGradeType(gradeType, name: updatedGradeType.name, weight: updatedGradeType.weight, icon: updatedGradeType.icon, in: modelContext)
                    gradeTypeToEdit = nil
                    gradeTypesUpdateTrigger = UUID() // Debug: Trigger view refresh
                }
            }
            .sheet(isPresented: $showingFixWeights) {
                FixWeightsView(gradeTypes: allAvailableGradeTypes, subject: subject) {
                    gradeTypesUpdateTrigger = UUID() // Debug: Trigger view refresh after weights are updated
                }
            }
            .alert("Notentyp löschen?", isPresented: $showingDeleteGradeTypeAlert) {
                Button("Löschen", role: .destructive) {
                    if let gradeTypeToDelete = gradeTypeToDelete {
                        deleteGradeType(gradeTypeToDelete)
                    }
                }
                Button("Abbrechen", role: .cancel) {
                    gradeTypeToDelete = nil
                }
            } message: {
                if let gradeTypeToDelete = gradeTypeToDelete {
                    let gradeCount = DataManager.getGrades(for: subject, gradeType: gradeTypeToDelete, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext).count
                    Text("Dies wird den Notentyp '\(gradeTypeToDelete.name)' und alle \(gradeCount) zugehörigen Noten unwiderruflich löschen.")
                }
            }
        }
        .tint(Color(hex: subject.colorHex)) // Debug: Apply subject color to navigation elements (back button, toolbar buttons)
    }
    
    // Debug: Subject header with icon, color, and period info
    private var subjectHeaderView: some View {
        HStack {
            Image(systemName: subject.icon)
                .font(.largeTitle)
                .foregroundColor(Color(hex: subject.colorHex))
                .frame(width: 60, height: 60)
                .background(Color(hex: subject.colorHex).opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("\(selectedSchoolYear.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(selectedSemester.displayName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    // Debug: Statistics overview
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Übersicht")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                StatisticCard(
                    title: "Anzahl Noten",
                    value: "\(grades.count)",
                    icon: "number.circle",
                    color: Color(hex: subject.colorHex)
                )
                
                StatisticCard(
                    title: "Durchschnitt",
                    value: averageGrade != nil ? GradingSystemHelpers.gradeDisplayText(for: averageGrade!, system: selectedSchoolYear.gradingSystem) : "—",
                    icon: "chart.bar",
                    color: averageGrade != nil ? GradingSystemHelpers.gradeColor(for: averageGrade!, system: selectedSchoolYear.gradingSystem) : .gray
                )
            }
        }
    }
    
    // Debug: Grades section showing all grade types as blocks
    private var gradesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Noten")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showingFixWeights = true
                }) {
                    Circle()
                        .fill(.secondary)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.primary.appropriateTextColor())
                                .font(.system(size: 16))
                        )
                }
                .buttonStyle(.scalable)

                Button(action: {
                    showingAddGradeType = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: subject.colorHex))
                        .font(.system(size: 30))
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.scalable)
            }
            
            // Debug: Warning when grade type weights don't add up to 100%
            if !allAvailableGradeTypes.isEmpty {
                let totalWeight = allAvailableGradeTypes.reduce(0) { $0 + $1.weight }
                if totalWeight != 100 {
                    weightWarningView(totalWeight: totalWeight)
                }
            }
            
            if allAvailableGradeTypes.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(allAvailableGradeTypes, id: \.id) { gradeType in
                        gradeTypeBlock(for: gradeType)
                    }
                }
            }
        }
    }
    
    // Debug: Grade type block similar to subject blocks on ContentView
    private func gradeTypeBlock(for gradeType: GradeType) -> some View {
        let gradesForType = DataManager.getGrades(for: subject, gradeType: gradeType, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
            .sorted { grade1, grade2 in
                // Debug: Sort by date - latest first, handle nil dates by putting them last
                guard let date1 = grade1.date else { return false }
                guard let date2 = grade2.date else { return true }
                return date1 > date2
            }
        
        return VStack(alignment: .leading, spacing: 12) {
            // Debug: Grade type header
            HStack {
                Image(systemName: gradeType.icon)
                    .foregroundColor(Color(hex: subject.colorHex))
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: subject.colorHex).opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(gradeType.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Gewichtung: \(gradeType.weight)% • \(gradesForType.count) Noten")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Debug: Three dots menu for grade type management (now works for all types)
                Menu {
                    Button(action: {
                        print("Debug: Setting grade type to edit: \(gradeType.name)")
                        gradeTypeToEdit = gradeType
                    }) {
                        Label("Bearbeiten", systemImage: "pencil")
                        .accentColor(.primary)
                        .tint(.primary)

                    }
                    
                    Button(role: .destructive, action: {
                        gradeTypeToDelete = gradeType
                        showingDeleteGradeTypeAlert = true
                    }) {
                        Label("Löschen", systemImage: "trash")
                        .tint(.red)
                        .accentColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title)
                }
                .buttonStyle(.plain)
                // Debug: Quick add grade button for this type
                Button(action: {
                    selectedGradeTypeForNewGrade = gradeType
                    showingAddGrade = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: subject.colorHex))
                        .font(.title)
                }
                .buttonStyle(.scalable)
                
                
            }
            
            // Debug: Grades list or empty placeholder
            if gradesForType.isEmpty {
                Text("Noch keine Noten für diesen Typ")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(gradesForType, id: \.persistentModelID) { grade in
                        GradeRowView(grade: grade, schoolYear: selectedSchoolYear)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    // Debug: Warning view when grade type weights don't total 100%
    private func weightWarningView(totalWeight: Int) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gewichtung unvollständig")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Die Notentypen haben eine Gesamtgewichtung von \(totalWeight)% statt 100%. Passe die Gewichtungen an für korrekte Durchschnittsberechnung.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            HStack {
                Spacer()
                Button("Problem beheben") {
                    showingFixWeights = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
        }
        .padding()
        .background(.orange.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    // Debug: Empty state when no grade types exist
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Keine Notentypen verfügbar")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Erstelle zuerst einen Notentyp um Noten hinzuzufügen")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Ersten Notentyp erstellen") {
                showingAddGradeType = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    // Debug: Delete grade type and all its grades
    private func deleteGradeType(_ gradeType: GradeType) {
        // Debug: Delete all grades of this type first
        DataManager.deleteGradesOfType(gradeType, for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
        
        // Debug: Delete grade type from storage (now works for both custom and default types)
        GradeTypeManager.deleteGradeType(gradeType, from: modelContext)
        
        gradeTypeToDelete = nil
        gradeTypesUpdateTrigger = UUID() // Debug: Trigger view refresh
        print("Debug: Deleted grade type '\(gradeType.name)' and all its grades")
    }
    
    // Debug: Color coding for grades with unique colors per grade range (German system: 0.7 = best, 6.0 = worst)
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
    
    // Debug: Convert decimal grade to German plus/minus notation (+ = better/lower, - = worse/higher)
    private func gradeDisplayText(for value: Double) -> String {
        switch value {
        case 0.7: return "1+"
        case 1.0: return "1"
        case 1.3: return "1-"
        case 1.7: return "2+"
        case 2.0: return "2"
        case 2.3: return "2-"
        case 2.7: return "3+"
        case 3.0: return "3"
        case 3.3: return "3-"
        case 3.7: return "4+"
        case 4.0: return "4"
        case 4.3: return "4-"
        case 4.7: return "5+"
        case 5.0: return "5"
        case 5.3: return "5-"
        case 5.7: return "6+"
        case 6.0: return "6"
                default: return String(format: "%.1f", value)
        }
    }
}

// Debug: Weight fixing view for easy adjustment of grade type weights
struct FixWeightsView: View {
    let gradeTypes: [GradeType]
    let subject: Subject
    let onSave: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var weightValues: [String: Int] = [:]
    
    var totalWeight: Int {
        weightValues.values.reduce(0, +)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Debug: Header with current status
                headerView
                
                // Debug: Grade types with adjustable weights
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(gradeTypes, id: \.id) { gradeType in
                            gradeTypeWeightRow(for: gradeType)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Gewichtung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveWeights()
                    }
                    .disabled(totalWeight != 100)
                }
            }
            .onAppear {
                // Debug: Initialize weight values with current weights
                for gradeType in gradeTypes {
                    weightValues[String(describing: gradeType.id)] = gradeType.weight
                }
            }
        }
    }
    
    // Debug: Header showing current total and status
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.pie")
                    .font(.title2)
                    .foregroundColor(Color(hex: subject.colorHex))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gesamtgewichtung")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("\(totalWeight)%")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(totalWeight == 100 ? .green : .orange)
                        
                        if totalWeight == 100 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.thinMaterial)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .padding(.horizontal)
            
            if totalWeight != 100 {
                Text("Ziel: 100% für korrekte Durchschnittsberechnung")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // Debug: Individual grade type weight adjustment row
    private func gradeTypeWeightRow(for gradeType: GradeType) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: gradeType.icon)
                    .foregroundColor(Color(hex: subject.colorHex))
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color(hex: subject.colorHex).opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(gradeType.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Aktuell: \(gradeType.weight)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(weightValues[String(describing: gradeType.id)] ?? gradeType.weight)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: subject.colorHex))
                    .frame(minWidth: 60, alignment: .trailing)
            }
            
            // Debug: Slider for weight adjustment
            HStack {
                Text("5%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: Binding(
                        get: { Double(weightValues[String(describing: gradeType.id)] ?? gradeType.weight) },
                        set: { weightValues[String(describing: gradeType.id)] = Int($0) }
                    ),
                    in: 5...100,
                    step: 5
                )
                .tint(Color(hex: subject.colorHex))
                
                Text("100%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    // Debug: Save the updated weights to the model
    private func saveWeights() {
        for gradeType in gradeTypes {
            if let newWeight = weightValues[String(describing: gradeType.id)], newWeight != gradeType.weight {
                GradeTypeManager.updateGradeType(gradeType, name: gradeType.name, weight: newWeight, icon: gradeType.icon, in: modelContext)
            }
        }
        
        onSave()
        dismiss()
    }
}

// Debug: Statistic card component
struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// Debug: Individual grade row component
struct GradeRowView: View {
    let grade: Grade
    let schoolYear: SchoolYear
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(GradingSystemHelpers.gradeDisplayText(for: grade.value, system: schoolYear.gradingSystem))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(GradingSystemHelpers.gradeColor(for: grade.value, system: schoolYear.gradingSystem))
                    
                    if let date = grade.date {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                showingDeleteAlert = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .buttonStyle(.borderless)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .alert("Note löschen?", isPresented: $showingDeleteAlert) {
            Button("Löschen", role: .destructive) {
                DataManager.deleteGrade(grade, from: modelContext)
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
} 