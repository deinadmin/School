//
//  AddSubjectView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData

// Debug: Structure for defining grade types in subject suggestions
struct GradeTypeDefinition {
    let name: String
    let weight: Int
    let icon: String
}

// Debug: Structure for subject suggestions with colors, icons, and custom grade types
struct SubjectSuggestion {
    let name: String
    let colorHex: String
    let icon: String
    let customGradeTypes: [GradeTypeDefinition]? // Debug: If nil, use default grade types
    
    // Debug: Convenience initializer for subjects with default grade types
    init(name: String, colorHex: String, icon: String) {
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.customGradeTypes = nil
    }
    
    // Debug: Full initializer for subjects with custom grade types
    init(name: String, colorHex: String, icon: String, customGradeTypes: [GradeTypeDefinition]) {
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.customGradeTypes = customGradeTypes
    }
}

struct AddSubjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var subjectName: String = ""
    @State private var selectedColorHex: String = "4ECDC4"
    @State private var selectedIcon: String = "book.fill"
    @State private var selectedCustomGradeTypes: [GradeTypeDefinition]? = nil // Debug: Store custom grade types from suggestions
    @FocusState private var isSubjectNameFocused: Bool
    
    // Debug: Query existing subjects to check for duplicates
    @Query(sort: \Subject.name) private var existingSubjects: [Subject]
    
    // Debug: Check if subject name already exists (case-insensitive)
    private var isDuplicateName: Bool {
        let trimmedName = subjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        return existingSubjects.contains { subject in
            subject.name.lowercased() == trimmedName.lowercased()
        }
    }
    
    // Debug: Check if form is valid for saving
    private var isFormValid: Bool {
        let trimmedName = subjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && !isDuplicateName
    }
    
    // Performance: Static constants to avoid re-allocation on each view initialization
    // Debug: Predefined color palette for subjects (improved for light/dark mode visibility)
    private static let colorPalette: [String] = [
        "FF6B6B", "4ECDC4", "45B7D1", "16A085", "F39C12", 
        "8E44AD", "27AE60", "E67E22", "E74C3C", "3498DB",
        "95A5A6", "D4AF37", "E91E63", "2980B9", "00BCD4"
    ]
    
    // Debug: Predefined icons for subjects including those used in suggestions
    private static let iconOptions: [String] = [
        "book.fill", "book.closed.fill", "graduationcap.fill", "atom", "function",
        "globe", "leaf.fill", "paintbrush.fill", "music.note", "camera.fill",
        "hammer.fill", "gearshape.fill", "heart.fill", "brain.fill", "eye.fill",
        "mic.fill", "speaker.fill", "globe.europe.africa", "flag.fill", "star.fill",
        "chart.bar.fill", "figure.run", "laptopcomputer", "bubble.left.and.text.bubble.right.fill"
    ]
    
    // Debug: Subject suggestions with official German school grade weightings
    private static let subjectSuggestions: [SubjectSuggestion] = [
        // Debug: Subjects with 50/50 split
        SubjectSuggestion(name: "Deutsch", colorHex: "FF6B6B", icon: "book.closed.fill", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 50, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill")
        ]),
        SubjectSuggestion(name: "Mathematik", colorHex: "45B7D1", icon: "function", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 50, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill")
        ]),
        
        // Debug: Modern foreign languages with vocabulary tests
        SubjectSuggestion(name: "Englisch", colorHex: "D4AF37", icon: "globe.europe.africa", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 40, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill"),
            GradeTypeDefinition(name: "Vokabeltests", weight: 10, icon: "doc.text.fill")
        ]),
        SubjectSuggestion(name: "Französisch", colorHex: "8E44AD", icon: "flag.fill", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 40, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill"),
            GradeTypeDefinition(name: "Vokabeltests", weight: 10, icon: "doc.text.fill")
        ]),
        SubjectSuggestion(name: "Spanisch", colorHex: "E67E22", icon: "flag.fill", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 40, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill"),
            GradeTypeDefinition(name: "Vokabeltests", weight: 10, icon: "doc.text.fill")
        ]),
        
        // Debug: Latin with special focus on translations
        SubjectSuggestion(name: "Latein", colorHex: "D4AF37", icon: "book.closed.fill", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 50, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 40, icon: "bubble.fill"),
            GradeTypeDefinition(name: "Vokabeltests", weight: 10, icon: "doc.text.fill")
        ]),
        
        // Debug: Sciences with practical components
        SubjectSuggestion(name: "Chemie", colorHex: "16A085", icon: "atom", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 40, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill"),
            GradeTypeDefinition(name: "Praktisch", weight: 10, icon: "testtube.2")
        ]),
        SubjectSuggestion(name: "Physik", colorHex: "3498DB", icon: "atom", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 40, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill"),
            GradeTypeDefinition(name: "Praktisch", weight: 10, icon: "testtube.2")
        ]),
        
        // Debug: Creative subjects with practical focus
        SubjectSuggestion(name: "Kunst", colorHex: "E74C3C", icon: "paintbrush.fill", customGradeTypes: [
            GradeTypeDefinition(name: "Praktisch", weight: 70, icon: "paintbrush.fill"),
            GradeTypeDefinition(name: "Sonstige", weight: 30, icon: "bubble.fill")
        ]),
        SubjectSuggestion(name: "Musik", colorHex: "8E44AD", icon: "music.note", customGradeTypes: [
            GradeTypeDefinition(name: "Praktisch", weight: 60, icon: "music.note"),
            GradeTypeDefinition(name: "Schriftlich", weight: 20, icon: "pencil"),
            GradeTypeDefinition(name: "Sonstige", weight: 20, icon: "bubble.fill")
        ]),
        
        // Debug: Sport with heavy practical focus
        SubjectSuggestion(name: "Sport", colorHex: "E74C3C", icon: "figure.run", customGradeTypes: [
            GradeTypeDefinition(name: "Praktisch", weight: 80, icon: "figure.run"),
            GradeTypeDefinition(name: "Sonstige", weight: 20, icon: "bubble.fill")
        ]),
        
        // Debug: Computer science with balanced approach
        SubjectSuggestion(name: "Informatik", colorHex: "2980B9", icon: "laptopcomputer", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 30, icon: "pencil"),
            GradeTypeDefinition(name: "Praktisch", weight: 40, icon: "laptopcomputer"),
            GradeTypeDefinition(name: "Mündlich", weight: 30, icon: "bubble.fill")
        ]),
        
        // Debug: Philosophy/Religion with high oral component
        SubjectSuggestion(name: "Religion", colorHex: "E91E63", icon: "heart.fill", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 30, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 70, icon: "bubble.fill")
        ]),
        SubjectSuggestion(name: "Philosophie", colorHex: "8E44AD", icon: "brain.fill", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 30, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 70, icon: "bubble.fill")
        ]),
        
        // Debug: Subjects using default weightings (Schriftlich 40%, Mündlich 60%)
        SubjectSuggestion(name: "Biologie", colorHex: "27AE60", icon: "leaf.fill"),
        SubjectSuggestion(name: "Geschichte", colorHex: "D4AF37", icon: "book.fill"),
        SubjectSuggestion(name: "Erdkunde", colorHex: "00BCD4", icon: "globe.europe.africa"),
        SubjectSuggestion(name: "Geographie", colorHex: "00BCD4", icon: "globe.europe.africa"), // Debug: Alternative name
        SubjectSuggestion(name: "Politik", colorHex: "2980B9", icon: "flag.fill"),
        SubjectSuggestion(name: "Wirtschaft", colorHex: "F39C12", icon: "chart.bar.fill"),
        SubjectSuggestion(name: "WiPo", colorHex: "2980B9", icon: "chart.bar.fill"),
        SubjectSuggestion(name: "Ethik", colorHex: "95A5A6", icon: "brain.fill")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Debug: Subject name section
                subjectNameSection
                
                // Debug: Color selection
                colorSelectionSection
                
                // Debug: Icon selection
                iconSelectionSection
                
                // Debug: Preview section
                previewSection
            }
            .navigationTitle("Fach hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveSubject()
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
            }
            .task {
                // Debug: Instantly focus the subject name field when view loads
                isSubjectNameFocused = true
            }
        }
    }
    
    // Debug: Subject name input with enhanced suggestions including colors and icons
    private var subjectNameSection: some View {
        Section("Fachname") {
            TextField("z.B. Mathematik", text: $subjectName)
                .autocorrectionDisabled()
                .focused($isSubjectNameFocused)
                .onChange(of: subjectName) { _, newValue in
                    // Debug: Reset custom grade types when user manually types (unless it matches a suggestion exactly)
                    if !Self.subjectSuggestions.contains(where: { $0.name == newValue }) {
                        selectedCustomGradeTypes = nil
                    }
                }
            
            // Debug: Show error message if duplicate name exists
            if isDuplicateName {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Dieses Fach existiert bereits")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.top, 4)
            }
            
            if !subjectName.isEmpty && !isDuplicateName {
                // Debug: Filter suggestions based on current input and exclude already existing subjects
                let filteredSuggestions = Self.subjectSuggestions.filter { suggestion in
                    // Debug: Check if suggestion matches input and doesn't already exist
                    let matchesInput = suggestion.name.localizedCaseInsensitiveContains(subjectName) && suggestion.name != subjectName
                    let doesNotExist = !existingSubjects.contains { existingSubject in
                        existingSubject.name.lowercased() == suggestion.name.lowercased()
                    }
                    return matchesInput && doesNotExist
                }
                
                if !filteredSuggestions.isEmpty {
                    ForEach(filteredSuggestions.prefix(3), id: \.name) { suggestion in
                        Button(action: {
                            applySuggestion(suggestion)
                        }) {
                            HStack {
                                // Debug: Show suggestion icon with color preview
                                Image(systemName: suggestion.icon)
                                    .font(.title3)
                                    .foregroundColor(Color(hex: suggestion.colorHex))
                                    .frame(width: 40, height: 40)
                                    .background(Color(hex: suggestion.colorHex).opacity(0.2))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.name)
                                        .foregroundColor(.primary)
                                        .fontWeight(.medium)
                                    Text("Tippe zum Wählen")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("Vorschlag")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // Debug: Apply suggestion with color, icon, and custom grade types
    private func applySuggestion(_ suggestion: SubjectSuggestion) {
        withAnimation(.easeInOut(duration: 0.3)) {
            subjectName = suggestion.name
            selectedColorHex = suggestion.colorHex
            selectedIcon = suggestion.icon
            selectedCustomGradeTypes = suggestion.customGradeTypes
        }
    }
    
    // Debug: Color palette selection
    private var colorSelectionSection: some View {
        Section("Farbe") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(Self.colorPalette, id: \.self) { colorHex in
                    Button(action: {
                        selectedColorHex = colorHex
                    }) {
                        Circle()
                            .fill(Color(hex: colorHex))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(selectedColorHex == colorHex ? Color.primary : Color.clear, lineWidth: 3)
                            )
                            .scaleEffect(selectedColorHex == colorHex ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedColorHex)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // Debug: Icon selection grid
    private var iconSelectionSection: some View {
        Section("Symbol") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(Self.iconOptions, id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                    }) {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(selectedIcon == icon ? Color(hex: selectedColorHex) : .secondary)
                            .frame(width: 40, height: 40)
                            .background(selectedIcon == icon ? Color(hex: selectedColorHex).opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .scaleEffect(selectedIcon == icon ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedIcon)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // Debug: Preview of the subject appearance with detailed grade type weightings
    private var previewSection: some View {
        Section("Vorschau") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: selectedIcon)
                        .font(.title2)
                        .foregroundColor(Color(hex: selectedColorHex))
                        .frame(width: 40, height: 40)
                        .background(Color(hex: selectedColorHex).opacity(0.2))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(subjectName.isEmpty ? "Fachname" : subjectName)
                            .font(.headline)
                            .foregroundColor(subjectName.isEmpty ? .secondary : .primary)
                        
                        Text("Notentypen:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Debug: Show detailed grade types with individual weightings
                if let customGradeTypes = selectedCustomGradeTypes {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(customGradeTypes, id: \.name) { gradeType in
                            HStack {
                                Image(systemName: gradeType.icon)
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                    .frame(width: 20)
                                
                                Text(gradeType.name)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Text("\(gradeType.weight)%")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(6)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .frame(width: 20)
                            
                            Text("Schriftlich")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("40%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "bubble.fill")
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .frame(width: 20)
                            
                            Text("Mündlich")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("60%")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(6)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // Debug: Save the new subject with duplicate validation
    private func saveSubject() {
        let trimmedName = subjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Debug: Additional validation before saving
        guard !trimmedName.isEmpty else {
            debugLog(" Cannot save subject - name is empty")
            return
        }
        
        guard !isDuplicateName else {
            debugLog(" Cannot save subject - duplicate name '\(trimmedName)' already exists")
            return
        }
        
        // Debug: Convert custom grade types if available
        let customGradeTypes: [(name: String, weight: Int, icon: String)]? = selectedCustomGradeTypes?.map { gradeType in
            (name: gradeType.name, weight: gradeType.weight, icon: gradeType.icon)
        }
        
        let typeDescription = customGradeTypes != nil ? "with custom grade types" : "with default grade types"
        debugLog(" Creating new subject '\(trimmedName)' \(typeDescription)")
        
        DataManager.createSubject(
            name: trimmedName,
            colorHex: selectedColorHex,
            icon: selectedIcon,
            customGradeTypes: customGradeTypes,
            in: modelContext
        )
        
        // Debug: Show success toast
        ToastManager.shared.success("„\(trimmedName)“ erstellt", icon: "plus.circle.fill", iconColor: Color(hex: selectedColorHex))
        
        dismiss()
    }
}
