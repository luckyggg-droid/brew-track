import FirebaseAuth
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var listenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        user = Auth.auth().currentUser
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
            }
        }
    }

    deinit {
        if let listenerHandle {
            Auth.auth().removeStateDidChangeListener(listenerHandle)
        }
    }

    var isSignedIn: Bool { user != nil }
    var displayEmail: String { user?.email ?? "Cafe Manager" }

    func signIn() {
        guard validateFields() else { return }
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: trimmedEmail, password: password) { [weak self] _, error in
            Task { @MainActor in
                self?.isLoading = false
                if let error {
                    self?.errorMessage = Self.friendlyMessage(for: error)
                }
            }
        }
    }

    func createAccount() {
        guard validateFields() else { return }
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: trimmedEmail, password: password) { [weak self] _, error in
            Task { @MainActor in
                self?.isLoading = false
                if let error {
                    self?.errorMessage = Self.friendlyMessage(for: error)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            email = ""
            password = ""
            errorMessage = nil
        } catch {
            errorMessage = "Could not sign out. Please try again."
        }
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func validateFields() -> Bool {
        errorMessage = nil

        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            errorMessage = "Enter a valid email address."
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        return true
    }

    private static func friendlyMessage(for error: Error) -> String {
        let code = AuthErrorCode(rawValue: (error as NSError).code)

        switch code {
        case .emailAlreadyInUse:
            return "That email already has an account. Try signing in."
        case .wrongPassword, .invalidCredential:
            return "Email or password is incorrect."
        case .userNotFound:
            return "No account found for that email."
        case .networkError:
            return "Network error. Check your connection and try again."
        case .weakPassword:
            return "Use a stronger password with at least 6 characters."
        default:
            return error.localizedDescription
        }
    }
}
