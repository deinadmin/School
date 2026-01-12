//
//  ToastManager.swift
//  School
//
//  Created by Carl on 12.01.26.
//

import SwiftUI
import Combine

// MARK: - Toast Model

/// Represents a toast notification with customizable appearance
/// Debug: Supports different types (success, error, info, warning) with corresponding icons and colors
struct Toast: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let type: ToastType
    let duration: TimeInterval
    let icon: String?
    /// Custom icon color - if nil, uses accent blue
    let iconColor: Color?
    
    init(message: String, type: ToastType = .success, duration: TimeInterval = 2.5, icon: String? = nil, iconColor: Color? = nil) {
        self.message = message
        self.type = type
        self.duration = duration
        self.icon = icon
        self.iconColor = iconColor
    }
    
    /// Resolved icon color - uses custom color if provided, otherwise accent blue
    var resolvedIconColor: Color {
        iconColor ?? .accentColor
    }
    
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

/// Toast notification types with corresponding styling
enum ToastType {
    case success
    case error
    case info
    case warning
    
    var defaultIcon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success: return Color.green.opacity(0.15)
        case .error: return Color.red.opacity(0.15)
        case .info: return Color.blue.opacity(0.15)
        case .warning: return Color.orange.opacity(0.15)
        }
    }
}

// MARK: - Toast Manager

/// Singleton manager for displaying stackable toast notifications
/// Debug: Supports up to 2 visible toasts at once with stack animation
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    /// Currently visible toasts (max 2)
    @Published var visibleToasts: [Toast] = []
    
    /// Maximum number of visible toasts
    private let maxVisibleToasts = 2
    
    /// Dismiss tasks for each toast
    private var dismissTasks: [UUID: Task<Void, Never>] = [:]
    
    private init() {}
    
    /// Show a toast notification
    /// Debug: Adds to visible stack, removing oldest if at max capacity
    @MainActor
    func show(_ toast: Toast) {
        // If at max capacity, remove the oldest (bottom) toast
        if visibleToasts.count >= maxVisibleToasts {
            let oldestToast = visibleToasts.first!
            dismissTasks[oldestToast.id]?.cancel()
            dismissTasks.removeValue(forKey: oldestToast.id)
            visibleToasts.removeFirst()
        }
        
        // Add new toast to the end (top of stack visually)
        visibleToasts.append(toast)
        
        // Schedule auto-dismiss for this toast
        scheduleDismiss(for: toast)
    }
    
    /// Convenience method for success toasts
    @MainActor
    func success(_ message: String, icon: String? = nil, iconColor: Color? = nil) {
        show(Toast(message: message, type: .success, duration: 3.0, icon: icon, iconColor: iconColor))
    }
    
    /// Convenience method for error toasts
    @MainActor
    func error(_ message: String, icon: String? = nil, iconColor: Color? = nil) {
        show(Toast(message: message, type: .error, duration: 3.5, icon: icon, iconColor: iconColor))
    }
    
    /// Convenience method for info toasts
    @MainActor
    func info(_ message: String, icon: String? = nil, iconColor: Color? = nil) {
        show(Toast(message: message, type: .info, duration: 3.0, icon: icon, iconColor: iconColor))
    }
    
    /// Convenience method for warning toasts
    @MainActor
    func warning(_ message: String, icon: String? = nil, iconColor: Color? = nil) {
        show(Toast(message: message, type: .warning, duration: 3.5, icon: icon, iconColor: iconColor))
    }
    
    @MainActor
    private func scheduleDismiss(for toast: Toast) {
        dismissTasks[toast.id] = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            if !Task.isCancelled {
                dismiss(toast: toast)
            }
        }
    }
    
    /// Dismiss a specific toast
    @MainActor
    func dismiss(toast: Toast) {
        dismissTasks[toast.id]?.cancel()
        dismissTasks.removeValue(forKey: toast.id)
        
        if let index = visibleToasts.firstIndex(where: { $0.id == toast.id }) {
            visibleToasts.remove(at: index)
        }
    }
    
    /// Dismiss all toasts
    @MainActor
    func dismissAll() {
        for (id, task) in dismissTasks {
            task.cancel()
            dismissTasks.removeValue(forKey: id)
        }
        visibleToasts.removeAll()
    }
}

// MARK: - Toast View

/// Liquid Glass style toast view using iOS 26 native glassEffect
/// Debug: Uses Apple's native .glassEffect with tint for colored glass styling
struct ToastView: View {
    let toast: Toast
    @Environment(ThemeManager.self) private var themeManager // Debug: Get global accent color
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with type-specific color (falls back to current theme color)
            Image(systemName: toast.icon ?? toast.type.defaultIcon)
                .font(.system(size: isIPad ? 22 : 20, weight: .semibold))
                .foregroundStyle(toast.iconColor ?? themeManager.accentColor)
                .symbolEffect(.bounce, value: toast.id)
            
