import Foundation

public struct ValidationUtilities {
    
    // MARK: - Email Validation
    public static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = AuthenticationConstants.Validation.emailRegex
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Password Validation
    public static func isValidPassword(_ password: String) -> Bool {
        return password.count >= AuthenticationConstants.Validation.minPasswordLength &&
               password.count <= AuthenticationConstants.Validation.maxPasswordLength
    }
    
    // MARK: - Name Validation
    public static func isValidName(_ name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.count >= AuthenticationConstants.Validation.minNameLength &&
               trimmedName.count <= AuthenticationConstants.Validation.maxNameLength
    }
    
    // MARK: - Password Match Validation
    public static func passwordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword && !password.isEmpty
    }
    
    // MARK: - Phone Number Validation
    public static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^[+]?[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    // MARK: - URL Validation
    public static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme != nil && url.host != nil
    }
}
