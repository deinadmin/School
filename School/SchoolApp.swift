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
    .modelContainer(for: [Subject.self, Grade.self, GradeType.self, FinalGrade.self])
  }
}
