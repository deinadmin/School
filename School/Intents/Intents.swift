import AppIntents
import UIKit

// Debug: App Intent to add a new grade, now using URL-based deep linking for iOS 18+ controls
struct AddGradeIntent: AppIntent {
    static var title: LocalizedStringResource = "Neue Note hinzufügen"
    static var description: IntentDescription? = "Fügt schnell eine neue Note für ein Fach hinzu."
    
    // Debug: This ensures the app opens when the shortcut is run
    static var openAppWhenRun: Bool = true
    
    // Debug: Define how the intent is displayed in lists and as a control
    static var shortTitle: LocalizedStringResource = "Note hinzufügen"
    static var systemImageName: String = "plus.circle"
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Debug: Open the app via a custom URL scheme to trigger the view
        guard let url = URL(string: "schoolapp://quick-add") else {
            return .result()
        }
        
        // Debug: Use UIApplication to open the URL
        await UIApplication.shared.open(url)
        return .result()
    }
}

// Debug: Expose the intent to the system using AppShortcutsProvider
struct SchoolAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddGradeIntent(),
            phrases: [
                "Neue Note in \(.applicationName)",
                "Füge eine Note in \(.applicationName) hinzu"
            ],
            shortTitle: "Note hinzufügen",
            systemImageName: "plus.circle"
        )
    }
} 