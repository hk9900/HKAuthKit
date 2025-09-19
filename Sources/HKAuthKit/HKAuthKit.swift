import SwiftUI
import FirebaseCore

@available(iOS 16.0, *)
public struct HKAuthKit {
    public static func configure(
        with configuration: AuthenticationConfiguration
    ) {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Store configuration
        ConfigurationManager.shared.setConfiguration(configuration)
    }
    
    public static func createLoginView(
        onSuccess: @escaping (User) -> Void,
        onRegister: @escaping () -> Void
    ) -> some View {
        LoginView(onSuccess: onSuccess, onRegister: onRegister)
    }
    
    public static func createRegisterView(
        onSuccess: @escaping (User) -> Void,
        onLogin: @escaping () -> Void
    ) -> some View {
        RegisterView(onSuccess: onSuccess, onLogin: onLogin)
    }
    
    public static func createForgotPasswordView(
        onSuccess: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) -> some View {
        ForgotPasswordView(onSuccess: onSuccess, onBack: onBack)
    }
    
    public static func createPasswordView(
        email: String,
        onSuccess: @escaping (User) -> Void,
        onForgotPassword: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) -> some View {
        PasswordView(
            email: email,
            onSuccess: onSuccess,
            onForgotPassword: onForgotPassword,
            onBack: onBack
        )
    }
}

// MARK: - Configuration Manager
@MainActor
public final class ConfigurationManager: ObservableObject {
    public static let shared = ConfigurationManager()
    
    @Published public private(set) var configuration: AuthenticationConfiguration?
    
    private init() {}
    
    public func setConfiguration(_ configuration: AuthenticationConfiguration) {
        self.configuration = configuration
    }
}