import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif

public final class FirebaseAuthenticationService: AuthenticationServiceProtocol {
    public static let shared = FirebaseAuthenticationService()
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    private init() {}
    
    public var currentUser: FirebaseAuth.User? {
        return auth.currentUser
    }
    
    public var isAuthenticated: Bool {
        auth.currentUser != nil
    }
    
    // MARK: - Email/Password Authentication
    
    public func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return result.user
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    public func signUp(email: String, password: String, fullName: String) async throws -> FirebaseAuth.User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            try await changeRequest.commitChanges()
            
            return result.user
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    public func signOut() throws {
        do {
            try auth.signOut()
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Password Management
    
    public func resetPassword(email: String) async throws {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    public func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = auth.currentUser else {
            throw AuthenticationError.userNotFound
        }
        
        do {
            // Re-authenticate user
            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
            try await user.reauthenticate(with: credential)
            
            // Update password
            try await user.updatePassword(to: newPassword)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Social Authentication
    
    public func signInWithGoogle() async throws -> FirebaseAuth.User {
        return try await GoogleSignInService.shared.signIn()
    }
    
    public func signInWithApple() async throws -> FirebaseAuth.User {
        #if canImport(AuthenticationServices) && canImport(UIKit)
            do {
                // Create Apple ID credential request
                let nonce = randomNonceString()
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
                request.nonce = sha256(nonce)
                
                print("🍎 Starting Apple Sign-In with nonce: \(nonce)")
            
            // Create authorization controller
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            // Create delegate to handle the response
            let delegate = await AppleSignInDelegate(nonce: nonce)
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            
            // Present the authorization controller
            authorizationController.performRequests()
            
            // Wait for the result
            let result = try await delegate.result
            
                guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential else {
                    print("🍎 Apple Sign-In failed: Invalid credential type")
                    throw AuthenticationError.appleSignInFailed
                }
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("🍎 Apple Sign-In failed: No identity token")
                    throw AuthenticationError.appleSignInFailed
                }
                
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("🍎 Apple Sign-In failed: Could not convert identity token to string")
                    throw AuthenticationError.appleSignInFailed
                }
                
                print("🍎 Apple Sign-In credential received - User ID: \(appleIDCredential.user), Email: \(appleIDCredential.email ?? "Hidden/Not provided")")
            
                // Create Firebase credential using OAuthProvider
                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, 
                                                              rawNonce: nonce, 
                                                              fullName: appleIDCredential.fullName)
                
                print("🍎 Created Firebase credential for Apple Sign-In")
            
            // Sign in to Firebase
            let authResult = try await auth.signIn(with: credential)
            print("🍎 Successfully signed in to Firebase with Apple credential")
            let firebaseUser = authResult.user
            
            // Extract user information from Apple ID credential
            let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            // Handle email - Apple ID credential email might be nil if user chose "Hide my email"
            let email: String
            if let appleEmail = appleIDCredential.email, !appleEmail.isEmpty {
                email = appleEmail
            } else if let firebaseEmail = firebaseUser.email, !firebaseEmail.isEmpty {
                email = firebaseEmail
            } else {
                // If no email is available, use a placeholder or the user's ID
                email = "\(firebaseUser.uid)@privaterelay.appleid.com"
            }
            
            // Create or update user document in Firestore
            try await createOrUpdateUserDocument(
                uid: firebaseUser.uid,
                email: email,
                fullName: fullName.isEmpty ? "Apple User" : fullName,
                profileImageUrl: nil
            )
            
            print("🍎 Apple Sign-In completed successfully for user: \(fullName.isEmpty ? "Apple User" : fullName)")
            return firebaseUser
            
        } catch {
            print("🍎 Apple Sign-In error: \(error.localizedDescription)")
            
            // Handle specific Apple Sign-In errors
            if let authError = error as? ASAuthorizationError {
                switch authError.code {
                case .canceled:
                    print("🍎 Apple Sign-In was cancelled by user")
                    throw AuthenticationError.appleSignInCancelled
                case .failed:
                    print("🍎 Apple Sign-In failed")
                    throw AuthenticationError.appleSignInFailed
                case .invalidResponse:
                    print("🍎 Apple Sign-In invalid response")
                    throw AuthenticationError.appleSignInFailed
                case .notHandled:
                    print("🍎 Apple Sign-In not handled")
                    throw AuthenticationError.appleSignInFailed
                case .unknown:
                    print("🍎 Apple Sign-In unknown error")
                    throw AuthenticationError.appleSignInFailed
                @unknown default:
                    print("🍎 Apple Sign-In unknown default error")
                    throw AuthenticationError.appleSignInFailed
                }
            }
            
            // Check for Firebase Auth errors
            if let firebaseError = error as? AuthErrorCode {
                print("🍎 Firebase Auth error: \(firebaseError.localizedDescription)")
            }
            
            throw mapFirebaseError(error)
        }
        #else
        throw AuthenticationError.appleSignInFailed
        #endif
    }
    
    // MARK: - User Management
    
    public func updateProfile(fullName: String?, profileImageUrl: String?) async throws -> FirebaseAuth.User {
        guard let user = auth.currentUser else {
            throw AuthenticationError.userNotFound
        }
        
        do {
            let changeRequest = user.createProfileChangeRequest()
            if let fullName = fullName {
                changeRequest.displayName = fullName
            }
            if let profileImageUrl = profileImageUrl {
                changeRequest.photoURL = URL(string: profileImageUrl)
            }
            try await changeRequest.commitChanges()
            
            // Update Firestore document
            try await updateUserDocument(uid: user.uid, fullName: fullName, profileImageUrl: profileImageUrl)
            
            return user
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    public func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AuthenticationError.userNotFound
        }
        
        do {
            // Delete user document from Firestore
            try await firestore.collection(AuthenticationConstants.FirestoreCollections.users)
                .document(user.uid)
                .delete()
            
            // Delete user account
            try await user.delete()
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Biometric Authentication
    
    public func enableBiometricAuth() async throws {
        // Placeholder implementation
        throw AuthenticationError.unknown("Biometric authentication not implemented")
    }
    
    public func disableBiometricAuth() throws {
        // Placeholder implementation
        throw AuthenticationError.unknown("Biometric authentication not implemented")
    }
    
    public func authenticateWithBiometrics() async throws -> FirebaseAuth.User {
        // Placeholder implementation
        throw AuthenticationError.unknown("Biometric authentication not implemented")
    }
    
    // MARK: - Private Helpers
    
    
    private func updateUserDocument(uid: String, fullName: String?, profileImageUrl: String?) async throws {
        var updateData: [String: Any] = [
            AuthenticationConstants.UserFields.updatedAt: Date()
        ]
        
        if let fullName = fullName {
            updateData[AuthenticationConstants.UserFields.fullName] = fullName
        }
        
        if let profileImageUrl = profileImageUrl {
            updateData[AuthenticationConstants.UserFields.profileImageUrl] = profileImageUrl
        }
        
        try await firestore.collection(AuthenticationConstants.FirestoreCollections.users)
            .document(uid)
            .updateData(updateData)
    }
    
    private func mapFirebaseError(_ error: Error) -> AuthenticationError {
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .invalidEmail:
                return .invalidEmail
            case .userNotFound:
                return .userNotFound
            case .wrongPassword:
                return .wrongPassword
            case .emailAlreadyInUse:
                return .emailAlreadyInUse
            case .weakPassword:
                return .weakPassword
            case .networkError:
                return .networkError
            default:
                return .unknown(authError.localizedDescription)
            }
        }
        return .unknown(error.localizedDescription)
    }
    
    #if canImport(UIKit)
    @MainActor
    private func getPresentingViewController() async -> UIViewController? {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            return nil
        }
        
        return rootViewController
    }
    #else
    @MainActor
    private func getPresentingViewController() async -> Any? {
        return nil
    }
    #endif
    
