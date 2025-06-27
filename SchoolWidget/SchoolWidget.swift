//
//  SchoolWidget.swift
//  SchoolWidget
//
//  Created by Carl on 26.06.25.
//

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Entry

/// Widget Timeline Entry containing the data to display
/// Debug: Holds the overall average and additional context for the widget
struct SchoolWidgetEntry: TimelineEntry {
    let date: Date
    let overallAverage: Double?
    let subjectCount: Int
    let gradeCount: Int
    let selectedSchoolYear: SchoolYear
    let selectedSemester: Semester
    let gradingSystem: GradingSystem
    
    // Debug: Sample data for previews
    static let sampleEntry = SchoolWidgetEntry(
        date: Date(),
        overallAverage: 2.1,
        subjectCount: 8,
        gradeCount: 24,
        selectedSchoolYear: SchoolYear.current,
        selectedSemester: .first,
        gradingSystem: .traditional
    )
    
    static let emptyEntry = SchoolWidgetEntry(
        date: Date(),
        overallAverage: nil,
        subjectCount: 0,
        gradeCount: 0,
        selectedSchoolYear: SchoolYear.current,
        selectedSemester: .first,
        gradingSystem: .traditional
    )
}

// MARK: - Timeline Provider

/// Provides timeline entries for the widget
/// Debug: Determines when and how often the widget should update
struct SchoolWidgetTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> SchoolWidgetEntry {
        return SchoolWidgetEntry.sampleEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SchoolWidgetEntry) -> Void) {
        // Debug: For widget gallery and system screenshots
        completion(SchoolWidgetEntry.sampleEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SchoolWidgetEntry>) -> Void) {
        // Debug: Get current data from shared container
        let entry = loadCurrentWidgetData()
        
        // Debug: Update every hour, or when app updates the data
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        
        completion(timeline)
    }
    
    /// Load current widget data from shared storage
    /// Debug: Reads data from shared UserDefaults/App Group
    private func loadCurrentWidgetData() -> SchoolWidgetEntry {
        // Debug: For now return sample data, we'll implement shared storage later
        return WidgetDataManager.loadWidgetData()
    }
}

// MARK: - Widget Views

/// Small Widget View (2x2)
/// Debug: Shows overall average prominently
struct SchoolWidgetSmallView: View {
    let entry: SchoolWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "graduationcap.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text(entry.selectedSemester.shortName)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Main Content - Overall Average
            HStack(spacing: 4) {
                if let average = entry.overallAverage {
                    Text("⌀")
                        .font(.system(size: 65))
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.6)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(GradingSystemHelpers.gradeDisplayText(for: average, system: entry.gradingSystem))
                        .font(.system(size: 65))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                } else {
                     VStack(spacing: 2) {
                         Text("Keine")
                             .font(.headline)
                             .foregroundColor(.white.opacity(0.8))
                         Text("Noten")
                             .font(.caption)
                             .foregroundColor(.white.opacity(0.6))
                     }
                 }
            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("\(entry.subjectCount) Fächer")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text(entry.selectedSchoolYear.displayName.replacingOccurrences(of: "/", with: "/"))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }

        .containerBackground(averageColor.gradient, for: .widget)
    }
    
    /// Color based on current average performance
    private var averageColor: Color {
        guard let average = entry.overallAverage else { return .gray }
        return GradingSystemHelpers.gradeColor(for: average, system: entry.gradingSystem)
    }
}

/// Medium Widget View (4x2)
/// Debug: Shows average plus additional statistics
struct SchoolWidgetMediumView: View {
    let entry: SchoolWidgetEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Main average
            VStack(alignment: .leading, spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Schnitt")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("\(entry.selectedSchoolYear.displayName)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Main average
                if let average = entry.overallAverage {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("⌀")
                            .font(.system(size: 60))
                            .bold()
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(GradingSystemHelpers.gradeDisplayText(for: average, system: entry.gradingSystem))
                            .font(.system(size: 60))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                } else {
                    Text("Keine Noten")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right side - Statistics
            VStack(alignment: .trailing, spacing: 12) {
                // Semester indicator
                Text(entry.selectedSemester.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Statistics
                VStack(alignment: .trailing, spacing: 4) {
                    if entry.subjectCount > 0 {
                        Text("\(entry.subjectCount) Fächer")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    if entry.gradeCount > 0 {
                        Text("\(entry.gradeCount) Noten")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Text(entry.gradingSystem.displayName)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .containerBackground(averageColor.gradient, for: .widget)
    }
    
    /// Color based on current average performance
    private var averageColor: Color {
        guard let average = entry.overallAverage else { return .gray }
        return GradingSystemHelpers.gradeColor(for: average, system: entry.gradingSystem)
    }
}

// MARK: - Widget Configuration

/// Main Widget Configuration
/// Debug: Configures the widget family and views
struct SchoolWidget: Widget {
    let kind: String = "SchoolWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SchoolWidgetTimelineProvider()) { entry in
            SchoolWidgetView(entry: entry)
        }
        .configurationDisplayName("School Durchschnitt")
        .description("Zeigt deinen aktuellen Notendurchschnitt an.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// Widget View Router
/// Debug: Routes to appropriate view based on widget family
struct SchoolWidgetView: View {
    let entry: SchoolWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SchoolWidgetSmallView(entry: entry)
        case .systemMedium:
            SchoolWidgetMediumView(entry: entry)
        default:
            SchoolWidgetSmallView(entry: entry)
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    SchoolWidget()
} timeline: {
    SchoolWidgetEntry.sampleEntry
    SchoolWidgetEntry.emptyEntry
}

#Preview(as: .systemMedium) {
    SchoolWidget()
} timeline: {
    SchoolWidgetEntry.sampleEntry
    SchoolWidgetEntry.emptyEntry
}
