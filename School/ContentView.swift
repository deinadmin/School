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
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {                                           
                        // Debug: Subjects list moved out of header section
                        if allSubjects.isEmpty {
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
                                ForEach(allSubjects, id: \.name) { subject in
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
                        
                        Image("HomeImageLight")
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom, 145)
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

                        if !allSubjects.isEmpty {
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
            .navigationTitle("Fächer")
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
                    Text("⌀ \(gradeDisplayText(for: average))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(gradeColor(for: average))
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


