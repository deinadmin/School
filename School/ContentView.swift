//
//  ContentView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSchoolYear: SchoolYear = SchoolYear.current
    @State private var selectedSemester: Semester = Semester.first
    @State private var showingAddSubject = false
    @State private var showingQuickGradeAdd = false
    @State private var showingSettings = false // Debug: State for settings sheet
    // Debug: App Storage for settings that affect main view
    @AppStorage("showMotivationalCharacter") private var showMotivationalCharacter = false
    @AppStorage("roundPointAverages") private var roundPointAverages = true
    // Debug: Query all subjects (subjects are independent of school year/semester)
    @Query(sort: \Subject.name) private var allSubjects: [Subject]
    
    // Debug: UserDefaults keys for persisting current selection
    private let selectedSchoolYearKey = "selectedSchoolYear"
    private let selectedSemesterKey = "selectedSemester"
    
    // Debug: Calculate overall average for speech bubble text (includes final grades)
    private var overallAverage: Double? {
        return DataManager.calculateOverallAverageWithFinalGrades(
            for: allSubjects,
            schoolYear: selectedSchoolYear,
            semester: selectedSemester,
            from: modelContext
        )
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
                        if showMotivationalCharacter {
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
                            
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 145)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {     
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                            .bold()
                    }
                }
            }
            .sheet(isPresented: $showingAddSubject) {
                AddSubjectView()
            }
            .sheet(isPresented: $showingQuickGradeAdd) {
                QuickGradeAddView(
                    selectedSchoolYear: selectedSchoolYear,
                    selectedSemester: selectedSemester
                )
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(onImportComplete: self.refreshCurrentSelection)
            }
            .onAppear {
                loadSelectedPeriod()
            }
            // Debug: Handle deep linking to open the quick add view
            .onOpenURL { url in
                print("Debug: .onOpenURL called with URL: \(url)")
                if url.scheme == "schoolapp" && url.host == "quick-add" {
                    print("Debug: URL matched. Current showingQuickGradeAdd: \(self.showingQuickGradeAdd). Attempting to set to true.")
                    
                    // Debug: To avoid state conflicts, dismiss any currently presented sheet first
                    if showingAddSubject || showingSettings {
                        print("Debug: Other sheet is showing. Dismissing it first.")
                        showingAddSubject = false
                        showingSettings = false
                        
                        // Debug: Give the dismissal animation a moment to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            print("Debug: Dispatch.asyncAfter - Setting showingQuickGradeAdd to true.")
                            showingQuickGradeAdd = true
                        }
                    } else {
                        print("Debug: No other sheet showing. Setting showingQuickGradeAdd to true directly.")
                        showingQuickGradeAdd = true
                    }
                } else {
                    print("Debug: URL did not match expected scheme/host.")
                }
            }
            .onChange(of: selectedSchoolYear) { _, newValue in
                saveSelectedSchoolYear(newValue)
                // Debug: Update widget when school year changes
                updateWidget()
            }
            .onChange(of: selectedSemester) { _, newValue in
                saveSelectedSemester(newValue)
                // Debug: Update widget when semester changes
                updateWidget()
            }
            .onAppear {
                // Debug: Update widget when view appears
                updateWidget()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Debug: Update widget when app becomes active
                updateWidget()
            }
            .onChange(of: roundPointAverages) { _, _ in
                // Debug: Update widget when rounding setting changes
                updateWidget()
            }
        }
    }
    
    // MARK: - UserDefaults Persistence Methods
    
    /// Refresh the selected school year to reflect data changes (e.g., after import)
    /// Debug: This ensures the UI updates immediately if the grading system for the current year was changed by an import.
    private func refreshCurrentSelection() {
        print("Debug: Refreshing current school year selection to reflect potential data changes.")
        let refreshedSystem = SchoolYearGradingSystemManager.getGradingSystem(forSchoolYear: selectedSchoolYear.startYear, from: modelContext) ?? selectedSchoolYear.gradingSystem
        let refreshedSchoolYear = SchoolYear(startYear: selectedSchoolYear.startYear, gradingSystem: refreshedSystem)
        
        // This assignment will trigger a UI update for views depending on selectedSchoolYear
        selectedSchoolYear = refreshedSchoolYear
    }
    
    /// Load saved school year and semester selection from UserDefaults with grading system from SwiftData
    /// Debug: Restores user's last selected period when app restarts, loading grading system from SwiftData
    private func loadSelectedPeriod() {
        // Debug: Load saved school year using UserDefaults extension, but get grading system from SwiftData
        if let savedSchoolYear = UserDefaults.standard.getStruct(forKey: selectedSchoolYearKey, as: SchoolYear.self) {
            // Debug: Load the current grading system from SwiftData instead of using saved one
            let currentGradingSystem = SchoolYearGradingSystemManager.getGradingSystem(forSchoolYear: savedSchoolYear.startYear, from: modelContext) ?? .traditional
            selectedSchoolYear = SchoolYear(startYear: savedSchoolYear.startYear, gradingSystem: currentGradingSystem)
            print("Debug: Loaded saved school year: \(selectedSchoolYear.displayName) with grading system: \(currentGradingSystem.displayName)")
        } else {
            // Debug: No saved school year, use current year with grading system from SwiftData
            let current = SchoolYear.current
            let currentGradingSystem = SchoolYearGradingSystemManager.getGradingSystem(forSchoolYear: current.startYear, from: modelContext) ?? .traditional
            selectedSchoolYear = SchoolYear(startYear: current.startYear, gradingSystem: currentGradingSystem)
            print("Debug: No saved school year found, using current: \(selectedSchoolYear.displayName) with grading system: \(currentGradingSystem.displayName)")
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
    
    /// Update widget with current data
    /// Debug: Triggers widget refresh with latest grade statistics
    private func updateWidget() {
        WidgetHelper.updateWidget(
            with: allSubjects,
            selectedSchoolYear: selectedSchoolYear,
            selectedSemester: selectedSemester,
            from: modelContext
        )
    }
}

// Debug: Statistics card showing overall performance metrics
struct StatisticsCardView: View {
    let subjects: [Subject]
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    @Environment(\.modelContext) private var modelContext
    // Debug: App Storage for rounding setting to trigger UI updates
    @AppStorage("roundPointAverages") private var roundPointAverages = true
    
    // Debug: Calculate overall statistics for the selected period (includes final grades)
    private var overallStatistics: (average: Double?, totalGrades: Int, subjectsWithGrades: Int) {
        var allGrades: [Grade] = []
        var subjectsWithGrades = 0
        
        for subject in subjects {
            let grades = DataManager.getGrades(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
            if !grades.isEmpty {
                allGrades.append(contentsOf: grades)
            }
            
            // Debug: Count subjects that have either grades or final grades
            let hasGrades = !grades.isEmpty
            let hasFinalGrade = DataManager.hasFinalGrade(for: subject, schoolYear: selectedSchoolYear, semester: selectedSemester, from: modelContext)
            if hasGrades || hasFinalGrade {
                subjectsWithGrades += 1
            }
        }
        
        // Debug: Use final grade aware calculation for overall average
        let average = DataManager.calculateOverallAverageWithFinalGrades(
            for: subjects,
            schoolYear: selectedSchoolYear,
            semester: selectedSemester,
            from: modelContext
        )
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
                Text("Schnitt")
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
        .id(roundPointAverages) // Debug: Force UI update when rounding setting changes
    }
}

// Debug: Subject row view showing grades for selected school year/semester
struct SubjectRowView: View {
    let subject: Subject
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    @Environment(\.modelContext) private var modelContext
    @State private var showingDeleteAlert = false
    // Debug: App Storage for rounding setting to trigger UI updates
    @AppStorage("roundPointAverages") private var roundPointAverages = true
    
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
                
                // Debug: Show final grade or calculated average
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
        .id(roundPointAverages) // Debug: Force UI update when rounding setting changes
    }
}

// Debug: Settings view with app info and configuration options
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var onImportComplete: () -> Void
    @State private var roundPointAverages = true
    @State private var showMotivationalCharacter = false
    @State private var showingImportAlert = false
    @State private var showingExportSheet = false
    @State private var showingDocumentPicker = false
    @State private var showingExportError = false
    @State private var showingImportError = false
    @State private var showingGradingSystemAlert = false
    @State private var exportFileURL: URL?
    @State private var importedData: String = ""
    @State private var isExporting = false
    @State private var isImporting = false
    
    // Debug: Dynamic app information from Bundle
    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? 
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "School"
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Debug: App header with icon and info
                    appHeaderView
                    
                    // Debug: Settings sections
                    settingsSection
                    
                    // Debug: CloudKit Sync section
                    cloudKitSyncSection
                    
                    // Debug: About section
                    aboutSection
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .onAppear {
                loadSettings()
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
            .shareSheet(isPresented: $showingExportSheet, 
                       items: exportFileURL != nil ? [exportFileURL!] : [],
                       onDismiss: {
                if let url = exportFileURL {
                    cleanupTemporaryFile(url)
                }
                // Debug: Reset export state when share sheet is dismissed
                isExporting = false
            })
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker { result in
                    switch result {
                    case .success(let url):
                        loadJSONFile(from: url)
                    case .failure(let error):
                        print("Debug: Document picker error: \(error)")
                        // Debug: Reset import state if document picker fails or is cancelled
                        isImporting = false
                    }
                }
            }
            .alert("Daten importieren?", isPresented: $showingImportAlert) {
                Button("Abbrechen", role: .cancel) {
                    importedData = ""
                }
                Button("Importieren", role: .destructive) {
                    importData(importedData)
                    importedData = ""
                }
            } message: {
                Text("⚠️ Achtung: Alle aktuellen Daten werden unwiderruflich überschrieben! Stellen Sie sicher, dass Sie ein Backup haben.")
            }
            .alert("Export fehlgeschlagen", isPresented: $showingExportError) {
                Button("OK") { }
            } message: {
                Text("Die Exportdatei konnte nicht erstellt werden. Bitte prüfen Sie den verfügbaren Speicherplatz und versuchen Sie es erneut.")
            }
            .alert("Import fehlgeschlagen", isPresented: $showingImportError) {
                Button("OK") { }
            } message: {
                Text("Die ausgewählte Datei konnte nicht importiert werden. Bitte stellen Sie sicher, dass es sich um eine gültige School-Backup-Datei handelt.")
            }
        }
    }
    
    // Debug: App header with icon and basic info
    private var appHeaderView: some View {
        HStack(spacing: 16) {
            // Debug: Real app icon from assets
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 8, y: 4)
            
            // Debug: App info positioned right of icon
            VStack(alignment: .leading, spacing: 6) {
                Text(appName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Version \(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Entwickelt von Carl Steen")
                    .font(.caption)
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
    
    // Debug: Settings options section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Einstellungen")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Debug: Point average rounding toggle
                settingRow(
                    icon: "number.circle.fill",
                    title: "Punkteschnitt runden",
                    subtitle: "Punkte-Durchschnitte auf ganze Zahlen runden",
                    toggle: $roundPointAverages
                )
                
                Divider()
                
                // Debug: Motivational character toggle
                settingRow(
                    icon: "person.crop.circle.fill",
                    title: "Motivierende Sprüche",
                    subtitle: "Zeigt Charakter mit motivierenden Nachrichten",
                    toggle: $showMotivationalCharacter
                )
            }
            .onChange(of: roundPointAverages) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "roundPointAverages")
                // Debug: Update widget data when setting changes to refresh display
                WidgetHelper.updateWidget(
                    with: DataManager.getAllSubjects(from: modelContext),
                    selectedSchoolYear: loadCurrentSchoolYear(),
                    selectedSemester: loadCurrentSemester(),
                    from: modelContext
                )
                print("Debug: Point average rounding setting changed to: \(newValue)")
            }
            .onChange(of: showMotivationalCharacter) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "showMotivationalCharacter")
                print("Debug: Motivational character setting changed to: \(newValue)")
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
    }
    
    // Debug: CloudKit Sync section with iCloud integration
    private var cloudKitSyncSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("iCloud Synchronisation")
                .font(.headline)
                .fontWeight(.bold)
            
            CloudKitSyncView()
        }
    }
    
    // Debug: About section with action buttons
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Verwaltung")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                // Debug: Export data button with loading state
                actionButton(
                    icon: isExporting ? nil : "square.and.arrow.up",
                    title: "Daten exportieren",
                    subtitle: "Alle Daten als JSON exportieren",
                    isLoading: isExporting
                ) {
                    exportData()
                }
                
                Divider()
                
                // Debug: Import data button with loading state
                actionButton(
                    icon: isImporting ? nil : "square.and.arrow.down",
                    title: "Daten importieren",
                    subtitle: "JSON-Datei aus Files App auswählen",
                    isLoading: isImporting
                ) {
                    showingDocumentPicker = true
                }
                
                Divider()
                
                // Debug: Support button
                actionButton(
                    icon: "questionmark.circle",
                    title: "Support",
                    subtitle: "Hilfe und Kontakt"
                ) {
                    openSupportMail()
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
    }
    
    // Debug: Reusable setting row with toggle
    private func settingRow(icon: String, title: String, subtitle: String, toggle: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: toggle)
                .labelsHidden()
        }
    }
    
    // Debug: Reusable action button row with loading state
    private func actionButton(icon: String?, title: String, subtitle: String, isLoading: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            .scaleEffect(0.8)
                    } else if let icon = icon {
                        Image(systemName: icon)
                            .foregroundColor(.accentColor)
                            .font(.title2)
                    }
                }
                .frame(width: 40, height: 40)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(isLoading ? .secondary : .primary)
                    
                    Text(isLoading ? "Bitte warten..." : subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !isLoading {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
    
    // MARK: - Settings Management
    
    /// Load settings from UserDefaults
    /// Debug: Restores user's preferences when settings view appears
    private func loadSettings() {
        roundPointAverages = UserDefaults.standard.bool(forKey: "roundPointAverages")
        showMotivationalCharacter = UserDefaults.standard.bool(forKey: "showMotivationalCharacter")
        
        // Debug: Set default values if not previously set
        if !UserDefaults.standard.hasKey("roundPointAverages") {
            roundPointAverages = true
            UserDefaults.standard.set(true, forKey: "roundPointAverages")
        }
        
        if !UserDefaults.standard.hasKey("showMotivationalCharacter") {
            showMotivationalCharacter = false
            UserDefaults.standard.set(false, forKey: "showMotivationalCharacter")
        }
        
        print("Debug: Loaded settings - Round points: \(roundPointAverages), Show character: \(showMotivationalCharacter)")
    }
    
    /// Load current school year selection from UserDefaults  
    /// Debug: Helper function for widget updates from settings
    private func loadCurrentSchoolYear() -> SchoolYear {
        if let savedSchoolYear = UserDefaults.standard.getStruct(forKey: "selectedSchoolYear", as: SchoolYear.self) {
            return savedSchoolYear
        } else {
            return SchoolYear.current
        }
    }
    
    /// Load current semester selection from UserDefaults
    /// Debug: Helper function for widget updates from settings
    private func loadCurrentSemester() -> Semester {
        if let savedSemester = UserDefaults.standard.getStruct(forKey: "selectedSemester", as: Semester.self) {
            return savedSemester
        } else {
            return .first
        }
    }
    
    // MARK: - Support Functions
    
    /// Open native mail app with support email
    /// Debug: Opens Mail app with pre-filled support email address
    private func openSupportMail() {
        let email = "support@designedbycarl.de"
        let subject = "School App Support"
        let body = ""
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let mailtoString = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let mailtoURL = URL(string: mailtoString) {
            if UIApplication.shared.canOpenURL(mailtoURL) {
                UIApplication.shared.open(mailtoURL)
                print("Debug: Opened mail app with support email")
            } else {
                print("Debug: Mail app not available")
            }
        } else {
            print("Debug: Failed to create mailto URL")
        }
    }
    
    // MARK: - Export/Import Functions
    
    /// Export all app data to JSON format with dynamic filename
    /// Debug: Exports subjects, grades, grade types with school year range in filename
    private func exportData() {
        isExporting = true
        print("Debug: Starting export...")
        
        // Debug: Add small delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let exportData = DataExporter.exportAllData(from: modelContext)
            print("Debug: Found \(exportData.subjects.count) subjects")
            
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.outputFormatting = .prettyPrinted
                
                let jsonData = try encoder.encode(exportData)
                guard let jsonString = String(data: jsonData, encoding: .utf8), !jsonString.isEmpty else {
                    print("Debug: Failed to convert JSON data to string")
                    DispatchQueue.main.async {
                        isExporting = false
                        showingExportError = true
                    }
                    return
                }
                
                let fileName = generateExportFileName(from: exportData)
                print("Debug: Generated filename: \(fileName)")
                print("Debug: JSON content length: \(jsonString.count) characters")
                
                // Debug: Create temporary file with proper name and content
                if let fileURL = createTemporaryFile(content: jsonString, fileName: fileName) {
                    DispatchQueue.main.async {
                        exportFileURL = fileURL
                        isExporting = false
                        showingExportSheet = true
                        print("Debug: Export successful, showing share sheet")
                    }
                } else {
                    print("Debug: Failed to create temporary file")
                    DispatchQueue.main.async {
                        isExporting = false
                        showingExportError = true
                    }
                }
            } catch {
                print("Debug: Export JSON encoding error: \(error)")
                DispatchQueue.main.async {
                    isExporting = false
                    showingExportError = true
                }
            }
        }
    }
    
    /// Create temporary file for sharing
    /// Debug: Creates a temporary .json file with proper content and filename
    private func createTemporaryFile(content: String, fileName: String) -> URL? {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        print("Debug: Temporary directory: \(temporaryDirectory)")
        
        let fileURL = temporaryDirectory.appendingPathComponent(fileName)
        print("Debug: Attempting to create file at: \(fileURL)")
        
        do {
            // Debug: Ensure directory exists
            try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)
            
            // Debug: Write content to file
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Debug: Verify file was created and has content
            let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? NSNumber)?.intValue ?? 0
            
            print("Debug: File created successfully at: \(fileURL)")
            print("Debug: File exists: \(fileExists), size: \(fileSize) bytes")
            
            return fileExists && fileSize > 0 ? fileURL : nil
        } catch {
            print("Debug: Error creating temporary file: \(error)")
            
            // Debug: Try fallback with simpler name
            let fallbackURL = temporaryDirectory.appendingPathComponent("School_Backup.json")
            print("Debug: Trying fallback file: \(fallbackURL)")
            
            do {
                try content.write(to: fallbackURL, atomically: true, encoding: .utf8)
                let fileExists = FileManager.default.fileExists(atPath: fallbackURL.path)
                let fileSize = (try? FileManager.default.attributesOfItem(atPath: fallbackURL.path)[.size] as? NSNumber)?.intValue ?? 0
                
                print("Debug: Fallback file created: exists=\(fileExists), size=\(fileSize)")
                return fileExists && fileSize > 0 ? fallbackURL : nil
            } catch {
                print("Debug: Fallback file creation also failed: \(error)")
                return nil
            }
        }
    }
    
    /// Clean up temporary export file
    /// Debug: Removes temporary file after sharing is complete
    private func cleanupTemporaryFile(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("Debug: Cleaned up temporary file: \(url)")
        } catch {
            print("Debug: Error cleaning up temporary file: \(error)")
        }
        exportFileURL = nil
    }
    
    /// Generate dynamic filename based on school year range in data
    /// Debug: Format: "School Backup Schuljahre 2023 - 2025.json"
    private func generateExportFileName(from exportData: ExportedData) -> String {
        var allSchoolYears: Set<Int> = []
        
        // Debug: Collect all school years from grades and final grades
        for subject in exportData.subjects {
            for grade in subject.grades {
                allSchoolYears.insert(grade.schoolYearStartYear)
            }
            for finalGrade in subject.finalGrades {
                allSchoolYears.insert(finalGrade.schoolYearStartYear)
            }
        }
        
        if allSchoolYears.isEmpty {
            // Debug: No grades exist, use current year
            let currentYear = Calendar.current.component(.year, from: Date())
            return "School_Backup_\(currentYear)_\(currentYear + 1).json"
        } else {
            // Debug: Use actual range from data
            let earliestYear = allSchoolYears.min() ?? 2024
            let latestYear = allSchoolYears.max() ?? 2024
            return "School_Backup_\(earliestYear)_\(latestYear + 1).json"
        }
    }
    
    /// Load JSON file from document picker URL
    /// Debug: Reads file content and triggers import confirmation
    private func loadJSONFile(from url: URL) {
        isImporting = true
        print("Debug: Loading JSON file from: \(url)")
        
        // Debug: Add small delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                let data = try Data(contentsOf: url)
                print("Debug: File loaded, size: \(data.count) bytes")
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Debug: JSON string length: \(jsonString.count) characters")
                    print("Debug: JSON preview: \(String(jsonString.prefix(200)))...")
                    
                    DispatchQueue.main.async {
                        importedData = jsonString
                        isImporting = false
                        showingImportAlert = true
                        print("Debug: Import confirmation alert will be shown")
                    }
                } else {
                    print("Debug: Failed to convert data to UTF-8 string")
                    DispatchQueue.main.async {
                        isImporting = false
                        showingImportError = true
                    }
                }
            } catch {
                print("Debug: Error reading file: \(error)")
                DispatchQueue.main.async {
                    isImporting = false
                    showingImportError = true
                }
            }
        }
    }
    
    /// Import JSON data and replace all current data
    /// Debug: Clears existing data and imports new data with original grading systems
    private func importData(_ jsonString: String) {
        isImporting = true
        print("Debug: Starting data import...")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Debug: Invalid JSON string")
            DispatchQueue.main.async {
                isImporting = false
                showingImportError = true
            }
            return
        }
        
        // Debug: Process import on background queue to avoid UI blocking
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let importData = try decoder.decode(ExportedData.self, from: jsonData)
                
                // Debug: Always import data and restore original grading systems
                DataImporter.importAllData(importData, to: modelContext)
                
                DispatchQueue.main.async {
                    // Debug: Restore original grading systems from backup to UserDefaults
                                            self.setGradingSystemsInSwiftData(importData.schoolYearGradingSystems)
                    
                    self.isImporting = false
                    print("Debug: Data imported successfully, original grading systems restored")
                    self.onImportComplete()
                }
            } catch {
                print("Debug: Import error: \(error)")
                
                // Debug: Try fallback decoding strategies
                do {
                    print("Debug: Trying fallback decoding with different date strategy...")
                    let fallbackDecoder = JSONDecoder()
                    fallbackDecoder.dateDecodingStrategy = .secondsSince1970
                    
                    let importData = try fallbackDecoder.decode(ExportedData.self, from: jsonData)
                    
                    // Debug: Always import data and restore original grading systems
                    DataImporter.importAllData(importData, to: modelContext)
                    
                    DispatchQueue.main.async {
                        // Debug: Restore original grading systems from backup to UserDefaults
                        self.setGradingSystemsInSwiftData(importData.schoolYearGradingSystems)
                        
                        self.isImporting = false
                        print("Debug: Data imported successfully with fallback decoder, original grading systems restored")
                        self.onImportComplete()
                    }
                } catch {
                    print("Debug: Fallback import also failed: \(error)")
                    DispatchQueue.main.async {
                        isImporting = false
                        showingImportError = true
                    }
                }
            }
        }
    }
    
    /// Set grading systems in SwiftData for all school years
    /// Debug: Updates SwiftData with grading system mappings from import data
    private func setGradingSystemsInSwiftData(_ gradingSystems: [String: String]) {
        print("Debug: Setting grading systems in SwiftData for \(gradingSystems.count) school years")
        print("Debug: Grading systems to set: \(gradingSystems)")
        
        var successCount = 0
        for (schoolYearString, gradingSystemString) in gradingSystems {
            guard let schoolYearStart = Int(schoolYearString),
                  let gradingSystem = GradingSystem(rawValue: gradingSystemString) else {
                print("Debug: Invalid school year or grading system: \(schoolYearString) -> \(gradingSystemString)")
                continue
            }
            
            SchoolYearGradingSystemManager.setGradingSystem(gradingSystem, forSchoolYear: schoolYearStart, in: modelContext)
            successCount += 1
            print("Debug: ✅ Set grading system \(gradingSystem.displayName) for school year \(schoolYearStart)/\(schoolYearStart + 1)")
        }
        
        print("Debug: Successfully set grading systems for \(successCount)/\(gradingSystems.count) school years")
        
        // Debug: Also handle school years that might not have explicit grading system info
        if gradingSystems.isEmpty {
            print("Debug: No grading systems in backup, keeping current SwiftData settings")
        }
    }
}

