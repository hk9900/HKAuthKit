import Foundation

public enum AuthenticationError: LocalizedError, Equatable {
    case invalidEmail
    case wrongPassword
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case googleSignInFailed
    case appleSignInFailed
    case networkError
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "The email address is not valid."
        case .wrongPassword:
            return "The password is not valid or user has no password."
        case .userNotFound:
            return "There is no user record corresponding to this identifier. The user may have been deleted."
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .weakPassword:
            return "The password is too weak. Please choose a stronger password."
        case .googleSignInFailed:
            return "Google Sign-In failed."
        case .appleSignInFailed:
            return "Apple Sign-In failed."
        case .networkError:
            return "Please check your internet connection."
        case .unknown(let message):
            return message
        }
    }
    
    public static func == (lhs: AuthenticationError, rhs: AuthenticationError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidEmail, .invalidEmail),
             (.wrongPassword, .wrongPassword),
             (.userNotFound, .userNotFound),
             (.emailAlreadyInUse, .emailAlreadyInUse),
             (.weakPassword, .weakPassword),
             (.googleSignInFailed, .googleSignInFailed),
             (.appleSignInFailed, .appleSignInFailed),
             (.networkError, .networkError):
            return true
        case (.unknown(let lhsMessage), .unknown(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
