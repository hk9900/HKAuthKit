import Foundation

public struct User: Codable, Identifiable, Equatable {
    public let id: String
    public let email: String
    public let fullName: String
    public let createdAt: Date
    public let updatedAt: Date
    public let profileImageUrl: String?
    public let isEmailVerified: Bool
    
    public init(
        id: String,
        email: String,
        fullName: String,
        createdAt: Date,
        updatedAt: Date,
        profileImageUrl: String? = nil,
        isEmailVerified: Bool = false
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.profileImageUrl = profileImageUrl
        self.isEmailVerified = isEmailVerified
    }
    
    public init(from firebaseUser: FirebaseAuth.User, fullName: String) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.fullName = fullName
        self.createdAt = firebaseUser.metadata.creationDate ?? Date()
        self.updatedAt = Date()
        self.profileImageUrl = firebaseUser.photoURL?.absoluteString
        self.isEmailVerified = firebaseUser.isEmailVerified
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
