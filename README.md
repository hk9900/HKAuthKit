# HKAuthKit

A reusable SwiftUI authentication package with Firebase integration.

## Features

- **Email/Password Authentication**: Secure authentication with Firebase Auth
- **User Registration**: Create new accounts with validation
- **Password Reset**: Forgot password functionality with email reset
- **Social Login**: Google and Apple Sign-In integration (placeholders)
- **Form Validation**: Real-time validation for all input fields
- **Customizable UI**: Easy to customize colors, fonts, and styling
- **Toast Notifications**: User-friendly success and error messages
- **Accessibility**: Full VoiceOver support and accessibility labels

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/hk9900/HKAuthKit", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version and add to target

## Usage

### 1. Configure Firebase

First, set up Firebase in your project:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Download `GoogleService-Info.plist` and add it to your project
3. Enable Authentication and Firestore in Firebase Console

### 2. Configure HKAuthKit

```swift
import SwiftUI
import HKAuthKit

@main
struct MyApp: App {
    init() {
        let config = AuthenticationConfiguration(
            firebaseProjectId: "your-project-id",
            firebaseApiKey: "your-api-key",
            firebaseAppId: "your-app-id",
            appName: "My App",
            primaryColor: .blue,
            backgroundColor: .white
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

### 3. Use Authentication Views

```swift
import SwiftUI
import HKAuthKit

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var currentUser: User?
    
    var body: some View {
        if isAuthenticated {
            MainAppView(user: currentUser)
        } else {
            HKAuthKit.createLoginView(
                onSuccess: { user in
                    currentUser = user
                    isAuthenticated = true
                },
                onRegister: {
                    // Navigate to register
                }
            )
        }
    }
}
```

## Configuration Options

```swift
let config = AuthenticationConfiguration(
    // Firebase Configuration
    firebaseProjectId: "your-project-id",
    firebaseApiKey: "your-api-key",
    firebaseAppId: "your-app-id",
    
    // UI Configuration
    appName: "My App",
    appLogo: "app_logo",
    primaryColor: .blue,
    backgroundColor: .white,
    
    // Feature Flags
    enableGoogleSignIn: true,
    enableAppleSignIn: true,
    enableBiometricAuth: false,
    showSplashScreen: true,
    
    // Validation Rules
    minPasswordLength: 8,
    requireSpecialCharacters: false,
    requireNumbers: false,
    
    // Navigation
    splashScreenDuration: 3.0
)
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## Support

For support, please open an issue on GitHub or contact the development team.
