import SwiftUI
import FirebaseCore

@available(iOS 16.0, *)
public struct HKAuthKit {
    @MainActor
    public static func configure(
        with configuration: AuthenticationConfiguration
    ) {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Store configuration
        ConfigurationManager.shared.setConfiguration(configuration)
    }
    
    // MARK: - Service Access
    public static var authenticationService: AuthenticationServiceProtocol {
        FirebaseAuthenticationService.shared
    }
    
    @MainActor
    public static var configuration: AuthenticationConfiguration? {
        ConfigurationManager.shared.configuration
    }
    
    // MARK: - Utilities
    public static var validationUtilities: ValidationUtilities.Type {
        return ValidationUtilities.self
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