    // MARK: - Apple Sign-In Helpers
    
    #if canImport(AuthenticationServices) && canImport(UIKit)
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func createOrUpdateUserDocument(uid: String, email: String, fullName: String, profileImageUrl: String?) async throws {
        let firestore = Firestore.firestore()
        let userDocumentRef = firestore.collection(AuthenticationConstants.FirestoreCollections.users).document(uid)
        
        let documentSnapshot = try await userDocumentRef.getDocument()
        
        var userData: [String: Any] = [
            AuthenticationConstants.UserFields.id: uid,
            AuthenticationConstants.UserFields.email: email,
            AuthenticationConstants.UserFields.fullName: fullName,
            AuthenticationConstants.UserFields.updatedAt: FieldValue.serverTimestamp()
        ]
        
        if let profileImageUrl = profileImageUrl {
            userData[AuthenticationConstants.UserFields.profileImageUrl] = profileImageUrl
        }
        
        if documentSnapshot.exists {
            try await userDocumentRef.updateData(userData)
        } else {
            userData[AuthenticationConstants.UserFields.createdAt] = FieldValue.serverTimestamp()
            try await userDocumentRef.setData(userData)
        }
    }
    #endif
}

// MARK: - Apple Sign-In Delegate

#if canImport(AuthenticationServices) && canImport(UIKit)
import CryptoKit

@MainActor
private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var continuation: CheckedContinuation<ASAuthorization, Error>?
    let nonce: String
    
    init(nonce: String) {
        self.nonce = nonce
        super.init()
    }
    
    var result: ASAuthorization {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation?.resume(returning: authorization)
        continuation = nil
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available for Apple Sign-In")
        }
        return window
    }
}
#endif
