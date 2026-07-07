import Foundation
import Observation

// MARK: - SignInViewModel
@MainActor
@Observable
final class SignInViewModel {
    var email = ""
    var password = ""
    var isAuthenticating = false
    var authError: String?
    var isAuthenticated = false

    var isEmailValid: Bool {
        Self.isValidEmail(email)
    }
    var isPasswordValid: Bool {
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var isFormValid: Bool {
        isEmailValid && isPasswordValid
    }

    // MARK: - Authentication
    func signIn() async {
        guard isFormValid else { return }
        authError = nil
        isAuthenticating = true

        do {
            let users = try await UserServices.fetchUsers()
            let match = users.first {
                $0.fields.email.caseInsensitiveCompare(email) == .orderedSame &&
                $0.fields.password == password
            }

            isAuthenticating = false
            if let match {
                CurrentUserStore.shared.signIn(
                    id: match.id,
                    name: match.fields.name,
                    email: match.fields.email
                )
                isAuthenticated = true
            } else {
                authError = "Incorrect email or password."
            }
        } catch {
            isAuthenticating = false
            authError = "Couldn't connect. Please try again."
        }
    }

    // MARK: - Validation
    private static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let pattern = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
}
