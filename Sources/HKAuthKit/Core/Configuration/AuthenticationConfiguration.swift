import SwiftUI
import Foundation

public struct AuthenticationConfiguration {
    // Firebase Configuration
    public let firebaseProjectId: String
    public let firebaseApiKey: String
    public let firebaseAppId: String
    
    // UI Configuration
    public let appName: String
    public let appLogo: String?
    public let primaryColor: Color
    public let backgroundColor: Color
    
    // Feature Flags
    public let enableGoogleSignIn: Bool
    public let enableAppleSignIn: Bool
    public let enableBiometricAuth: Bool
    public let showSplashScreen: Bool
    
    // Validation Rules
    public let minPasswordLength: Int
    public let requireSpecialCharacters: Bool
    public let requireNumbers: Bool
    
    // Navigation
    public let splashScreenDuration: TimeInterval
    
    public init(
        firebaseProjectId: String,
        firebaseApiKey: String,
        firebaseAppId: String,
        appName: String,
        appLogo: String? = nil,
        primaryColor: Color = .black,
        backgroundColor: Color = Color(red: 0.95, green: 0.95, blue: 0.95),
        enableGoogleSignIn: Bool = true,
        enableAppleSignIn: Bool = true,
        enableBiometricAuth: Bool = false,
        showSplashScreen: Bool = true,
        minPasswordLength: Int = 8,
        requireSpecialCharacters: Bool = false,
        requireNumbers: Bool = false,
        splashScreenDuration: TimeInterval = 3.0
    ) {
        self.firebaseProjectId = firebaseProjectId
        self.firebaseApiKey = firebaseApiKey
        self.firebaseAppId = firebaseAppId
        self.appName = appName
        self.appLogo = appLogo
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.enableGoogleSignIn = enableGoogleSignIn
        self.enableAppleSignIn = enableAppleSignIn
        self.enableBiometricAuth = enableBiometricAuth
        self.showSplashScreen = showSplashScreen
        self.minPasswordLength = minPasswordLength
        self.requireSpecialCharacters = requireSpecialCharacters
        self.requireNumbers = requireNumbers
        self.splashScreenDuration = splashScreenDuration
    }
}
