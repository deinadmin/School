//
//  OnboardingView.swift
//  School
//
//  Created by Carl on 13.01.26.
//

import SwiftUI
import SwiftData
import UIKit

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    
    @State private var currentStep = 0
    @State private var selectedGradingSystem: GradingSystem = .traditional
    
    // Subject creation state
    @State private var subjectName = ""
    @State private var selectedColorHex = "4ECDC4"
    @State private var selectedIcon = "book.fill"
    @State private var selectedCustomGradeTypes: [GradeTypeDefinition]? = nil
    
    // Animation states for staggered fade-up
    @State private var showContent = false
    
    let onComplete: () -> Void
    
    private let totalSteps = 4
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    themeManager.accentColor.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content
                TabView(selection: $currentStep) {
                    welcomeStep
                        .tag(0)
                        .ignoresSafeArea()
                    
                    featuresStep
                        .tag(1)
                        .ignoresSafeArea()
                    
                    gradingSystemStep
                        .tag(2)
                        .ignoresSafeArea()
                    
                    firstSubjectStep
                        .tag(3)
                        .ignoresSafeArea()
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            
            // Floating progress indicator at top
            VStack {
                floatingProgressIndicator
                Spacer()
            }
            
            // Floating bottom navigation
            VStack {
                Spacer()
                floatingBottomNavigation
            }
        }
        .onChange(of: currentStep) { _, _ in
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Reset and trigger animations when step changes
            withAnimation(.linear(duration: 0)) {
                showContent = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showContent = true
                }
            }
        }
        .onAppear {
            // Initial animation trigger
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showContent = true
                }
            }
        }
    }
    
    // MARK: - Floating Progress Indicator
    private var floatingProgressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? themeManager.accentColor : Color(.systemGray4))
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 16)
        .glassEffect(.regular.interactive(), in: Capsule())
        .padding(.top, 16)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Floating Bottom Navigation
    private var floatingBottomNavigation: some View {
        HStack(spacing: 12) {
            // Back button (hidden on first step)
            if currentStep > 0 {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep -= 1
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                        Text("Zurück")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
                .glassEffect(.regular.interactive().tint(Color(.systemGray).opacity(0.6)), in: Capsule())
            }
            
            Spacer()
            
            // Next/Complete button - Liquid glass style
            Button(action: {
                handleNextAction()
            }) {
                HStack(spacing: 6) {
                    Text(currentStep == totalSteps - 1 ? "Los geht's" : "Weiter")
                        .fontWeight(.semibold)
                    Image(systemName: currentStep == totalSteps - 1 ? "checkmark" : "chevron.right")
                        .font(.body.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
            }
            .glassEffect(.regular.interactive().tint(themeManager.accentColor.opacity(0.9)), in: Capsule())
            .opacity(currentStep == totalSteps - 1 && subjectName.isEmpty ? 0.5 : 1)
            .disabled(currentStep == totalSteps - 1 && subjectName.isEmpty)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
    
    // MARK: - Handle Next Action
    private func handleNextAction() {
        if currentStep < totalSteps - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep += 1
            }
        } else {
            // Complete onboarding
            createFirstSubjectIfNeeded()
            saveGradingSystem()
            ToastManager.shared.success("Willkommen bei School!", icon: "hand.wave.fill", iconColor: themeManager.accentColor)
            onComplete()
        }
    }
    
    // MARK: - Step 1: Welcome
    private var welcomeStep: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Real app icon from assets
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .cornerRadius(28)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 20, y: 10)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                VStack(spacing: 16) {
                    Text("Willkommen bei School")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)
                    
                    Text("Dein persönlicher Begleiter für bessere Noten. Behalte den Überblick über alle deine Fächer und Leistungen.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 80)

        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .vertical)
        .contentMargins(.top, 100, for: .scrollContent)
        .contentMargins(.bottom, 120, for: .scrollContent)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity, alignment: .center)

    }
    
    // MARK: - Step 2: Features
    private var featuresStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Was School kann")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                VStack(spacing: 16) {
                    AnimatedFeatureRow(
                        icon: "book.closed.fill",
                        iconColor: Color(hex: "4ECDC4"),
                        title: "Fächer verwalten",
                        description: "Organisiere alle deine Schulfächer an einem Ort",
                        isVisible: showContent,
                        delay: 0.1
                    )
                    
                    AnimatedFeatureRow(
                        icon: "chart.bar.fill",
                        iconColor: Color(hex: "F39C12"),
                        title: "Noten tracken",
                        description: "Trage Noten ein und behalte deinen Schnitt im Blick",
                        isVisible: showContent,
                        delay: 0.2
                    )
                    
                    AnimatedFeatureRow(
                        icon: "widget.small",
                        iconColor: Color(hex: "E91E63"),
                        title: "Widgets",
                        description: "Behalte deine Noten immer im Blick mit Widgets",
                        isVisible: showContent,
                        delay: 0.3
                    )
                    
                    AnimatedFeatureRow(
                        icon: "icloud.fill",
                        iconColor: Color(hex: "3498DB"),
                        title: "iCloud Sync",
                        description: "Deine Daten sind sicher und auf allen Geräten verfügbar",
                        isVisible: showContent,
                        delay: 0.4
                    )
                }
                .padding(.horizontal, 24)

            }
            .padding(.top, 80)

        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .vertical)
        .contentMargins(.top, 100, for: .scrollContent)
        .contentMargins(.bottom, 120, for: .scrollContent)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Step 3: Grading System Selection
    private var gradingSystemStep: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Welches System nutzt du?")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("Du kannst dies später jederzeit ändern")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)
                }
                
                VStack(spacing: 16) {
                    AnimatedGradingSystemOptionCard(
                        system: .traditional,
                        isSelected: selectedGradingSystem == .traditional,
                        isVisible: showContent,
                        delay: 0.2,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedGradingSystem = .traditional
                            }
                        }
                    )
                    
                    AnimatedGradingSystemOptionCard(
                        system: .points,
                        isSelected: selectedGradingSystem == .points,
                        isVisible: showContent,
                        delay: 0.3,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedGradingSystem = .points
                            }
                        }
                    )
                }
                .padding(.horizontal, 24)
                
            }
            .padding(.top, 80)
            
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .vertical)
        .contentMargins(.top, 100, for: .scrollContent)
        .contentMargins(.bottom, 120, for: .scrollContent)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Step 4: First Subject
    private var firstSubjectStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Dein erstes Fach")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("Leg direkt mit deinem wichtigsten Fach los")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)
                }
                
                // Subject preview
                subjectPreview
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)
                
                // Subject name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Fachname")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("z.B. Mathematik", text: $subjectName)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)
                
                // Quick subject suggestions
                quickSubjectSuggestions
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.4), value: showContent)
                
                // Color picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Farbe")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                        ForEach(Self.colorPalette, id: \.self) { colorHex in
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColorHex == colorHex ? 3 : 0)
                                )
                                .shadow(color: selectedColorHex == colorHex ? Color(hex: colorHex).opacity(0.5) : .clear, radius: 6)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedColorHex = colorHex
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)
                
                // Icon picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Symbol")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(Self.iconOptions, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundColor(selectedIcon == icon ? .white : Color(hex: selectedColorHex))
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedIcon == icon ? Color(hex: selectedColorHex) : Color(hex: selectedColorHex).opacity(0.15))
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedIcon = icon
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.6), value: showContent)
                .padding(.bottom)
            }
            .padding(.top, 80)

        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .vertical)
        .contentMargins(.top, 100, for: .scrollContent)
        .contentMargins(.bottom, 120, for: .scrollContent)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Subject Preview
    private var subjectPreview: some View {
        HStack(spacing: 16) {
            Image(systemName: selectedIcon)
                .font(.title)
                .foregroundColor(Color(hex: selectedColorHex))
                .frame(width: 56, height: 56)
                .background(Color(hex: selectedColorHex).opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subjectName.isEmpty ? "Fachname" : subjectName)
                    .font(.headline)
                    .foregroundColor(subjectName.isEmpty ? .secondary : .primary)
                
                Text("Keine Noten")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("—")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
    
    // MARK: - Quick Subject Suggestions
    private var quickSubjectSuggestions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vorschläge")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Self.subjectSuggestions, id: \.name) { suggestion in
                        Button(action: {
                            applySubjectSuggestion(suggestion)
                        }) {
                            Text(suggestion.name)
                                .font(.subheadline)
                                .foregroundColor(subjectName == suggestion.name ? .white : .primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(subjectName == suggestion.name ? Color(hex: selectedColorHex) : Color(.systemGray6))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // MARK: - Apply Subject Suggestion
    private func applySubjectSuggestion(_ suggestion: OnboardingSubjectSuggestion) {
        withAnimation(.easeInOut(duration: 0.3)) {
            subjectName = suggestion.name
            selectedColorHex = suggestion.colorHex
            selectedIcon = suggestion.icon
            selectedCustomGradeTypes = suggestion.customGradeTypes
        }
    }
    
    // MARK: - Helper Functions
    private func createFirstSubjectIfNeeded() {
        guard !subjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedName = subjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if subject already exists
        let descriptor = FetchDescriptor<Subject>(predicate: #Predicate { $0.name == trimmedName })
        let existingSubjects = (try? modelContext.fetch(descriptor)) ?? []
        
        guard existingSubjects.isEmpty else { return }
        
        // Create the subject
        let newSubject = Subject(name: trimmedName, colorHex: selectedColorHex, icon: selectedIcon)
        modelContext.insert(newSubject)
        
        // Create grade types - use custom if available, otherwise default
        if let customTypes = selectedCustomGradeTypes {
            let customTypeTuples = customTypes.map { (name: $0.name, weight: $0.weight, icon: $0.icon) }
            DataManager.createCustomGradeTypes(customTypeTuples, for: newSubject, in: modelContext)
            debugLog(" Created first subject during onboarding with custom grade types: \(trimmedName)")
        } else {
            DataManager.createDefaultGradeTypes(for: newSubject, in: modelContext)
            debugLog(" Created first subject during onboarding with default grade types: \(trimmedName)")
        }
        
        try? modelContext.save()
    }
    
    private func saveGradingSystem() {
        let currentYear = SchoolYear.current
        SchoolYearGradingSystemManager.setGradingSystem(selectedGradingSystem, forSchoolYear: currentYear.startYear, in: modelContext)
        debugLog(" Set grading system during onboarding: \(selectedGradingSystem.displayName)")
    }
    
    // MARK: - Static Data
    private static let colorPalette: [String] = [
        "FF6B6B", "4ECDC4", "45B7D1", "16A085", "F39C12",
        "8E44AD", "27AE60", "E67E22", "E74C3C", "3498DB",
        "95A5A6", "D4AF37", "E91E63", "2980B9", "00BCD4"
    ]
    
    private static let iconOptions: [String] = [
        "book.fill", "book.closed.fill", "graduationcap.fill", "atom", "function",
        "globe", "leaf.fill", "paintbrush.fill", "music.note", "camera.fill",
        "hammer.fill", "gearshape.fill", "heart.fill", "brain.fill", "eye.fill",
        "mic.fill", "speaker.fill", "globe.europe.africa", "flag.fill", "star.fill",
        "chart.bar.fill", "figure.run", "laptopcomputer", "bubble.left.and.text.bubble.right.fill"
    ]
    
    // Subject suggestions with colors, icons, and custom grade types
    private static let subjectSuggestions: [OnboardingSubjectSuggestion] = [
        OnboardingSubjectSuggestion(name: "Mathematik", colorHex: "45B7D1", icon: "function", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 50, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill")
        ]),
        OnboardingSubjectSuggestion(name: "Deutsch", colorHex: "FF6B6B", icon: "book.closed.fill", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 50, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill")
        ]),
        OnboardingSubjectSuggestion(name: "Englisch", colorHex: "D4AF37", icon: "globe.europe.africa", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 40, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill"),
            GradeTypeDefinition(name: "Vokabeltests", weight: 10, icon: "doc.text.fill")
        ]),
        OnboardingSubjectSuggestion(name: "Physik", colorHex: "3498DB", icon: "atom", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 40, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill"),
            GradeTypeDefinition(name: "Praktisch", weight: 10, icon: "testtube.2")
        ]),
        OnboardingSubjectSuggestion(name: "Chemie", colorHex: "16A085", icon: "atom", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 40, icon: "pencil"),
            GradeTypeDefinition(name: "Mündlich", weight: 50, icon: "bubble.fill"),
            GradeTypeDefinition(name: "Praktisch", weight: 10, icon: "testtube.2")
        ]),
        OnboardingSubjectSuggestion(name: "Biologie", colorHex: "27AE60", icon: "leaf.fill"),
        OnboardingSubjectSuggestion(name: "Informatik", colorHex: "2980B9", icon: "laptopcomputer", customGradeTypes: [
            GradeTypeDefinition(name: "Schriftlich", weight: 30, icon: "pencil"),
            GradeTypeDefinition(name: "Praktisch", weight: 40, icon: "laptopcomputer"),
            GradeTypeDefinition(name: "Mündlich", weight: 30, icon: "bubble.fill")
        ]),
        OnboardingSubjectSuggestion(name: "Sport", colorHex: "E74C3C", icon: "figure.run", customGradeTypes: [
            GradeTypeDefinition(name: "Praktisch", weight: 80, icon: "figure.run"),
            GradeTypeDefinition(name: "Sonstige", weight: 20, icon: "bubble.fill")
        ])
    ]
}

