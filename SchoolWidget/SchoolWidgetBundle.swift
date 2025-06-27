//
//  SchoolWidgetBundle.swift
//  SchoolWidget
//
//  Created by Carl on 26.06.25.
//

import WidgetKit
import SwiftUI

/// Widget Bundle entry point
/// Debug: This is the main entry point for the widget extension
@main
struct SchoolWidgetBundle: WidgetBundle {
    var body: some Widget {
        SchoolWidget()
        // Debug: Add more widgets here in the future (e.g., subject-specific widgets)
        // SubjectWidget()
        // UpcomingExamsWidget()
    }
}