            // Message text - using secondary for better contrast on glass
            Text(toast.message)
                .font(.system(size: isIPad ? 16 : 15, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, isIPad ? 20 : 16)
        .padding(.vertical, isIPad ? 16 : 14)
        .frame(maxWidth: isIPad ? 500 : .infinity)
        // iOS 26 Liquid Glass Effect with interactive style and type-based tint
        .glassEffect(.regular.interactive(), in: .capsule)
        .tint((toast.iconColor ?? themeManager.accentColor).opacity(0.35))
        .padding(.horizontal, isIPad ? 0 : 16)
        .contentShape(.capsule) // Debug: Define shape for tap interception
        .onTapGesture {
            // Debug: Intercept tap to prevent it from passing through to views behind the toast
        }
    }
}

// MARK: - Animated Toast Item

/// Individual toast item with animation state
struct AnimatedToastItem: View {
    let toast: Toast
    let index: Int
    let totalCount: Int
    let onDismiss: () -> Void
    
    @State private var animateIn = false
    @State private var hasTriggeredHaptic = false
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    /// Is this the front (newest) toast?
    private var isFront: Bool {
        index == totalCount - 1
    }
    
    /// Scale factor - front toast is full size, back toast is slightly smaller
    private var scale: CGFloat {
        if isFront {
            return animateIn ? 1.0 : 0.85
        } else {
            return animateIn ? 0.92 : 0.85
        }
    }
    
    /// Vertical offset - back toast peeks just below front toast
    private var yOffset: CGFloat {
        if isFront {
            return animateIn ? 0 : -50
        } else {
            // Back toast: just a few pixels down to peek below
            return animateIn ? 12 : -50
        }
    }
    
    /// Opacity
    private var opacity: CGFloat {
        if isFront {
            return animateIn ? 1.0 : 0
        } else {
            return animateIn ? 0.7 : 0
        }
    }
    
    /// Blur radius
    private var blurRadius: CGFloat {
        if isFront {
            return animateIn ? 0 : 12
        } else {
            // No blur for back toast - better performance
            return 0
        }
    }
    
    var body: some View {
        ToastView(toast: toast)
            .blur(radius: blurRadius)
            .offset(y: yOffset)
            .opacity(opacity)
            .scaleEffect(scale)
            .zIndex(Double(index))
            .onTapGesture {
                if isFront {
                    dismissWithAnimation()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        if value.translation.height < -20 && isFront {
                            dismissWithAnimation()
                        }
                    }
            )
            .onAppear {
                withAnimation(.easeOut(duration: 0.35)) {
                    animateIn = true
                }
                
                // Haptic feedback only for front toast
                if isFront && !hasTriggeredHaptic {
                    hasTriggeredHaptic = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
                        impactFeedback.impactOccurred(intensity: 0.6)
                    }
                }
            }
            // Animate when transitioning to back position
            .animation(.easeOut(duration: 0.25), value: isFront)
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeOut(duration: 0.25)) {
            animateIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

// MARK: - Toast Container View

/// Container view that overlays stackable toasts on top of content
/// Debug: Supports up to 2 stacked toasts with smooth animations
struct ToastContainerView<Content: View>: View {
    @ObservedObject private var toastManager = ToastManager.shared
    let content: Content
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            content
            
            // Toast stack overlay with exit transition
            ZStack(alignment: .top) {
                ForEach(Array(toastManager.visibleToasts.enumerated()), id: \.element.id) { index, toast in
                    AnimatedToastItem(
                        toast: toast,
                        index: index,
                        totalCount: toastManager.visibleToasts.count,
                        onDismiss: {
                            withAnimation(.easeOut(duration: 0.25)) {
                                toastManager.dismiss(toast: toast)
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
            }
            .padding(.top, isIPad ? 20 : 8)
            .zIndex(999)
            .animation(.easeOut(duration: 0.25), value: toastManager.visibleToasts.count)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Apply toast overlay to any view
    /// Debug: Wraps content in ToastContainerView for toast display capability
    func withToastOverlay() -> some View {
        ToastContainerView {
            self
        }
    }
}

// MARK: - Preview

#Preview("Toast Types") {
    VStack(spacing: 20) {
        ToastView(toast: Toast(message: "Fach erfolgreich erstellt!", type: .success))
        ToastView(toast: Toast(message: "Note hinzugefügt", type: .success, icon: "plus.circle.fill"))
        ToastView(toast: Toast(message: "Fehler beim Speichern", type: .error))
        ToastView(toast: Toast(message: "Backup erfolgreich importiert", type: .info))
        ToastView(toast: Toast(message: "Gewichtungen summieren sich nicht auf 100%", type: .warning))
    }
    .padding()
}

