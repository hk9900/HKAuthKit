# HKAuthKit

A comprehensive authentication framework for iOS applications built with SwiftUI and Firebase. HKAuthKit provides a complete authentication solution with support for multiple authentication methods, built-in validation, and seamless Firebase integration.

## ✨ Features

- 🔐 **Multiple Authentication Methods**: Email/password, Google Sign-In, Apple Sign-In
- 🔥 **Firebase Integration**: Built on Firebase Auth with Firestore support
- 🛡️ **Type Safety**: Strongly typed authentication models and error handling
- 🎯 **Protocol-Based**: Easy to mock and test with protocol-based architecture
- 📱 **SwiftUI Ready**: Designed specifically for SwiftUI applications
- 🔧 **Configurable**: Flexible configuration for different environments
- ✅ **Validation**: Built-in email and password validation utilities
- 🚀 **Modern Swift**: Uses async/await and modern Swift concurrency
- 🌐 **Cross-Platform**: Supports iOS and macOS
- 🔗 **URL Handling**: Built-in URL scheme handling for social authentication

## 📋 Requirements

- iOS 16.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+
- Firebase project setup

## 🚀 Installation

### Swift Package Manager

Add HKAuthKit to your project using Swift Package Manager:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/hk9900/HKAuthKit`
3. Select the version you want to use
4. Click **Add Package**

### Local Development

For local development or testing:

1. Add HKAuthKit as a local package dependency
2. Point to your local HKAuthKit directory
3. Build and run your project

## 🎯 Quick Start

### 1. Configure Firebase and HKAuthKit

Set up Firebase and configure HKAuthKit in your app's entry point:

```swift
import SwiftUI
import HKAuthKit

@main
struct MyApp: App {
    init() {
        // Configure HKAuthKit (includes Firebase configuration)
        HKAuthKit.configure(with: AuthenticationConfiguration.default)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    _ = HKAuthKit.handleURL(url)
                }
        }
    }
}
```

### 2. Use Authentication Service

```swift
import SwiftUI
import HKAuthKit

@MainActor
class AuthViewModel: ObservableObject {
    private let authService = HKAuthKit.authenticationService
    @Published var user: User?
    @Published var isLoading = false
    
    func signIn(email: String, password: String) async {
        isLoading = true
        do {
            let user = try await authService.signIn(email: email, password: password)
            self.user = user
        } catch {
            print("Sign in failed: \(error)")
        }
        isLoading = false
    }
    
    func signUp(email: String, password: String, fullName: String) async {
        isLoading = true
        do {
            let user = try await authService.signUp(email: email, password: password, fullName: fullName)
            self.user = user
        } catch {
            print("Sign up failed: \(error)")
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        do {
            let user = try await authService.signInWithGoogle()
            self.user = user
        } catch {
            print("Google sign-in failed: \(error)")
        }
        isLoading = false
    }
    
    func signOut() async {
        do {
            try authService.signOut()
            self.user = nil
        } catch {
            print("Sign out failed: \(error)")
        }
    }
}
```

### 3. Create Authentication Views

```swift
import SwiftUI
import HKAuthKit

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Sign In") {
                Task {
                    await viewModel.signIn(email: email, password: password)
                }
            }
            .disabled(viewModel.isLoading)
            
            Button("Sign In with Google") {
                Task {
                    await viewModel.signInWithGoogle()
                }
            }
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
    }
}
```

## ⚙️ Configuration

### AuthenticationConfiguration

Configure HKAuthKit with your app's specific settings:

```swift
let config = AuthenticationConfiguration(
    firebaseProjectId: "your-project-id",
    firebaseApiKey: "your-api-key",
    firebaseAppId: "your-app-id",
    appName: "MyApp",
    appLogo: "app-logo",
    primaryColor: .blue,
    backgroundColor: Color(.systemBackground),
    enableGoogleSignIn: true,
    enableAppleSignIn: true,
    enableBiometricAuth: false,
    showSplashScreen: true,
    minPasswordLength: 8,
    requireSpecialCharacters: false,
    requireNumbers: false,
    splashScreenDuration: 3.0
)

