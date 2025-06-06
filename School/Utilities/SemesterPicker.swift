//
//  SemesterPicker.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI

struct SemesterPicker: View {
    @Binding var selectedSemester: Semester
    let availableSemesters = Semester.allCases // Debug: Using all available semesters
    
    var body: some View {
        HStack {
            Text("Aktuelles Halbjahr:")
                .bold()
            Spacer()

            Picker("Halbjahr", selection: $selectedSemester) {
                ForEach(availableSemesters) { semester in
                    Text(semester.displayName)
                        .tag(semester)
                }
            }
            .pickerStyle(.menu) // Debug: Dropdown style for semester selection
        }
        .padding(.leading, 10)
    }
}
