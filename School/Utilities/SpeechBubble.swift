//
//  GlassySpeechBubble1.swift
//  School
//
//  Created by Carl on 08.06.25.
//



import SwiftUI

struct GlassySpeechBubble1: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 0) {
            // Main bubble with frosted effect
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(.systemBackground))
                    .overlay(
                        // Inner glow
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.primary.opacity(0.6),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                ),
                                lineWidth: 2
                            )
                            .blur(radius: 1)
                    )
                    .overlay(
                        // Outer stroke
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                Color.primary.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                    .shadow(color: Color.white.opacity(0.5), radius: 3, x: 0, y: -2)
                
                // Content
                Text(text)
                    .foregroundColor(.primary)
                    .bold()
                    .font(.title3)
                    .padding(8)
            }
            
        
        }
        .frame(maxWidth: 300)
    }
}
