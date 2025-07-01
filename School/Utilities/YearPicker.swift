import SwiftUI
import Foundation
import SwiftData

struct CardBasedSchoolPicker: View {
    @Binding var selectedSchoolYear: SchoolYear
    @Binding var selectedSemester: Semester
    @State private var isExpanded = false
    @State private var showingGradingSystemAlert = false
    @State private var pendingGradingSystem: GradingSystem?
    @State private var gradingSystemError: String?
    
    // Debug: Need ModelContext for grading system validation
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(spacing: 0) {
            // Collapsed View
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [Color.accentColor.opacity(0.2), Color.accentColor.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "calendar.badge.clock")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(selectedSchoolYear.displayName)")
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(selectedSemester.displayName) • \(selectedSchoolYear.gradingSystem.displayName)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Chevron
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading) // Debug: Make entire card area tappable
                .contentShape(Rectangle()) // Debug: Ensure entire button area is tappable
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded View
            if isExpanded {
                VStack(spacing: 16) {
                    Divider()
                        .padding(.horizontal)
                    
                    // Year Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Schuljahr")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(SchoolYear.allAvailableYears(from: modelContext), id: \.startYear) { year in
                                        YearChip(
                                            year: year,
                                            isSelected: selectedSchoolYear.startYear == year.startYear,
                                            action: { 
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    selectedSchoolYear = year
                                                }
                                            }
                                        )
                                        .id(year.startYear)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo(selectedSchoolYear.startYear, anchor: .center)
                                }
                            }
                            .onChange(of: isExpanded) { _, newValue in
                                if newValue {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo(selectedSchoolYear.startYear, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Grading System Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bewertungssystem")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ForEach(GradingSystem.allCases, id: \.rawValue) { system in
                                GradingSystemCard(
                                    system: system,
                                    isSelected: selectedSchoolYear.gradingSystem == system,
                                    action: {
                                        changeGradingSystem(to: system)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // No conversion info text needed anymore
                    }
                    
                    // Semester Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Halbjahr")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ForEach(Semester.allCases) { semester in
                                SemesterCard(
                                    semester: semester,
                                    isSelected: selectedSemester == semester,
                                    action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedSemester = semester
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    
                }
                .blur(radius: isExpanded ? 0 : 40)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .alert("Bewertungssystem ändern?", isPresented: $showingGradingSystemAlert) {
            Button("Konvertieren", role: .none) {
                if let newSystem = pendingGradingSystem {
                    applyGradingSystemChange(to: newSystem)
                }
            }
            Button("Abbrechen", role: .cancel) {
                pendingGradingSystem = nil
                gradingSystemError = nil
            }
        } message: {
            if let errorMessage = gradingSystemError {
                Text(errorMessage)
            } else if let newSystem = pendingGradingSystem {
                let gradeCount = DataManager.getGradeCount(for: selectedSchoolYear, from: modelContext)
                Text("Durch die Änderung werden \(gradeCount) Noten zu \(newSystem.displayName) konvertiert.")
            }
        }
    }
    
    // Debug: Handle grading system change with conversion
    private func changeGradingSystem(to newSystem: GradingSystem) {
        // Debug: Don't do anything if already selected
        guard selectedSchoolYear.gradingSystem != newSystem else { return }
        
        // Debug: Check if there are grades to convert
        let gradeCount = DataManager.getGradeCount(for: selectedSchoolYear, from: modelContext)
        
        if gradeCount == 0 {
            // Debug: No grades exist, change immediately without alert
            applyGradingSystemChange(to: newSystem)
        } else {
            // Debug: Grades exist, show conversion confirmation
            pendingGradingSystem = newSystem
            gradingSystemError = nil
            showingGradingSystemAlert = true
        }
    }
    
    // Debug: Apply the grading system change with grade conversion
    private func applyGradingSystemChange(to newSystem: GradingSystem) {
        // Debug: Perform grade conversion if there are existing grades
        let gradeCount = DataManager.getGradeCount(for: selectedSchoolYear, from: modelContext)
        
        if gradeCount > 0 {
            let conversionResult = DataManager.convertGradingSystem(for: selectedSchoolYear, to: newSystem, from: modelContext)
            
            if !conversionResult.success {
                gradingSystemError = conversionResult.errorMessage
                showingGradingSystemAlert = true
                return
            }
            
            print("Debug: Successfully converted \(conversionResult.convertedCount) grades to \(newSystem.displayName)")
        }
        
        // Debug: Save the grading system change to SwiftData instead of UserDefaults
        SchoolYearGradingSystemManager.setGradingSystem(newSystem, forSchoolYear: selectedSchoolYear.startYear, in: modelContext)
        
        // Debug: Update the selected school year with the new system
        let updatedSchoolYear = SchoolYear(startYear: selectedSchoolYear.startYear, gradingSystem: newSystem)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedSchoolYear = updatedSchoolYear
        }
        
        pendingGradingSystem = nil
        gradingSystemError = nil
        
        print("Debug: Changed grading system for \(selectedSchoolYear.displayName) to \(newSystem.displayName)")
    }
}

struct YearChip: View {
    let year: SchoolYear
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(year.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)

            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .overlay(
                Capsule()
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.scalable)
    }
}

struct GradingSystemCard: View {
    let system: GradingSystem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: system == .traditional ? "1.circle.fill" : "15.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : .blue)
                
                VStack(spacing: 2) {
                    Text(system.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(system == .traditional ? "1+ bis 6" : "0 bis 15")
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ?
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color(.systemGray6), Color(.systemGray6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.scalable)
    }
}

struct SemesterCard: View {
    let semester: Semester
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: semester == .first ? "1.circle.fill" : "2.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(semester.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ?
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color(.systemGray6), Color(.systemGray6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(.scalable)
    }
}
