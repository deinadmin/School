//
//  AddGradeTypeView.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI

struct AddGradeTypeView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (GradeType) -> Void
    
    @State private var typeName: String = ""
    @State private var weight: Int = 10
    @State private var weightText: String = "10"
    @State private var selectedIcon: String = "doc.text.fill"
    
    // Debug: Icon options for grade types
    private let iconOptions: [String] = [
        "doc.text.fill", "questionmark.circle.fill", "mic.fill", "house.fill",
        "person.2.fill", "chart.bar.fill", "star.fill", "checkmark.circle.fill",
        "pencil", "book.fill", "trophy.fill", "target", "clipboard.fill",
        "calendar", "timer", "exclamationmark.triangle.fill"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Debug: Name section
                nameSection
                
                // Debug: Weight selection
                weightSection
                
                // Debug: Icon selection
                iconSelectionSection
                
                // Debug: Preview section
                previewSection
            }
            .navigationTitle("Notentyp hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveGradeType()
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValidInput)
                }
            }
        }
    }
    
    // Debug: Name input section
    private var nameSection: some View {
        Section("Name des Notentyps") {
            TextField("z.B. Referat, Projekt, Quiz", text: $typeName)
                .autocorrectionDisabled()
            
            Text("Gib einen aussagekräftigen Namen für diese Art der Bewertung ein")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // Debug: Weight selection section with custom percentage input
    private var weightSection: some View {
        Section("Gewichtung (in Prozent)") {
            HStack {
                Text("Gewichtung:")
                Spacer()
                TextField("z.B. 25", text: $weightText)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                    .onChange(of: weightText) { _, newValue in
                        // Debug: Update weight when text changes, validate range 1-100
                        if let value = Int(newValue), value >= 1 && value <= 100 {
                            weight = value
                        }
                    }
                Text("%")
                    .foregroundColor(.secondary)
            }
            
            // Debug: Slider for visual weight selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Verschiebe für genaue Einstellung:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(value: Binding(
                    get: { Double(weight) },
                    set: { newValue in
                        weight = Int(newValue.rounded())
                        weightText = "\(weight)"
                    }
                ), in: 10...100, step: 10)
                
                HStack {
                    Text("1%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(weight)%")
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    Text("100%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Bestimmt wie stark diese Bewertung in die Gesamtnote einfließt (1-100%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // Debug: Icon selection grid
    private var iconSelectionSection: some View {
        Section("Symbol") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button(action: {
                        selectedIcon = icon
                    }) {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(selectedIcon == icon ? .accentColor : .secondary)
                            .frame(width: 50, height: 50)
                            .background(selectedIcon == icon ? Color.accentColor.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedIcon == icon ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                            .scaleEffect(selectedIcon == icon ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3), value: selectedIcon)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // Debug: Preview section
    private var previewSection: some View {
        Section("Vorschau") {
            HStack {
                Image(systemName: selectedIcon)
                    .foregroundColor(.accentColor)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(typeName.isEmpty ? "Name des Notentyps" : typeName)
                        .font(.headline)
                        .foregroundColor(typeName.isEmpty ? .secondary : .primary)
                    
                    Text("Gewichtung: \(weight)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
                }
    }
    
    // Debug: Validation for save button
    private var isValidInput: Bool {
        let trimmedName = typeName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && weight >= 1 && weight <= 100
    }
    
    // Debug: Save the new grade type and call callback
    private func saveGradeType() {
        let trimmedName = typeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let newGradeType = GradeType(name: trimmedName, weight: weight, icon: selectedIcon)
        
        print("Debug: Created new grade type - Name: \(trimmedName), Weight: \(weight)%, Icon: \(selectedIcon)")
        
        onSave(newGradeType)
        dismiss()
    }
} 