import SwiftUI

// Debug: Triangle shape for speech bubble tail
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Debug: Create triangle pointing right (will be rotated for speech bubble)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// Debug: Simple speech bubble tail that actually looks like one
struct SimpleSpeechTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Debug: Create a simple curved tail pointing toward the character
        path.move(to: CGPoint(x: 0, y: height * 0.3))
        
        // Debug: Curve down and out to create the tail point
        path.addQuadCurve(
            to: CGPoint(x: width * 0.8, y: height * 0.7),
            control: CGPoint(x: width * 0.4, y: height * 0.9)
        )
        
        // Debug: Curve back up to connect
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height * 0.7),
            control: CGPoint(x: width * 0.3, y: height * 0.5)
        )
        
        path.closeSubpath()
        
        return path
    }
} 