//
//  SchoolApp.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI
import SwiftData

@main
struct SchoolApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    // Debug: Configure SwiftData model container for Subject, Grade, GradeType, and FinalGrade persistence
    .modelContainer(for: [Subject.self, Grade.self, GradeType.self, FinalGrade.self])
  }
}
