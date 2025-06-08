import SwiftUI
import Foundation

struct CardBasedSchoolPicker: View {
    @Binding var selectedSchoolYear: SchoolYear
    @Binding var selectedSemester: Semester
    @State private var isExpanded = false
    
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
                        Text("\(selectedSemester.displayName)")
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
                                    ForEach(SchoolYear.allAvailableYears, id: \.startYear) { year in
                                        YearChip(
                                            year: year,
                                            isSelected: selectedSchoolYear.startYear == year.startYear,
                                            action: { selectedSchoolYear = year }
                                        )
                                        .id(year.startYear) // Add id for scrolling
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .onAppear {
                                // Scroll to selected year when view appears
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo(selectedSchoolYear.startYear, anchor: .center)
                                }
                            }
                            .onChange(of: isExpanded) { _, newValue in
                                // Scroll to selected year when picker expands
                                if newValue {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo(selectedSchoolYear.startYear, anchor: .center)
                                    }
                                }
                            }
                        }
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
                .fill(.thinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct YearChip: View {
    let year: SchoolYear
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(year.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
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
            )
        }
        .buttonStyle(.scalable)
    }
}
