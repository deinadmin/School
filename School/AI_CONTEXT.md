# 🎓 School App - AI Development Context

## 📱 Project Overview

**App Name**: School (iOS App für deutsche Schüler)  
**Purpose**: Grade tracking and management app for German students  
**Target Users**: German high school students (Gymnasium, Realschule, etc.)  
**Platform**: iOS only (SwiftUI)

## 🎯 Core Functionality

Students can:
- Create school subjects (Fächer) for different school years
- Track grades (Noten) for each subject
- Organize by school years (2024/2025, etc.) and semesters (Halbjahre)
- Calculate weighted averages based on German grading system
- View progress over time

## 🏫 German Education System Context

### Grading System
- **Scale**: 1.0 (best) to 6.0 (worst)
- **Pass/Fail**: 4.0 is minimum passing grade
- **Common grades**: 1.0, 1.3, 1.7, 2.0, 2.3, 2.7, 3.0, 3.3, 3.7, 4.0, 4.3, 4.7, 5.0, 5.3, 5.7, 6.0

### School Year Structure
- **Academic Year**: August/September to July/August (next year)
- **Format**: "2024/2025" (start year/end year)
- **Semesters**: Two halves ("1. Halbjahr", "2. Halbjahr")

### Assessment Types
- **Klassenarbeit/Klausur**: Major exams (weight: 3)
- **Test**: Small tests (weight: 2) 
- **Hausaufgabe**: Homework (weight: 1)
- **Mündliche Mitarbeit**: Oral participation (weight: 1)

## 🛠 Tech Stack

- **Frontend**: SwiftUI
- **Language**: Swift
- **Platform**: iOS only


## 📁 Current Project Structure

```
School/
├── Models/
│   ├── SchoolYear.swift     # Academic years (2024/2025)
│   ├── Semester.swift       # 1./2. Halbjahr enum
│   ├── Subject.swift        # School subjects (Fächer)
│   ├── Grade.swift          # Individual grades (Noten)
│   ├── GradeType.swift      # Assessment types (NotenType)
│   └── README.md           # Model documentation
├── Utilities/
│   └── SchoolYearPicker.swift # UI for year selection
├── SchoolApp.swift         # Main app entry point
└── ContentView.swift       # Main view
```

## 🗃 Data Models

### Hierarchy
```
SchoolYear (2024/2025)
├── Semester (1./2. Halbjahr)
    ├── Subject (Mathe, Deutsch, Englisch, etc.)
        ├── Grade (1.0, 2.5, 3.7, etc.)
            └── GradeType (Klassenarbeit, Test, Hausaufgabe, etc.)
```

### Key Models

**SchoolYear**
- Represents academic years (e.g., 2024/2025)
- Auto-detects current year based on German calendar
- Provides picker with years 2000/2001 to 2099/2100

**Semester** 
- Enum: `.first` ("1. Halbjahr"), `.second` ("2. Halbjahr")

**Subject**
- School subjects with name, color, icon
- Linked to specific SchoolYear + Semester

**Grade**
- Individual grades (1.0-6.0 scale)
- Linked to Subject and GradeType
- Optional date

**GradeType**
- Assessment types with weights for calculation
- Predefined German types (Klassenarbeit, Test, etc.)

## 🎨 UI/UX Guidelines

### Language
- **Code**: English (for maintainability)
- **UI**: German (user-facing)
- **Comments**: German terms as reference

### Design Principles
- Simple, clean interface for students
- German educational terminology
- Intuitive grade entry and overview
- Color-coded subjects for visual organization

## 📋 User Stories

### Current Features
- [x] Data models for German school system
- [x] School year picker (2000-2099)
- [x] Semester selection
- [x] Subject creation with colors/icons
- [x] Grade tracking with types and weights

### Planned Features
- [ ] Grade calculation (weighted averages)
- [ ] Subject overview screens
- [ ] Grade entry forms
- [ ] Progress charts and statistics
- [ ] Export functionality
- [ ] Cloud sync with iCloud
- [ ] Multiple school types support

## 🔧 Development Guidelines

### Swift/SwiftUI Rules
- Use `@Observable` for ViewModels
- Prefer `@State` for local UI state only
- Use `@Environment` for app-wide state
- Implement lazy loading for large lists
- Write clean, commented code
- Add debug logs for development

### Code Quality
- Keep files under 200-300 lines
- No duplicate code patterns
- Simple solutions preferred
- Proper error handling
- Unit tests for business logic

### Naming Conventions
- **Models**: English names (Subject, Grade, etc.)
- **UI Text**: German display names
- **Files**: English naming
- **Comments**: Include German equivalents

## 🎓 German School Types Context

The app should eventually support different German school types:
- **Gymnasium**: Academic track (grades 5-12/13)
- **Realschule**: Intermediate track (grades 5-10)
- **Hauptschule**: Basic track (grades 5-9)
- **Gesamtschule**: Comprehensive school
- **Berufsschule**: Vocational school

## 📊 Grade Calculation Logic

### Weighted Average Formula
```
Average = Σ(grade × weight) / Σ(weight)
```

### Example
- Klassenarbeit (2.0, weight 3) = 6.0 points
- Test (1.7, weight 2) = 3.4 points  
- Hausaufgabe (1.0, weight 1) = 1.0 points
- **Average**: (6.0 + 3.4 + 1.0) / (3 + 2 + 1) = 1.73

## 🚀 Current Development Status

**Phase**: Early development - data models complete
**Next Priority**: UI implementation for grade entry and subject management
**Goal**: MVP for single user grade tracking

## 💡 AI Assistant Guidelines

When helping with this project:
1. **Maintain German education context** - understand the grading system
2. **Follow SwiftUI best practices** - use proper state management
3. **Keep UI in German** - all user-facing text should be German
4. **Consider mobile UX** - design for iPhone usage by students
6. **Debug extensively** - add logs and comments for development
7. **Test thoroughly** - consider edge cases in German school system

---

**Last Updated**: June 2025  
**Version**: Early Development Phase 