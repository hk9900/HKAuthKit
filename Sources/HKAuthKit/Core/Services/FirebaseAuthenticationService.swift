import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
#if canImport(UIKit)
import UIKit
#endif

public final class FirebaseAuthenticationService: AuthenticationServiceProtocol {
    public static let shared = FirebaseAuthenticationService()
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    private init() {}
    
    public var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        return User(from: firebaseUser, fullName: firebaseUser.displayName ?? "")
    }
    
    public var isAuthenticated: Bool {
        auth.currentUser != nil
    }
    
    // MARK: - Email/Password Authentication
    
    public func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            let user = try await fetchUserData(uid: result.user.uid)
            return user
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    public func signUp(email: String, password: String, fullName: String) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = fullName
            try await changeRequest.commitChanges()
            
            // Ensure user is properly authenticated before writing to Firestore
            guard let currentUser = auth.currentUser, currentUser.uid == result.user.uid else {
                throw AuthenticationError.unknown("User authentication failed")
            }
            
            // Create user document in Firestore
            let user = User(from: result.user, fullName: fullName)
            try await createUserDocument(user)
            
            return user
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
    
    public func signInWithGoogle() async throws -> User {
        return try await GoogleSignInService.shared.signIn()
    }
    
    public func signInWithApple() async throws -> User {
        // Placeholder implementation
        try await Task.sleep(nanoseconds: 1_200_000_000)
        throw AuthenticationError.appleSignInFailed
    }
    
    // MARK: - User Management
    
    public func updateProfile(fullName: String?, profileImageUrl: String?) async throws -> User {
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
            
            return User(from: user, fullName: fullName ?? user.displayName ?? "")
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
    
    public func authenticateWithBiometrics() async throws -> User {
        // Placeholder implementation
        throw AuthenticationError.unknown("Biometric authentication not implemented")
    }
    
    // MARK: - Private Helpers
    
    private func createUserDocument(_ user: User) async throws {
        let data: [String: Any] = [
            AuthenticationConstants.UserFields.id: user.id,
            AuthenticationConstants.UserFields.email: user.email,
            AuthenticationConstants.UserFields.fullName: user.fullName,
            AuthenticationConstants.UserFields.createdAt: user.createdAt,
            AuthenticationConstants.UserFields.updatedAt: user.updatedAt,
            AuthenticationConstants.UserFields.profileImageUrl: user.profileImageUrl ?? "",
            AuthenticationConstants.UserFields.isEmailVerified: user.isEmailVerified
        ]
        try await firestore.collection(AuthenticationConstants.FirestoreCollections.users)
            .document(user.id)
            .setData(data)
    }
    
    private func fetchUserData(uid: String) async throws -> User {
        let document = try await firestore.collection(AuthenticationConstants.FirestoreCollections.users)
            .document(uid)
            .getDocument()
        
        guard document.exists,
              let data = document.data() else {
            throw AuthenticationError.unknown("User data not found")
        }
        
        guard let id = data[AuthenticationConstants.UserFields.id] as? String,
              let email = data[AuthenticationConstants.UserFields.email] as? String,
              let fullName = data[AuthenticationConstants.UserFields.fullName] as? String else {
            throw AuthenticationError.unknown("Invalid user data format")
        }
        
        // Handle Firestore Timestamps
        let createdAt: Date
        let updatedAt: Date
        
        if let createdAtTimestamp = data[AuthenticationConstants.UserFields.createdAt] as? Timestamp {
            createdAt = createdAtTimestamp.dateValue()
        } else if let createdAtDate = data[AuthenticationConstants.UserFields.createdAt] as? Date {
            createdAt = createdAtDate
        } else {
            createdAt = Date()
        }
        
        if let updatedAtTimestamp = data[AuthenticationConstants.UserFields.updatedAt] as? Timestamp {
            updatedAt = updatedAtTimestamp.dateValue()
        } else if let updatedAtDate = data[AuthenticationConstants.UserFields.updatedAt] as? Date {
            updatedAt = updatedAtDate
        } else {
            updatedAt = Date()
        }
        
        let profileImageUrl = data[AuthenticationConstants.UserFields.profileImageUrl] as? String
        let isEmailVerified = data[AuthenticationConstants.UserFields.isEmailVerified] as? Bool ?? false
        
        return User(
            id: id,
            email: email,
            fullName: fullName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            profileImageUrl: profileImageUrl,
            isEmailVerified: isEmailVerified
        )
    }
    
    
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
}
