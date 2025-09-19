import Foundation
import FirebaseCore
import GoogleSignIn

public final class GoogleSignInConfiguration {
    public static let shared = GoogleSignInConfiguration()
    
    private init() {}
    
    public func configure() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            print("⚠️ GoogleService-Info.plist not found or CLIENT_ID missing")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        print("🔐 Google Sign-In configured successfully")
    }
    
    public func handleURL(_ url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
