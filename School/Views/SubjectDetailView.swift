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
    
    // Debug: Get grades for this subject in the selected period
    private var grades: [Grade] {
        DataManager.getGrades(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
    }
    
    // Debug: Get all available grade types (show all, not just used) - reactive to changes
    private var allAvailableGradeTypes: [GradeType] {
        _ = gradeTypesUpdateTrigger // Debug: Force dependency on update trigger
        return GradeTypeManager.getAllGradeTypes()
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            selectedGradeTypeForNewGrade = nil
                            showingAddGrade = true
                        }) {
                            Label("Note hinzufügen", systemImage: "plus")
                        }
                        
                        Button(action: {
                            showingAddGradeType = true
                        }) {
                            Label("Notentyp hinzufügen", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
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
                    GradeTypeManager.addCustomGradeType(newGradeType)
                    gradeTypesUpdateTrigger = UUID() // Debug: Trigger view refresh
                }
            }
            .sheet(item: $gradeTypeToEdit) { gradeType in
                EditGradeTypeView(gradeType: gradeType) { updatedGradeType in
                    print("Debug: Saving updated grade type: \(updatedGradeType.name)")
                    GradeTypeManager.updateGradeType(updatedGradeType)
                    gradeTypeToEdit = nil
                    gradeTypesUpdateTrigger = UUID() // Debug: Trigger view refresh
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
        .background(.ultraThinMaterial)
        .cornerRadius(12)
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
                    value: averageGrade != nil ? gradeDisplayText(for: averageGrade!) : "—",
                    icon: "chart.bar",
                    color: averageGrade != nil ? gradeColor(for: averageGrade!) : .gray
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
                    showingAddGradeType = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: subject.colorHex))
                        .font(.title2)
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
                
                // Debug: Quick add grade button for this type
                Button(action: {
                    selectedGradeTypeForNewGrade = gradeType
                    showingAddGrade = true
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(Color(hex: subject.colorHex))
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                // Debug: Three dots menu for grade type management (now works for all types)
                Menu {
                    Button(action: {
                        print("Debug: Setting grade type to edit: \(gradeType.name)")
                        gradeTypeToEdit = gradeType
                    }) {
                        Label("Bearbeiten", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        gradeTypeToDelete = gradeType
                        showingDeleteGradeTypeAlert = true
                    }) {
                        Label("Löschen", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
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
                    ForEach(gradesForType, id: \.self) { grade in
                        GradeRowView(grade: grade)
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(10)
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
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
    
    // Debug: Delete grade type and all its grades
    private func deleteGradeType(_ gradeType: GradeType) {
        // Debug: Delete all grades of this type first
        DataManager.deleteGradesOfType(gradeType, for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
        
        // Debug: Delete grade type from storage (now works for both custom and default types)
        GradeTypeManager.deleteGradeType(gradeType)
        
        gradeTypeToDelete = nil
        gradeTypesUpdateTrigger = UUID() // Debug: Trigger view refresh
        print("Debug: Deleted grade type '\(gradeType.name)' and all its grades")
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
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

// Debug: Individual grade row component
struct GradeRowView: View {
    let grade: Grade
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(gradeDisplayText(for: grade.value))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(gradeColor(for: grade.value))
                    
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
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .alert("Note löschen?", isPresented: $showingDeleteAlert) {
            Button("Löschen", role: .destructive) {
                DataManager.deleteGrade(grade, from: modelContext)
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
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