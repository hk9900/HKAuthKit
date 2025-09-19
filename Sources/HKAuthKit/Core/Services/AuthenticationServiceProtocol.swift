import Foundation

public protocol AuthenticationServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    
    // Authentication Methods
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, fullName: String) async throws -> User
    func signOut() throws
    
    // Password Management
    func resetPassword(email: String) async throws
    func updatePassword(currentPassword: String, newPassword: String) async throws
    
    // Social Authentication
    func signInWithGoogle() async throws -> User
    func signInWithApple() async throws -> User
    
    // User Management
    func updateProfile(fullName: String?, profileImageUrl: String?) async throws -> User
    func deleteAccount() async throws
    
    // Biometric Authentication
    func enableBiometricAuth() async throws
    func disableBiometricAuth() throws
    func authenticateWithBiometrics() async throws -> User
}
