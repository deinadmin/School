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
| `GradeType` | NotenType | Type of assessment (Test, Homework, etc.) |

### Hierarchy

```
SchoolYear (2024/2025)
├── Semester (1./2. Halbjahr)
    ├── Subject (Mathe, Deutsch, etc.)
        ├── Grade (1.0, 2.5, etc.)
            └── GradeType (Klassenarbeit, Test, etc.)
```

### Usage

- UI displays German terms to users
- Code uses English model names
- German terms available in static properties and comments 