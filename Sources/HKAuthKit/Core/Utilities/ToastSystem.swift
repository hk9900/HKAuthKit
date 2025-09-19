import SwiftUI
import Combine

// MARK: - Toast Types
public enum ToastType {
    case success
    case error
    case warning
    case info
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

// MARK: - Toast Model
public struct Toast: Identifiable, Equatable {
    public let id = UUID()
    public let message: String
    public let type: ToastType
    public let duration: TimeInterval
    
    public init(message: String, type: ToastType, duration: TimeInterval = AuthenticationConstants.ToastDurations.medium) {
        self.message = message
        self.type = type
        self.duration = duration
    }
    
    public static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast Manager
@MainActor
public class ToastManager: ObservableObject {
    @Published public var toasts: [Toast] = []
    
    public init() {}
    
    public func show(_ message: String, type: ToastType = .info, duration: TimeInterval = AuthenticationConstants.ToastDurations.medium) {
        let toast = Toast(message: message, type: type, duration: duration)
        toasts.append(toast)
        
        // Auto-dismiss after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.dismiss(toast)
        }
    }
    
    public func dismiss(_ toast: Toast) {
        toasts.removeAll { $0.id == toast.id }
    }
    
    public func dismissAll() {
        toasts.removeAll()
    }
}

// MARK: - Toast View
public struct ToastView: View {
    let toast: Toast
    let onDismiss: () -> Void
    
    public init(toast: Toast, onDismiss: @escaping () -> Void) {
        self.toast = toast
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .foregroundColor(toast.type.color)
                .font(.system(size: 16, weight: .medium))
            
            Text(toast.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
}

// MARK: - Toast Overlay Modifier
public struct ToastOverlayModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                
                ForEach(toastManager.toasts) { toast in
                    ToastView(toast: toast) {
                        toastManager.dismiss(toast)
                    }
                }
            }
        }
    }
}

// MARK: - View Extension
public extension View {
    func toastOverlay(toastManager: ToastManager) -> some View {
        modifier(ToastOverlayModifier(toastManager: toastManager))
    }
}
