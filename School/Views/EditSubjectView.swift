//
//  EditSubjectView.swift
//  School
//
//  Created by Carl on 21.10.25.
//

import SwiftUI
import SwiftData

struct EditSubjectView: View {
    let subject: Subject
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var subjectName: String = ""
    @State private var selectedColorHex: String = ""
    @State private var selectedIcon: String = ""
    @FocusState private var isSubjectNameFocused: Bool
    
    // Debug: Query existing subjects to check for duplicates (excluding current subject)
    @Query(sort: \Subject.name) private var existingSubjects: [Subject]
    
    // Debug: Check if subject name already exists (case-insensitive, excluding current subject)
    private var isDuplicateName: Bool {
        let trimmedName = subjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        return existingSubjects.contains { otherSubject in
            otherSubject.persistentModelID != subject.persistentModelID &&
            otherSubject.name.lowercased() == trimmedName.lowercased()
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
    
    // Debug: Predefined icons for subjects
    private let iconOptions: [String] = [
        "book.fill", "book.closed.fill", "graduationcap.fill", "atom", "function",
        "globe", "leaf.fill", "paintbrush.fill", "music.note", "camera.fill",
        "hammer.fill", "gearshape.fill", "heart.fill", "brain.fill", "eye.fill",
        "mic.fill", "speaker.fill", "globe.europe.africa", "flag.fill", "star.fill",
        "chart.bar.fill", "figure.run", "laptopcomputer", "bubble.left.and.text.bubble.right.fill"
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
            .navigationTitle("Fach bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                // Debug: Initialize with current subject values
                subjectName = subject.name
                selectedColorHex = subject.colorHex
                selectedIcon = subject.icon
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // Debug: Subject name input
    private var subjectNameSection: some View {
        Section("Fachname") {
            TextField("z.B. Mathematik", text: $subjectName)
                .autocorrectionDisabled()
                .focused($isSubjectNameFocused)
            
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
                
                Text(subjectName.isEmpty ? "Fachname" : subjectName)
                    .font(.headline)
                    .foregroundColor(subjectName.isEmpty ? .secondary : .primary)
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    // Debug: Save changes to the subject
    private func saveChanges() {
        let trimmedName = subjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Debug: Validation
        guard !trimmedName.isEmpty else {
            print("Debug: Cannot save subject - name is empty")
            return
        }
        
        guard !isDuplicateName else {
            print("Debug: Cannot save subject - duplicate name '\(trimmedName)' already exists")
            return
        }
        
        // Debug: Update the subject
        subject.name = trimmedName
        subject.colorHex = selectedColorHex
        subject.icon = selectedIcon
        
        do {
            try modelContext.save()
            print("Debug: Successfully updated subject '\(trimmedName)'")
        } catch {
            print("Debug: Error saving subject changes: \(error)")
        }
        
        dismiss()
    }
}
