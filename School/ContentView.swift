//
//  ContentView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSchoolYear: SchoolYear = SchoolYear.current
    @State private var selectedSemester: Semester = Semester.first
    @State private var showingAddSubject = false
    @State private var showingQuickGradeAdd = false
    // Debug: Query all subjects (subjects are independent of school year/semester)
    @Query(sort: \Subject.name) private var allSubjects: [Subject]
    
    // Debug: UserDefaults keys for persisting current selection
    private let selectedSchoolYearKey = "selectedSchoolYear"
    private let selectedSemesterKey = "selectedSemester"
    
    // Debug: Calculate overall average for speech bubble text
    private var overallAverage: Double? {
        var allGrades: [Grade] = []
        
        for subject in allSubjects {
            let grades = DataManager.getGrades(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
            if !grades.isEmpty {
                allGrades.append(contentsOf: grades)
            }
        }
        
        return DataManager.calculateOverallWeightedAverage(from: allGrades)
    }
    
    // Debug: Dynamic speech bubble text based on overall performance
    private var speechBubbleText: String {
        return GradingSystemHelpers.getPerformanceMessage(for: overallAverage, system: selectedSchoolYear.gradingSystem)
    }
    
    // Debug: Subjects sorted by average grade (best grades first)
    private var sortedSubjects: [Subject] {
        return allSubjects.sorted { subject1, subject2 in
            let average1 = DataManager.calculateWeightedAverage(for: subject1, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
            let average2 = DataManager.calculateWeightedAverage(for: subject2, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
            
            // Debug: Handle subjects without grades (put them at the end)
            switch (average1, average2) {
            case (nil, nil):
                // Debug: Both have no grades, sort alphabetically
                return subject1.name < subject2.name
            case (nil, _):
                // Debug: subject1 has no grades, put it after subject2
                return false
            case (_, nil):
                // Debug: subject2 has no grades, put subject1 before it
                return true
            case (let avg1?, let avg2?):
                // Debug: Both have grades, sort by grade quality
                switch selectedSchoolYear.gradingSystem {
                case .traditional:
                    // Debug: Traditional system (1-6): lower numbers are better
                    return avg1 < avg2
                case .points:
                    // Debug: Points system (0-15): higher numbers are better
                    return avg1 > avg2
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Debug: Statistics card at the top
                        if !sortedSubjects.isEmpty {
                            StatisticsCardView(
                                subjects: sortedSubjects,
                                selectedSchoolYear: selectedSchoolYear,
                                selectedSemester: selectedSemester
                            )
                        }
                        
                        // Debug: Subjects list moved out of header section
                        if sortedSubjects.isEmpty {
                            VStack(spacing: 16) {
                                // Debug: Icon for empty state
                                Image(systemName: "book.closed")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                
                                VStack(spacing: 8) {
                                    Text("Keine Fächer vorhanden")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.primary)
                                    
                                    Text("Erstelle dein erstes Fach, indem du unten auf den Button tippst.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
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
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(sortedSubjects, id: \.persistentModelID) { subject in
                                    NavigationLink(destination: SubjectDetailView(
                                        subject: subject,
                                        selectedSchoolYear: selectedSchoolYear,
                                        selectedSemester: selectedSemester
                                    )) {
                                        SubjectRowView(
                                            subject: subject,
                                            selectedSchoolYear: selectedSchoolYear,
                                            selectedSemester: selectedSemester
                                        )
                                    }
                                    .buttonStyle(.plain) // Debug: Remove default button styling for custom appearance
                                }
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 16) {
                            // Debug: Speech bubble positioned at character's mouth height
                            VStack {
                                Spacer()
                                    .frame(height: 40) // Debug: Position bubble at mouth height (roughly 1/3 from top)
                                
                                Text(speechBubbleText)
                                    .font(.title3)
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(.systemGray5), lineWidth: 1)
                                    )
                                
                                Spacer()
                            }

                            Image("StudentCharacter")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                            
                        }
                        .padding(.bottom, 60)
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading) {
                    Spacer()
                    CardBasedSchoolPicker(selectedSchoolYear: $selectedSchoolYear, selectedSemester: $selectedSemester)
                    HStack {
                        Button(action: {
                            showingAddSubject = true
                        }, label: {
                            HStack {
                                Spacer()
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .bold()
                                Text("Fach")
                                    .foregroundColor(.white)
                                    .bold()
                                    Spacer()
                            }
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(16)
                        })
                        .buttonStyle(.scalable)

                        if !sortedSubjects.isEmpty {
                            Button(action: {
                                showingQuickGradeAdd = true
                            }, label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                        .bold()
                                    Text("Note")
                                        .foregroundColor(.white)
                                        .bold()
                                    Spacer()
                                }
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(16)
                            })
                            .buttonStyle(.scalable)
                        }
                    }
                }
                .padding(.horizontal)

            }
            .navigationTitle("School")
            .sheet(isPresented: $showingAddSubject) {
                AddSubjectView()
            }
            .sheet(isPresented: $showingQuickGradeAdd) {
                QuickGradeAddView(
                    selectedSchoolYear: selectedSchoolYear,
                    selectedSemester: selectedSemester
                )
            }
            .onAppear {
                loadSelectedPeriod()
            }
            .onChange(of: selectedSchoolYear) { _, newValue in
                saveSelectedSchoolYear(newValue)
            }
            .onChange(of: selectedSemester) { _, newValue in
                saveSelectedSemester(newValue)
            }
        }
    }
    
    // MARK: - UserDefaults Persistence Methods
    
    /// Load saved school year and semester selection from UserDefaults
    /// Debug: Restores user's last selected period when app restarts
    private func loadSelectedPeriod() {
        // Debug: Load saved school year using UserDefaults extension
        if let savedSchoolYear = UserDefaults.standard.getStruct(forKey: selectedSchoolYearKey, as: SchoolYear.self) {
            selectedSchoolYear = savedSchoolYear
            print("Debug: Loaded saved school year: \(savedSchoolYear.displayName)")
        } else {
            print("Debug: No saved school year found, using current: \(selectedSchoolYear.displayName)")
        }
        
        // Debug: Load saved semester using UserDefaults extension
        if let savedSemester = UserDefaults.standard.getStruct(forKey: selectedSemesterKey, as: Semester.self) {
            selectedSemester = savedSemester
            print("Debug: Loaded saved semester: \(savedSemester.displayName)")
        } else {
            print("Debug: No saved semester found, using default: \(selectedSemester.displayName)")
        }
    }
    
    /// Save selected school year to UserDefaults
    /// Debug: Persists school year selection across app restarts
    private func saveSelectedSchoolYear(_ schoolYear: SchoolYear) {
        UserDefaults.standard.setStruct(schoolYear, forKey: selectedSchoolYearKey)
        print("Debug: Saved school year selection: \(schoolYear.displayName)")
    }
    
    /// Save selected semester to UserDefaults
    /// Debug: Persists semester selection across app restarts
    private func saveSelectedSemester(_ semester: Semester) {
        UserDefaults.standard.setStruct(semester, forKey: selectedSemesterKey)
        print("Debug: Saved semester selection: \(semester.displayName)")
    }
}