// MARK: - Onboarding Subject Suggestion
struct OnboardingSubjectSuggestion {
    let name: String
    let colorHex: String
    let icon: String
    let customGradeTypes: [GradeTypeDefinition]?
    
    init(name: String, colorHex: String, icon: String, customGradeTypes: [GradeTypeDefinition]? = nil) {
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.customGradeTypes = customGradeTypes
    }
}

// MARK: - Animated Feature Row Component
struct AnimatedFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let isVisible: Bool
    let delay: Double
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 50, height: 50)
                .background(iconColor.opacity(0.15))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(delay), value: isVisible)
    }
}

// MARK: - Animated Grading System Option Card
struct AnimatedGradingSystemOptionCard: View {
    let system: GradingSystem
    let isSelected: Bool
    let isVisible: Bool
    let delay: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: system == .traditional ? "1.circle.fill" : "15.circle.fill")
                        .font(.title)
                        .foregroundColor(isSelected ? .white : .secondary)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(system.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(system == .traditional ? "Klassische Schulnoten von 1 bis 6" : "Oberstufenpunkte von 0 bis 15")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Checkmark or placeholder circle
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : Color(.systemGray4))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? AnyShapeStyle(Color.blue.opacity(0.1)) : AnyShapeStyle(.thinMaterial))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color(.systemGray5), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.easeOut(duration: 0.4).delay(delay), value: isVisible)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(onComplete: {})
        .environment(ThemeManager.shared)
        .modelContainer(for: Subject.self, inMemory: true)
}