HKAuthKit.configure(with: config)
```

### Configuration Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `firebaseProjectId` | `String` | Required | Your Firebase project ID |
| `firebaseApiKey` | `String` | Required | Your Firebase API key |
| `firebaseAppId` | `String` | Required | Your Firebase app ID |
| `appName` | `String` | Required | Your app name for user records |
| `appLogo` | `String?` | `nil` | Optional app logo identifier |
| `primaryColor` | `Color` | `.black` | Primary color for UI elements |
| `backgroundColor` | `Color` | Light gray | Background color for UI elements |
| `enableGoogleSignIn` | `Bool` | `true` | Enable Google Sign-In |
| `enableAppleSignIn` | `Bool` | `true` | Enable Apple Sign-In |
| `enableBiometricAuth` | `Bool` | `false` | Enable biometric authentication |
| `showSplashScreen` | `Bool` | `true` | Show splash screen |
| `minPasswordLength` | `Int` | `8` | Minimum password length |
| `requireSpecialCharacters` | `Bool` | `false` | Require special characters in password |
| `requireNumbers` | `Bool` | `false` | Require numbers in password |
| `splashScreenDuration` | `TimeInterval` | `3.0` | Splash screen duration |

## 🔐 Authentication Methods

### Email/Password Authentication

```swift
// Sign in
let user = try await authService.signIn(email: "user@example.com", password: "password123")

// Sign up
let user = try await authService.signUp(
    email: "user@example.com", 
    password: "password123", 
    fullName: "John Doe"
)

// Reset password
try await authService.resetPassword(email: "user@example.com")
```

### Google Sign-In

```swift
// Sign in with Google
let user = try await authService.signInWithGoogle()

// Ensure URL handling is set up in your app
.onOpenURL { url in
    _ = HKAuthKit.handleURL(url)
}
```

**Setup Requirements:**
1. Enable Google Sign-In in Firebase Console
2. Add your `GoogleService-Info.plist` to the project
3. Configure URL schemes in your app's Info.plist (handled automatically by HKAuthKit)

### Apple Sign-In

```swift
let user = try await authService.signInWithApple()
```

**Setup Requirements:**
1. Enable Apple Sign-In in Firebase Console
2. Configure Sign in with Apple capability in your app
3. Ensure bundle ID matches between Xcode project and Firebase configuration
4. Apple Sign-In supports "Hide my email" functionality automatically

## 👤 User Management

### User Model

```swift
public struct User: Codable, Identifiable {
    public let id: String
    public let email: String
    public let fullName: String
    public let profileImageURL: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    // Convenience initializer from Firebase User
    public init(from firebaseUser: FirebaseUser, fullName: String)
}
```

### User Operations

```swift
// Get current user
let currentUser = authService.currentUser

// Check authentication status
let isAuthenticated = authService.isAuthenticated

// Update user profile
try await authService.updateProfile(
    fullName: "New Name",
    profileImageUrl: "https://example.com/image.jpg"
)

// Delete user account
try await authService.deleteAccount()
```

## ✅ Validation Utilities

HKAuthKit includes comprehensive validation utilities:

```swift
import HKAuthKit

// Email validation
let isValidEmail = HKAuthKit.validationUtilities.isValidEmail("user@example.com")

// Password validation
let isValidPassword = HKAuthKit.validationUtilities.isValidPassword("password123")

// Name validation
let isValidName = HKAuthKit.validationUtilities.isValidName("John Doe")

// Password matching
let passwordsMatch = HKAuthKit.validationUtilities.passwordsMatch("password", "password")
```

### Validation Rules

- **Email**: RFC 5322 compliant email format
- **Password**: Minimum length, configurable complexity requirements
- **Name**: Non-empty string with reasonable length limits
- **Password Matching**: Exact string comparison for confirmation fields

## 🚨 Error Handling

HKAuthKit provides comprehensive error handling with specific error types:

```swift
import HKAuthKit

do {
    let user = try await authService.signIn(email: email, password: password)
} catch let error as AuthenticationError {
    switch error {
    case .invalidEmail:
        // Handle invalid email format
    case .userNotFound:
        // Handle user not found
    case .wrongPassword:
        // Handle incorrect password
    case .emailAlreadyInUse:
        // Handle email already registered
    case .weakPassword:
        // Handle weak password
    case .networkError:
        // Handle network connectivity issues
    case .googleSignInFailed:
        // Handle Google Sign-In failure
    case .googleSignInCancelled:
        // Handle Google Sign-In cancellation
    case .appleSignInFailed:
        // Handle Apple Sign-In failure
    case .appleSignInCancelled:
        // Handle Apple Sign-In cancellation
    case .appleSignInNotAvailable:
        // Handle Apple Sign-In not available
    case .userNotFound:
        // Handle user not found
    case .unknown(let message):
        // Handle unknown error with message
    }
} catch {
    // Handle other errors
    print("Unexpected error: \(error)")
}
```

## 🧪 Testing

HKAuthKit is designed to be easily testable with protocol-based architecture:

```swift
import HKAuthKit

