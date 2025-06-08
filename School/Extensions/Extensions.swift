//
//  Extensions.swift
//  School
//
//  Created by Carl on 05.06.25.
//

import Foundation
import SwiftUI

extension Color {
    static func randomVibrant() -> Color {
        // Zufällige Werte für Rot, Grün und Blau erzeugen
        let red = Double.random(in: 0.5...1.0)
        let green = Double.random(in: 0.5...1.0)
        let blue = Double.random(in: 0.5...1.0)
        
        // Eine Farbe mit diesen zufälligen Werten erzeugen
        return Color(red: red, green: green, blue: blue)
    }
    
    func appropriateTextColor() -> Color {
        // Versucht, die Komponenten der Farbe zu extrahieren
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Luminanz berechnen (nach dem W3C-Standard)
        let luminance = (0.299 * red + 0.587 * green + 0.114 * blue)
        
        // Wenn die Luminanz hoch ist, dann dunkle Schrift, sonst helle
        return luminance > 0.6 ? .black : .white
    }
    
    // Debug: Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UserDefaults {
    func setStruct<T: Codable>(_ value: T?, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            self.set(encoded, forKey: key)
        }
    }
    
    func getStruct<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(T.self, from: data) {
                return decoded
            }
        }
        return nil
    }
    
    func removeStruct(forKey key: String) {
        self.removeObject(forKey: key)
    }
}

struct ScalableButtonStyle: ButtonStyle {
    // Skalierungsfaktor - wie stark der Button verkleinert werden soll
    var scaleAmount: CGFloat
    
    // Standardwert für den Skalierungsfaktor
    init(scaleAmount: CGFloat = 0.9) {
        self.scaleAmount = scaleAmount
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Hier verkleinern wir den Button beim Drücken
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            // Animation hinzufügen für einen weicheren Übergang
            .animation(.smooth, value: configuration.isPressed)
    }
}

// Erweiterung für bessere Autovervollständigung
extension ButtonStyle where Self == ScalableButtonStyle {
    static var scalable: ScalableButtonStyle { .init() }
    
    // Variante mit anpassbarem Skalierungsfaktor
    static func scalable(scaleAmount: CGFloat) -> ScalableButtonStyle {
        ScalableButtonStyle(scaleAmount: scaleAmount)
    }
}

struct BottomButtonModifier: ViewModifier {
    let minBottomPadding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) { bottomPadding }
    }
    
    @ViewBuilder
    private var bottomPadding: some View {
        GeometryReader { geometry in
            Color.clear
                .frame(height: max(geometry.safeAreaInsets.bottom, minBottomPadding))
        }
    }
}

extension View {
    func bottomButton(minBottomPadding: CGFloat = 16) -> some View {
        self.modifier(BottomButtonModifier(minBottomPadding: minBottomPadding))
    }
}
