//
//  QuickGradeAddView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct QuickGradeAddView: View {
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Subject.name) private var allSubjects: [Subject]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    LazyVStack(spacing: 12) {
                        ForEach(allSubjects, id: \.persistentModelID) { subject in
                            NavigationLink(destination: QuickGradeTypeSelectionView(
                                subject: subject,
                                selectedSchoolYear: selectedSchoolYear,
                                selectedSemester: selectedSemester,
                                dismissSheet: dismiss
                            )) {
                                QuickGradeSubjectRowView(
                                    subject: subject,
                                    selectedSchoolYear: selectedSchoolYear,
                                    selectedSemester: selectedSemester
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Fach wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuickGradeTypeSelectionView: View {
    let subject: Subject
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    let dismissSheet: DismissAction
    
    @Environment(\.modelContext) private var modelContext
    
    private var gradeTypes: [GradeType] {
        GradeTypeManager.getGradeTypes(for: subject, from: modelContext)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if gradeTypes.isEmpty {
                    emptyGradeTypesView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(gradeTypes, id: \.id) { gradeType in
                            NavigationLink(destination: QuickGradeValueSelectionView(
                                subject: subject,
                                gradeType: gradeType,
                                selectedSchoolYear: selectedSchoolYear,
                                selectedSemester: selectedSemester,
                                dismissSheet: dismissSheet
                            )) {
                                QuickGradeTypeRowView(
                                    gradeType: gradeType,
                                    subject: subject,
                                    selectedSchoolYear: selectedSchoolYear,
                                    selectedSemester: selectedSemester
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Notentyp wählen")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var emptyGradeTypesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Keine Notentypen verfügbar")
                .font(.headline)
                .bold()
                .foregroundColor(.primary)
            
            Text("Erstelle zuerst Notentypen für dieses Fach in der Fachansicht.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
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

struct QuickGradeValueSelectionView: View {
    let subject: Subject
    let gradeType: GradeType
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    let dismissSheet: DismissAction
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedGradeValue: Double?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                selectedInfoView
                gradePickerSection
            }
            .padding(.horizontal)   
        }
        .navigationTitle("Note eingeben")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var selectedInfoView: some View {
        VStack(spacing: 12) {
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
                    
                    Text("\(selectedSchoolYear.displayName) • \(selectedSemester.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            
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
                    
                    Text("Gewichtung: \(gradeType.weight)%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
    
    private var gradePickerSection: some View {
        VStack(spacing: 16) {
            Text("Note auswählen")
                .font(.headline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(gradeRows, id: \.0) { row in
                    HStack(spacing: 12) {
                        ForEach(row.1, id: \.value) { gradeItem in
                            gradeButton(for: gradeItem, rowColor: row.2)
                        }
                        
                        // Debug: Add empty space for rows with fewer items
                        let itemsInRow = row.1.count
                        let maxItemsPerRow = selectedSchoolYear.gradingSystem == .traditional ? 3 : 4
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveGrade()
                    }
                    .accentColor(Color(hex: subject.colorHex))
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedGradeValue == nil)
                }
            }

            if selectedGradeValue != nil {
                Button(action: saveGrade) {
                    HStack {
                        Spacer()
                        Text("Note speichern")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: subject.colorHex))
                    .cornerRadius(16)
                }
                .buttonStyle(.scalable)
                .padding(.top, 8)
                .padding(.bottom)
            }
        }
    }
    
    private func gradeButton(for gradeItem: (value: Double, display: String), rowColor: Color) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedGradeValue = gradeItem.value
            }
        }) {
            Text(gradeItem.display)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(selectedGradeValue == gradeItem.value ? .white : rowColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Group {
                        if selectedGradeValue == gradeItem.value {
                            rowColor
                        } else {
                            rowColor.opacity(0.12)
                        }
                    }
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(rowColor.opacity(selectedGradeValue == gradeItem.value ? 0 : 0.3), lineWidth: 1)
                )
                .scaleEffect(selectedGradeValue == gradeItem.value ? 1.05 : 1.0)
                .shadow(
                    color: selectedGradeValue == gradeItem.value ? rowColor.opacity(0.3) : .clear,
                    radius: selectedGradeValue == gradeItem.value ? 8 : 0,
                    x: 0, y: 4
                )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedGradeValue)
        .sensoryFeedback(.increase, trigger: selectedGradeValue)
    }
    
    private var gradeRows: [(Int, [(value: Double, display: String)], Color)] {
        return GradingSystemHelpers.getGradeRows(for: selectedSchoolYear.gradingSystem)
    }
    
    private func saveGrade() {
        guard let gradeValue = selectedGradeValue else { return }
        
        DataManager.createGrade(
            value: gradeValue,
            gradeType: gradeType,
            date: Date(),
            for: subject,
            schoolYear: selectedSchoolYear,
            semester: selectedSemester,
            in: modelContext
        )
        
        // Debug: Update widget after adding new grade
        updateWidget()
        
        dismissSheet()
    }
    
    /// Update widget with current data
    /// Debug: Triggers widget refresh with latest grade statistics
    private func updateWidget() {
        let allSubjects = DataManager.getAllSubjects(from: modelContext)
        WidgetHelper.updateWidget(
            with: allSubjects,
            selectedSchoolYear: selectedSchoolYear,
            selectedSemester: selectedSemester,
            from: modelContext
        )
    }
}

struct QuickGradeSubjectRowView: View {
    let subject: Subject
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    @Environment(\.modelContext) private var modelContext
    
    private var gradesForSelectedPeriod: [Grade] {
        DataManager.getGrades(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
    }
    
    private var averageGrade: Double? {
        DataManager.calculateWeightedAverage(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
    }
    
    var body: some View {
        HStack {
            Image(systemName: subject.icon)
                .foregroundColor(Color(hex: subject.colorHex))
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color(hex: subject.colorHex).opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(subject.name)
                    .font(.headline)
                Text("\(selectedSchoolYear.displayName) - \(selectedSemester.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(gradesForSelectedPeriod.count) Noten")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let average = averageGrade {
                    let hasFinalGrade = DataManager.hasFinalGrade(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
                    
                    HStack(spacing: 2) {
                        if hasFinalGrade {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(GradingSystemHelpers.gradeColor(for: average, system: selectedSchoolYear.gradingSystem))
                        } else {
                            Text("⌀")
                                .font(.caption2)
                                .foregroundColor(GradingSystemHelpers.gradeColor(for: average, system: selectedSchoolYear.gradingSystem))
                        }
                        
                        Text("\(GradingSystemHelpers.gradeDisplayText(for: average, system: selectedSchoolYear.gradingSystem))")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(GradingSystemHelpers.gradeColor(for: average, system: selectedSchoolYear.gradingSystem))
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
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
    }
}

struct QuickGradeTypeRowView: View {
    let gradeType: GradeType
    let subject: Subject
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    @Environment(\.modelContext) private var modelContext
    
    private var gradesForType: [Grade] {
        DataManager.getGrades(for: subject, gradeType: gradeType, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
    }
    
    var body: some View {
        HStack {
            Image(systemName: gradeType.icon)
                .foregroundColor(Color(hex: subject.colorHex))
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color(hex: subject.colorHex).opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(gradeType.name)
                    .font(.headline)
                Text("Gewichtung: \(gradeType.weight)%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(gradesForType.count) Noten")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
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
    }
} 