// Create a mock authentication service
class MockAuthenticationService: AuthenticationServiceProtocol {
    var shouldSucceed = true
    var mockUser: User?
    
    func signIn(email: String, password: String) async throws -> User {
        if shouldSucceed {
            return mockUser ?? User(
                id: "1", 
                email: email, 
                fullName: "Test User", 
                profileImageURL: nil, 
                createdAt: Date(), 
                updatedAt: Date()
            )
        } else {
            throw AuthenticationError.invalidCredentials
        }
    }
    
    // Implement other required methods...
}

// Use in tests
let mockService = MockAuthenticationService()
let viewModel = AuthViewModel(authenticationService: mockService)
```

## 🏗️ Architecture

HKAuthKit follows clean architecture principles:

### Core Components

- **Models**: `User`, `AuthenticationError`, `AuthenticationConfiguration`
- **Services**: `AuthenticationServiceProtocol`, `FirebaseAuthenticationService`, `GoogleSignInService`
- **Utilities**: `ValidationUtilities` for input validation
- **Configuration**: `AuthenticationConfiguration`, `GoogleSignInConfiguration`
- **Constants**: `AuthenticationConstants` for Firestore field names and collections

### Service Layer

```swift
// Protocol-based service interface
public protocol AuthenticationServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, fullName: String) async throws -> User
    func signOut() throws
    func resetPassword(email: String) async throws
    func signInWithGoogle() async throws -> User
    func signInWithApple() async throws -> User
    func updateProfile(fullName: String?, profileImageUrl: String?) async throws -> User
    func deleteAccount() async throws
}

// Firebase implementation
public final class FirebaseAuthenticationService: AuthenticationServiceProtocol {
    // Implementation details...
}
```

## 🔒 Thread Safety

All public APIs are designed with thread safety in mind:

- Authentication operations are marked with appropriate concurrency attributes
- UI-related operations are marked with `@MainActor`
- Background operations use `async/await` patterns

## 📦 Dependencies

HKAuthKit manages its own dependencies:

- **Firebase Auth**: User authentication
- **Firebase Firestore**: User data storage
- **Firebase Storage**: Profile image storage
- **Google Sign-In for iOS**: Social authentication

## 🔧 Advanced Configuration

### Custom Configuration

```swift
// Create custom configuration
let customConfig = AuthenticationConfiguration(
    firebaseProjectId: "my-project",
    firebaseApiKey: "my-api-key",
    firebaseAppId: "my-app-id",
    appName: "MyApp",
    primaryColor: .purple,
    backgroundColor: .black,
    enableGoogleSignIn: true,
    enableAppleSignIn: false,
    minPasswordLength: 12,
    requireSpecialCharacters: true,
    requireNumbers: true
)

HKAuthKit.configure(with: customConfig)
```

### URL Scheme Handling

HKAuthKit automatically handles URL schemes for social authentication:

```swift
// In your app's main view
.onOpenURL { url in
    _ = HKAuthKit.handleURL(url)
}
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/hk9900/HKAuthKit/issues) page
2. Review Firebase documentation
3. Open a new issue with detailed information

## 🔄 Changelog

### Version 1.1.0
- ✅ Complete Apple Sign-In implementation with "Hide my email" support
- ✅ Fixed bundle ID validation and audience error handling
- ✅ Enhanced error handling with specific Apple Sign-In error types
- ✅ Improved debugging and logging capabilities
- ✅ Better email handling for Apple Sign-In privacy options
- ✅ Comprehensive error mapping for all authentication methods

### Version 1.0.0
- Initial release
- Email/password authentication
- Google Sign-In integration
- Apple Sign-In support
- Firebase integration
- Validation utilities
- Comprehensive error handling
- Cross-platform support

---

**Made with ❤️ for the SwiftUI community**