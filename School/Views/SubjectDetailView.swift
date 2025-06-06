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
    
    // Debug: Get grades for this subject in the selected period
    private var grades: [Grade] {
        DataManager.getGrades(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
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
                    
                    // Debug: Grades list
                    gradesListView
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Note hinzufügen") {
                        showingAddGrade = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .sheet(isPresented: $showingAddGrade) {
                AddGradeView(subject: subject, schoolYear: selectedSchoolYear, semester: selectedSemester)
            }
        }
    }
    
    // Debug: Subject header with icon, color, and period info
    private var subjectHeaderView: some View {
        HStack {
            Image(systemName: subject.icon)
                .font(.largeTitle)
                .foregroundColor(Color(hex: subject.colorHex))
                .frame(width: 60, height: 60)
                .background(Color(hex: subject.colorHex).opacity(0.1))
                .clipShape(Circle())
            
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
        .background(Color(.systemGray6))
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
                    color: .blue
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
    
    // Debug: List of all grades
    private var gradesListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Noten")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !grades.isEmpty {
                    Text("\(grades.count) Einträge")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if grades.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(grades, id: \.self) { grade in
                        GradeRowView(grade: grade)
                    }
                }
            }
        }
    }
    
    // Debug: Empty state when no grades exist
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.below.ecg")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("Noch keine Noten")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Füge deine erste Note für \(subject.name) hinzu")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Erste Note hinzufügen") {
                showingAddGrade = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
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
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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
                    
                    Image(systemName: grade.type.icon)
                        .foregroundColor(.secondary)
                }
                
                Text(grade.type.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let date = grade.date {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Gewichtung: \(grade.type.weight)%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.borderless)
            }
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