// MARK: - Data Export/Import Structures

/// Structure containing all exportable app data
/// Debug: JSON-serializable structure for complete data backup
struct ExportedData: Codable {
    let subjects: [ExportedSubject]
    let schoolYearGradingSystems: [String: String] // Debug: "2024" -> "traditional" or "points"
    let exportDate: Date
    let appVersion: String
    
    init(subjects: [ExportedSubject], schoolYearGradingSystems: [String: String] = [:]) {
        self.subjects = subjects
        self.schoolYearGradingSystems = schoolYearGradingSystems
        self.exportDate = Date()
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    // Debug: Custom decoding to handle older backups without grading systems
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        subjects = try container.decode([ExportedSubject].self, forKey: .subjects)
        exportDate = try container.decode(Date.self, forKey: .exportDate)
        appVersion = try container.decode(String.self, forKey: .appVersion)
        
        // Debug: Handle optional schoolYearGradingSystems for backward compatibility
        schoolYearGradingSystems = try container.decodeIfPresent([String: String].self, forKey: .schoolYearGradingSystems) ?? [:]
        
        if schoolYearGradingSystems.isEmpty {
            print("Debug: No grading systems found in backup, assuming traditional system for all years")
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case subjects, schoolYearGradingSystems, exportDate, appVersion
    }
}

/// Exported subject with all related data
/// Debug: Contains grades, grade types, and final grades for complete subject backup
struct ExportedSubject: Codable {
    let name: String
    let colorHex: String
    let icon: String
    let grades: [ExportedGrade]
    let gradeTypes: [ExportedGradeType]
    let finalGrades: [ExportedFinalGrade]
}

/// Exported grade with all properties
struct ExportedGrade: Codable {
    let value: Double
    let date: Date?
    let schoolYearStartYear: Int
    let semester: String // Debug: Store as string for easier JSON handling
    let gradeTypeName: String // Debug: Reference by name instead of ID
}

/// Exported grade type with properties
struct ExportedGradeType: Codable {
    let name: String
    let weight: Int
    let icon: String
}

/// Exported final grade
struct ExportedFinalGrade: Codable {
    let value: Double
    let schoolYearStartYear: Int
    let semester: String
}

// MARK: - Data Export Manager

/// Handles exporting of all app data to JSON
/// Debug: Converts SwiftData models to exportable structures
class DataExporter {
    static func exportAllData(from context: ModelContext) -> ExportedData {
        // Debug: Fetch all subjects with their relationships
        let descriptor = FetchDescriptor<Subject>(sortBy: [SortDescriptor(\.name)])
        let subjects = (try? context.fetch(descriptor)) ?? []
        
        // Debug: Export grading systems for all relevant school years
        var schoolYearGradingSystems: [String: String] = [:]

        // 1. Export systems for all years with an explicit setting, covering configured-but-empty years.
        let allYearsToCheck = SchoolYear.allAvailableYears(from: context)
        for schoolYear in allYearsToCheck {
            if SchoolYearGradingSystemManager.hasGradingSystemSetting(forSchoolYear: schoolYear.startYear, from: context) {
                let gradingSystem = SchoolYearGradingSystemManager.getGradingSystem(forSchoolYear: schoolYear.startYear, from: context) ?? .traditional
                schoolYearGradingSystems[String(schoolYear.startYear)] = gradingSystem.rawValue
            }
        }

        // 2. Safety net: Ensure any year with grades is included, even if outside the 'allAvailableYears' range.
        for subject in subjects {
            for grade in subject.grades ?? [] {
                let year = grade.schoolYearStartYear
                if schoolYearGradingSystems[String(year)] == nil {
                    let gradingSystem = SchoolYearGradingSystemManager.getGradingSystem(forSchoolYear: year, from: context) ?? .traditional
                    schoolYearGradingSystems[String(year)] = gradingSystem.rawValue
                    print("Debug: Exporting grading system for out-of-range year \(year) with grades: \(gradingSystem.rawValue)")
                }
            }
            for finalGrade in subject.finalGrades ?? [] {
                let year = finalGrade.schoolYearStartYear
                if schoolYearGradingSystems[String(year)] == nil {
                    let gradingSystem = SchoolYearGradingSystemManager.getGradingSystem(forSchoolYear: year, from: context) ?? .traditional
                    schoolYearGradingSystems[String(year)] = gradingSystem.rawValue
                    print("Debug: Exporting grading system for out-of-range year \(year) with final grades: \(gradingSystem.rawValue)")
                }
            }
        }
        
        let exportedSubjects = subjects.map { subject in
            ExportedSubject(
                name: subject.name,
                colorHex: subject.colorHex,
                icon: subject.icon,
                grades: (subject.grades ?? []).map { grade in
                    ExportedGrade(
                        value: grade.value,
                        date: grade.date,
                        schoolYearStartYear: grade.schoolYearStartYear,
                        semester: (grade.semester ?? .first).rawValue,
                        gradeTypeName: grade.gradeType?.name ?? "Unknown"
                    )
                },
                gradeTypes: (subject.gradeTypes ?? []).map { gradeType in
                    ExportedGradeType(
                        name: gradeType.name,
                        weight: gradeType.weight,
                        icon: gradeType.icon
                    )
                },
                finalGrades: (subject.finalGrades ?? []).map { finalGrade in
                    ExportedFinalGrade(
                        value: finalGrade.value,
                        schoolYearStartYear: finalGrade.schoolYearStartYear,
                        semester: (finalGrade.semester ?? .first).rawValue
                    )
                }
            )
        }
        
        print("Debug: Exported \(schoolYearGradingSystems.count) grading systems: \(schoolYearGradingSystems)")
        return ExportedData(subjects: exportedSubjects, schoolYearGradingSystems: schoolYearGradingSystems)
    }
}

// MARK: - Data Import Manager

/// Handles importing JSON data and recreating SwiftData models
/// Debug: Clears existing data and recreates all models with proper relationships
class DataImporter {
    static func importAllData(_ data: ExportedData, to context: ModelContext) {
        // Debug: Clear all existing data first (with user confirmation)
        clearAllData(from: context)
        
        // Debug: Import subjects and recreate relationships (grading systems are handled by importWithConversion)
        for (index, exportedSubject) in data.subjects.enumerated() {
            print("Debug: Importing subject \(index + 1)/\(data.subjects.count): '\(exportedSubject.name)'")
            print("Debug: Subject has \(exportedSubject.gradeTypes.count) grade types and \(exportedSubject.grades.count) grades")
            
            let subject = Subject(
                name: exportedSubject.name,
                colorHex: exportedSubject.colorHex,
                icon: exportedSubject.icon
            )
            context.insert(subject)
            
            // Debug: Create grade types for this subject
            var gradeTypeMap: [String: GradeType] = [:]
            for exportedGradeType in exportedSubject.gradeTypes {
                let gradeType = GradeType(
                    name: exportedGradeType.name,
                    weight: exportedGradeType.weight,
                    icon: exportedGradeType.icon,
                    subject: subject
                )
                context.insert(gradeType)
                gradeTypeMap[exportedGradeType.name] = gradeType
            }
            
            // Debug: Ensure subject has at least one grade type (create default if none exist)
            if gradeTypeMap.isEmpty {
                print("Debug: No grade types found for subject '\(exportedSubject.name)', creating default types")
                
                let defaultSchriftlich = GradeType(
                    name: "Schriftlich",
                    weight: 40,
                    icon: "pencil",
                    subject: subject
                )
                context.insert(defaultSchriftlich)
                gradeTypeMap["Schriftlich"] = defaultSchriftlich
                
                let defaultMuendlich = GradeType(
                    name: "Mündlich", 
                    weight: 60,
                    icon: "bubble.fill",
                    subject: subject
                )
                context.insert(defaultMuendlich)
                gradeTypeMap["Mündlich"] = defaultMuendlich
            }
            
            // Debug: Create grades with proper grade type relationships
            for exportedGrade in exportedSubject.grades {
                let gradeType = gradeTypeMap[exportedGrade.gradeTypeName]
                let semester = Semester(rawValue: exportedGrade.semester) ?? .first
                
                // Debug: Ensure we have a valid grade type
                guard let validGradeType = gradeType ?? gradeTypeMap.values.first else {
                    print("Debug: Warning - No grade type found for grade with type '\(exportedGrade.gradeTypeName)', skipping grade")
                    continue
                }
                
                let grade = Grade(
                    value: exportedGrade.value,
                    gradeType: validGradeType,
                    date: exportedGrade.date,
                    schoolYearStartYear: exportedGrade.schoolYearStartYear,
                    semester: semester,
                    subject: subject
                )
                context.insert(grade)
            }
            
            // Debug: Create final grades
            for exportedFinalGrade in exportedSubject.finalGrades {
                let semester = Semester(rawValue: exportedFinalGrade.semester) ?? .first
                let finalGrade = FinalGrade(
                    value: exportedFinalGrade.value,
                    schoolYearStartYear: exportedFinalGrade.schoolYearStartYear,
                    semester: semester,
                    subject: subject
                )
                context.insert(finalGrade)
            }
        }
        
        // Debug: Save all changes
        try? context.save()
    }
    