// Debug: Statistics card showing overall performance metrics
struct StatisticsCardView: View {
    let subjects: [Subject]
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    @Environment(\.modelContext) private var modelContext
    
    // Debug: Calculate overall statistics for the selected period
    private var overallStatistics: (average: Double?, totalGrades: Int, subjectsWithGrades: Int) {
        var allGrades: [Grade] = []
        var subjectsWithGrades = 0
        
        for subject in subjects {
            let grades = DataManager.getGrades(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
            if !grades.isEmpty {
                allGrades.append(contentsOf: grades)
                subjectsWithGrades += 1
            }
        }
        
        let average = DataManager.calculateOverallWeightedAverage(from: allGrades)
        return (average, allGrades.count, subjectsWithGrades)
    }
    
    var body: some View {
        HStack {
            // Debug: Statistics icon
            Image(systemName: "chart.bar.fill")
                .foregroundColor(.accentColor)
                .font(.title)
                .frame(width: 60, height: 60)
                .background(Color.accentColor.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text("Zeugnisschnitt")
                    .font(.title2)
                    .bold()
                Text("\(selectedSchoolYear.displayName) - \(selectedSemester.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Debug: Overall average
                if let average = overallStatistics.average {
                    Text("⌀ \(GradingSystemHelpers.gradeDisplayText(for: average, system: selectedSchoolYear.gradingSystem))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(GradingSystemHelpers.gradeColor(for: average, system: selectedSchoolYear.gradingSystem))
                } else {
                    Text("Keine Noten")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    // Debug: Number of subjects with grades
                    if overallStatistics.subjectsWithGrades > 0 {
                        Text("\(overallStatistics.subjectsWithGrades) Fächer")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Debug: Total grades count
                    if overallStatistics.totalGrades > 0 {
                        Text("\(overallStatistics.totalGrades) Noten")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
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

// Debug: Subject row view showing grades for selected school year/semester
struct SubjectRowView: View {
    let subject: Subject
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteAlert = false
    
    // Debug: Get grades for this subject in the selected period
    private var gradesForSelectedPeriod: [Grade] {
        DataManager.getGrades(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
    }
    
    // Debug: Calculate average for selected period
    private var averageGrade: Double? {
        DataManager.calculateWeightedAverage(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
    }
    
    var body: some View {
        HStack {
            // Debug: Subject icon and color
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
                // Debug: Show grade count for selected period
                Text("\(gradesForSelectedPeriod.count) Noten")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Debug: Show average if available
                if let average = averageGrade {
                    Text("⌀ \(GradingSystemHelpers.gradeDisplayText(for: average, system: selectedSchoolYear.gradingSystem))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(GradingSystemHelpers.gradeColor(for: average, system: selectedSchoolYear.gradingSystem))
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
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Fach löschen", systemImage: "trash")
            }
        }
        .alert("Fach löschen?", isPresented: $showingDeleteAlert) {
            Button("Löschen", role: .destructive) {
                DataManager.deleteSubject(subject, from: modelContext)
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Das Fach \"\(subject.name)\" und alle zugehörigen Noten werden dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
}


