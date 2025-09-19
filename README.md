# HKAuthKit

A comprehensive authentication framework for iOS applications built with SwiftUI and Firebase.

## Features

- 🔐 **Multiple Authentication Methods**: Email/password, Google Sign-In, Apple Sign-In
- 🔥 **Firebase Integration**: Built on Firebase Auth with Firestore support
- 🛡️ **Type Safety**: Strongly typed authentication models and error handling
- 🎯 **Protocol-Based**: Easy to mock and test with protocol-based architecture
- 📱 **SwiftUI Ready**: Designed specifically for SwiftUI applications
- 🔧 **Configurable**: Flexible configuration for different environments
- ✅ **Validation**: Built-in email and password validation utilities
- 🚀 **Modern Swift**: Uses async/await and modern Swift concurrency

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+
- Firebase project setup

## Installation

### Swift Package Manager

Add HKAuthKit to your project using Swift Package Manager:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/hk9900/HKAuthKit`
3. Select the version you want to use
4. Click **Add Package**

## Quick Start

### 1. Configure Firebase

First, set up Firebase in your project:

1. Add your `GoogleService-Info.plist` to your Xcode project
2. Configure Firebase in your app's entry point:

```swift
import SwiftUI
import FirebaseCore
import HKAuthKit

@main
struct MyApp: App {
    init() {
        FirebaseApp.configure()
        
        // Configure HKAuthKit
        let config = AuthenticationConfiguration(
            firebaseProjectId: "your-project-id",
            firebaseApiKey: "your-api-key",
            firebaseAppId: "your-app-id",
            appName: "MyApp",
            primaryColor: .blue,
            backgroundColor: Color(.systemBackground)
        )
        
        HKAuthKit.configure(with: config)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
    
    func signOut() async {
        do {
            try await authService.signOut()
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
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
    }
}
```

## Configuration

### AuthenticationConfiguration

| Property | Type | Description |
|----------|------|-------------|
| `firebaseProjectId` | `String` | Your Firebase project ID |
| `firebaseApiKey` | `String` | Your Firebase API key |
| `firebaseAppId` | `String` | Your Firebase app ID |
| `appName` | `String` | Your app name for user records |
| `primaryColor` | `Color` | Primary color for UI elements |
| `backgroundColor` | `Color` | Background color for UI elements |

## Authentication Methods

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
let user = try await authService.signInWithGoogle()
```

### Apple Sign-In

```swift
let user = try await authService.signInWithApple()
```

## User Management

### User Model

```swift
public struct User: Codable, Identifiable {
    public let id: String
    public let email: String
    public let fullName: String
    public let profileImageURL: String?
    public let createdAt: Date
    public let updatedAt: Date
}
```

### User Operations

```swift
// Get current user
let currentUser = authService.currentUser

// Update user profile
try await authService.updateUserProfile(fullName: "New Name")

// Delete user account
try await authService.deleteUser()
```

## Validation Utilities

HKAuthKit includes built-in validation utilities:

```swift
import HKAuthKit

// Email validation
let isValidEmail = ValidationUtilities.isValidEmail("user@example.com")

// Password validation
let isValidPassword = ValidationUtilities.isValidPassword("password123")

// Name validation
let isValidName = ValidationUtilities.isValidName("John Doe")

// Password matching
let passwordsMatch = ValidationUtilities.passwordsMatch("password", "password")
```

## Error Handling

HKAuthKit provides comprehensive error handling:

```swift
import HKAuthKit

do {
    let user = try await authService.signIn(email: email, password: password)
} catch let error as AuthenticationError {
    switch error {
    case .invalidCredentials:
        // Handle invalid credentials
    case .userNotFound:
        // Handle user not found
    case .emailAlreadyInUse:
        // Handle email already in use
    case .weakPassword:
        // Handle weak password
    case .networkError:
        // Handle network error
    case .unknown(let message):
        // Handle unknown error
    }
} catch {
    // Handle other errors
}
```

## Testing

HKAuthKit is designed to be easily testable:

```swift
import HKAuthKit

// Create a mock authentication service
class MockAuthenticationService: AuthenticationServiceProtocol {
    var shouldSucceed = true
    var mockUser: User?
    
    func signIn(email: String, password: String) async throws -> User {
        if shouldSucceed {
            return mockUser ?? User(id: "1", email: email, fullName: "Test User", profileImageURL: nil, createdAt: Date(), updatedAt: Date())
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

## Architecture

HKAuthKit follows a clean architecture pattern:

- **Models**: `User`, `AuthenticationError`, `AuthenticationConfiguration`
- **Services**: `AuthenticationServiceProtocol`, `FirebaseAuthenticationService`
- **Utilities**: `ValidationUtilities` for input validation
- **Configuration**: Centralized configuration management

## Thread Safety

All public APIs are marked with `@MainActor` to ensure thread safety. Authentication operations should be performed on the main thread.

## Dependencies

- Firebase Auth
- Firebase Firestore
- Firebase Storage
- Google Sign-In for iOS

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any issues or have questions, please open an issue on GitHub.

---

Made with ❤️ for the SwiftUI community