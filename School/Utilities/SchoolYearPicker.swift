//
//  SchoolYearPicker.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import SwiftUI

struct SchoolYearPicker: View {
    @Binding var selectedSchoolYear: SchoolYear
    let availableYears: [SchoolYear] = SchoolYear.allAvailableYears
    
    var body: some View {
        HStack {
            Text("Aktuelles Schuljahr:")
            .bold()
            Spacer()

            Picker("Schuljahr", selection: $selectedSchoolYear) {
                ForEach(availableYears, id: \.startYear) { year in
                    Text(year.displayName)
                        .tag(year)
                }
            }
            .pickerStyle(.menu) // Debug: Dropdown style for large list
        }
        .padding(.vertical, 6)
        .padding(.leading, 10)

    }
}
