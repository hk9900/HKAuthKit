import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
#if canImport(UIKit)
import UIKit
#endif

public final class GoogleSignInService {
    public static let shared = GoogleSignInService()
    
    private init() {}
    
    public func signIn() async throws -> FirebaseAuth.User {
        #if canImport(UIKit)
        guard let presentingViewController = await getPresentingViewController() as? UIViewController else {
            throw AuthenticationError.googleSignInFailed
        }
        
        do {
            // Start the Google Sign-In flow
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw AuthenticationError.googleSignInFailed
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            let googleUser = result.user
            
            guard let idToken = googleUser.idToken?.tokenString else {
                throw AuthenticationError.googleSignInFailed
            }
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: googleUser.accessToken.tokenString)
            
            // Sign in to Firebase
            let authResult = try await Auth.auth().signIn(with: credential)
            let firebaseUser = authResult.user
            
            // Create or update user document in Firestore
            let fullName = googleUser.profile?.name ?? ""
            let email = googleUser.profile?.email ?? firebaseUser.email ?? ""
            let profileImageUrl = googleUser.profile?.imageURL(withDimension: 200)?.absoluteString
            
            try await createOrUpdateUserDocument(
                uid: firebaseUser.uid,
                email: email,
                fullName: fullName,
                profileImageUrl: profileImageUrl
            )
            
            return firebaseUser
            
        } catch {
            throw mapGoogleSignInError(error)
        }
        #else
        throw AuthenticationError.googleSignInFailed
        #endif
    }
    
    // MARK: - Private Helpers
    
    private func createOrUpdateUserDocument(uid: String, email: String, fullName: String, profileImageUrl: String?) async throws {
        let firestore = Firestore.firestore()
        let userDocumentRef = firestore.collection(AuthenticationConstants.FirestoreCollections.users).document(uid)
        
        // Check if document exists
        let documentSnapshot = try await userDocumentRef.getDocument()
        
        var userData: [String: Any] = [
            AuthenticationConstants.UserFields.id: uid,
            AuthenticationConstants.UserFields.email: email,
            AuthenticationConstants.UserFields.fullName: fullName,
            AuthenticationConstants.UserFields.updatedAt: Date()
        ]
        
        if let profileImageUrl = profileImageUrl {
            userData[AuthenticationConstants.UserFields.profileImageUrl] = profileImageUrl
        }
        
        if documentSnapshot.exists {
            // Update existing document
            try await userDocumentRef.updateData(userData)
        } else {
            // Create new document
            userData[AuthenticationConstants.UserFields.createdAt] = Date()
            userData[AuthenticationConstants.UserFields.isEmailVerified] = true // Google sign-in users are verified
            try await userDocumentRef.setData(userData)
        }
    }
    
    private func mapGoogleSignInError(_ error: Error) -> AuthenticationError {
        if let authError = error as? AuthErrorCode {
            switch authError.code {
            case .invalidEmail:
                return .invalidEmail
            case .userNotFound:
                return .userNotFound
            case .emailAlreadyInUse:
                return .emailAlreadyInUse
            case .networkError:
                return .networkError
            default:
                return .googleSignInFailed
            }
        }
        return .googleSignInFailed
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
