# Data Models

## English Model Names with German Context

All data models use English naming for better code maintainability and iOS development standards. German terms are preserved in comments and UI text.

### Model Overview

| English Model | German Term | Description |
|---------------|-------------|-------------|
| `SchoolYear` | Schuljahr | Represents academic years (e.g., 2024/2025) |
| `Semester` | Halbjahr | First/Second half of school year |
| `Subject` | Fach | School subjects (Math, German, etc.) |
| `Grade` | Note | Individual grades/marks |
| `GradeType` | NotenType | Type of assessment per subject (Schriftlich, Mündlich) |

### SwiftData Structure

All models are now stored using SwiftData for persistence:
- **Subject**: `@Model` class with relationships to grades and grade types
- **Grade**: `@Model` class with relationships to subject and grade type
- **GradeType**: `@Model` class (NEW) with relationship to subject

### Grade Type Implementation

**Key Changes:**
- Grade types are now stored in SwiftData instead of UserDefaults
- Each subject has its own independent set of grade types
- Default grade types created automatically: "Schriftlich" (40%, pencil) and "Mündlich" (60%, bubble.fill)
- Grade types can be added, edited, and deleted per subject

### Hierarchy

```
SchoolYear (2024/2025)
├── Semester (1./2. Halbjahr)
    ├── Subject (Mathe, Deutsch, etc.)
        ├── GradeType (Schriftlich 40%, Mündlich 60%)
        ├── Grade (1.0, 2.5, etc.)
            └── belongs to GradeType
```

### Default Grade Types

Each new subject automatically gets:
1. **Schriftlich** - 40% weight, pencil icon
2. **Mündlich** - 60% weight, bubble.fill icon

### Usage

- UI displays German terms to users
- Code uses English model names
- German terms available in static properties and comments
- Grade types are subject-specific and stored in SwiftData 