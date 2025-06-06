//
//  AddSubjectView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData

// Debug: Structure for subject suggestions with colors and icons
struct SubjectSuggestion {
    let name: String
    let colorHex: String
    let icon: String
}

struct AddSubjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var subjectName: String = ""
    @State private var selectedColorHex: String = "4ECDC4"
    @State private var selectedIcon: String = "book"
    
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
    
    // Debug: Predefined color palette for subjects (improved for light/dark mode visibility)
    private let colorPalette: [String] = [
        "FF6B6B", "4ECDC4", "45B7D1", "16A085", "F39C12", 
        "8E44AD", "27AE60", "E67E22", "E74C3C", "3498DB",
        "95A5A6", "D4AF37", "E91E63", "2980B9", "00BCD4"
    ]
    
    // Debug: Predefined icons for subjects including those used in suggestions
    private let iconOptions: [String] = [
        "book.fill", "book.closed.fill", "graduationcap.fill", "atom", "function",
        "globe", "leaf.fill", "paintbrush.fill", "music.note", "camera.fill",
        "hammer.fill", "gearshape.fill", "heart.fill", "brain.fill", "eye.fill",
        "mic.fill", "speaker.fill", "globe.europe.africa", "flag.fill", "star.fill",
        "chart.bar.fill", "figure.run", "laptopcomputer", "bubble.left.and.text.bubble.right.fill"
    ]
    
    // Debug: Subject suggestions with improved colors for better visibility in both light and dark modes
    private let subjectSuggestions: [SubjectSuggestion] = [
        SubjectSuggestion(name: "Mathematik", colorHex: "45B7D1", icon: "function"),
        SubjectSuggestion(name: "Deutsch", colorHex: "FF6B6B", icon: "book.closed.fill"),
        SubjectSuggestion(name: "Englisch", colorHex: "D4AF37", icon: "globe.europe.africa"),
        SubjectSuggestion(name: "Französisch", colorHex: "8E44AD", icon: "flag.fill"),
        SubjectSuggestion(name: "Spanisch", colorHex: "E67E22", icon: "flag.fill"),
        SubjectSuggestion(name: "Physik", colorHex: "3498DB", icon: "atom"),
        SubjectSuggestion(name: "Chemie", colorHex: "16A085", icon: "atom"),
        SubjectSuggestion(name: "Biologie", colorHex: "27AE60", icon: "leaf.fill"),
        SubjectSuggestion(name: "Geschichte", colorHex: "D4AF37", icon: "book.fill"),
        SubjectSuggestion(name: "Erdkunde", colorHex: "00BCD4", icon: "globe.europe.africa"),
        SubjectSuggestion(name: "Politik", colorHex: "2980B9", icon: "flag.fill"),
        SubjectSuggestion(name: "Wirtschaft", colorHex: "F39C12", icon: "chart.bar.fill"),
        SubjectSuggestion(name: "WiPo", colorHex: "2980B9", icon: "chart.bar.fill"),
        SubjectSuggestion(name: "Religion", colorHex: "E91E63", icon: "heart.fill"),
        SubjectSuggestion(name: "Ethik", colorHex: "95A5A6", icon: "brain.fill"),
        SubjectSuggestion(name: "Philosophie", colorHex: "8E44AD", icon: "brain.fill"),
        SubjectSuggestion(name: "Kunst", colorHex: "E74C3C", icon: "paintbrush.fill"),
        SubjectSuggestion(name: "Musik", colorHex: "8E44AD", icon: "music.note"),
        SubjectSuggestion(name: "Sport", colorHex: "E74C3C", icon: "figure.run"),
        SubjectSuggestion(name: "Informatik", colorHex: "2980B9", icon: "laptopcomputer"),
        SubjectSuggestion(name: "Latein", colorHex: "D4AF37", icon: "book.closed.fill")
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
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // Debug: Subject name input with enhanced suggestions including colors and icons
    private var subjectNameSection: some View {
        Section("Fachname") {
            TextField("z.B. Mathematik", text: $subjectName)
                .autocorrectionDisabled()
            
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
                let filteredSuggestions = subjectSuggestions.filter { suggestion in
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
    
    // Debug: Apply suggestion with color and icon
    private func applySuggestion(_ suggestion: SubjectSuggestion) {
        withAnimation(.easeInOut(duration: 0.3)) {
            subjectName = suggestion.name
            selectedColorHex = suggestion.colorHex
            selectedIcon = suggestion.icon
        }
    }
    
    // Debug: Color palette selection
    private var colorSelectionSection: some View {
        Section("Farbe") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                ForEach(colorPalette, id: \.self) { colorHex in
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
                ForEach(iconOptions, id: \.self) { icon in
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
    
    // Debug: Preview of the subject appearance
    private var previewSection: some View {
        Section("Vorschau") {
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
                    
                    Text("So wird dein Fach angezeigt")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    // Debug: Save the new subject with duplicate validation
    private func saveSubject() {
        let trimmedName = subjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Debug: Additional validation before saving
        guard !trimmedName.isEmpty else {
            print("Debug: Cannot save subject - name is empty")
            return
        }
        
        guard !isDuplicateName else {
            print("Debug: Cannot save subject - duplicate name '\(trimmedName)' already exists")
            return
        }
        
        print("Debug: Creating new subject '\(trimmedName)' with color '\(selectedColorHex)' and icon '\(selectedIcon)'")
        
        DataManager.createSubject(
            name: trimmedName,
            colorHex: selectedColorHex,
            icon: selectedIcon,
            in: modelContext
        )
        
        dismiss()
    }
} 