    /// Clear all existing data from the model context
    /// Debug: Removes all subjects, grades, grade types, and final grades
    private static func clearAllData(from context: ModelContext) {
        do {
            // Debug: Delete all subjects (cascade will handle grades and grade types)
            let subjectDescriptor = FetchDescriptor<Subject>()
            let subjects = try context.fetch(subjectDescriptor)
            for subject in subjects {
                context.delete(subject)
            }
            
            try context.save()
            print("Debug: Cleared all existing data")
        } catch {
            print("Debug: Error clearing data: \(error)")
        }
    }
}

// MARK: - Export/Import UI Components

/// UIActivityViewController wrapper for sharing exported data
/// Debug: Optimized share sheet for file URLs with proper handling
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let onDismiss: (() -> Void)?
    
    init(items: [Any], onDismiss: (() -> Void)? = nil) {
        self.items = items
        self.onDismiss = onDismiss
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Debug: Optimize for file sharing
        controller.setValue("School Backup", forKey: "subject")
        
        // Debug: Exclude activities that don't work well with files
        controller.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .postToWeibo,
            .postToVimeo,
            .postToFlickr,
            .postToTencentWeibo
        ]
        
        controller.completionWithItemsHandler = { activityType, completed, _, error in
            print("Debug: Share completed - Type: \(activityType?.rawValue ?? "unknown"), Success: \(completed)")
            if let error = error {
                print("Debug: Share error: \(error)")
            }
            onDismiss?()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// UIDocumentPicker wrapper for importing JSON files
/// Debug: Native Files app integration for file selection
struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (Result<URL, Error>) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Debug: Get access to security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                parent.onDocumentPicked(.failure(DocumentPickerError.accessDenied))
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            parent.onDocumentPicked(.success(url))
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onDocumentPicked(.failure(DocumentPickerError.cancelled))
        }
    }
}

/// Document picker specific errors
/// Debug: Custom error types for document picker operations
enum DocumentPickerError: Error {
    case cancelled
    case accessDenied
    case invalidFile
}

// MARK: - SwiftUI ShareSheet Modifier

extension View {
    /// SwiftUI modifier for presenting share sheet
    /// Debug: Native iOS share sheet integration
    func shareSheet(isPresented: Binding<Bool>, items: [Any], onDismiss: @escaping () -> Void = {}) -> some View {
        self.sheet(isPresented: isPresented) {
            if !items.isEmpty {
                ShareSheet(items: items, onDismiss: onDismiss)
                    .onAppear {
                        print("Debug: ShareSheet presented with \(items.count) items")
                        for (index, item) in items.enumerated() {
                            print("Debug: Item \(index): \(item)")
                        }
                    }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Keine Daten zum Teilen")
                        .font(.headline)
                    Text("Bitte versuchen Sie es erneut")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }
}

// MARK: - UserDefaults Extension

extension UserDefaults {
    /// Check if UserDefaults has a key stored
    /// Debug: Used to determine if settings have been set before
    func hasKey(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
}