import Foundation

public enum AuthenticationConstants {
    // MARK: - Firebase Collections
    public enum FirestoreCollections {
        public static let users = "users"
        public static let userProfiles = "userProfiles"
        public static let userSettings = "userSettings"
    }
    
    // MARK: - User Document Fields
    public enum UserFields {
        public static let id = "id"
        public static let email = "email"
        public static let fullName = "fullName"
        public static let createdAt = "createdAt"
        public static let updatedAt = "updatedAt"
        public static let profileImageUrl = "profileImageUrl"
        public static let isEmailVerified = "isEmailVerified"
    }
    
    // MARK: - Validation Rules
    public enum Validation {
        public static let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        public static let minPasswordLength = 8
        public static let maxPasswordLength = 128
        public static let minNameLength = 2
        public static let maxNameLength = 50
    }
    
    // MARK: - Error Messages
    public enum ErrorMessages {
        public static let invalidEmail = "Please enter a valid email address"
        public static let passwordTooShort = "Password must be at least 8 characters"
        public static let passwordsDoNotMatch = "Passwords do not match"
        public static let nameRequired = "Please enter your full name"
        public static let termsNotAccepted = "Please accept the terms and conditions"
        public static let networkError = "Please check your internet connection"
        public static let unknownError = "An unexpected error occurred"
    }
    
    // MARK: - Success Messages
    public enum SuccessMessages {
        public static let loginSuccess = "Welcome back!"
        public static let registrationSuccess = "Account created successfully!"
        public static let passwordResetSent = "Password reset email sent!"
        public static let profileUpdated = "Profile updated successfully!"
    }
    
    // MARK: - Accessibility Identifiers
    public enum AccessibilityIdentifiers {
        public static let emailTextField = "emailTextField"
        public static let passwordTextField = "passwordTextField"
        public static let fullNameTextField = "fullNameTextField"
        public static let loginButton = "loginButton"
        public static let registerButton = "registerButton"
        public static let forgotPasswordButton = "forgotPasswordButton"
        public static let googleSignInButton = "googleSignInButton"
        public static let appleSignInButton = "appleSignInButton"
    }
    
    // MARK: - Animation Durations
    public enum AnimationDurations {
        public static let quick = 0.2
        public static let standard = 0.3
        public static let slow = 0.5
        public static let splashScreen = 3.0
    }
    
    // MARK: - Toast Durations
    public enum ToastDurations {
        public static let short = 2.0
        public static let medium = 3.0
        public static let long = 5.0
    }
}
