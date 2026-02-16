import Foundation
import AuthenticationServices
internal import Combine
import CloudKit

@MainActor
class LogInViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldNavigateToWelcome: Bool = false

    private let cloudKitService = CloudKitService.shared

    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handleAppleResult(_ result: Result<ASAuthorization, Error>, session: AppSession) {
        isLoading = true
        errorMessage = nil

        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                fail(with: "Invalid Apple credential")
                return
            }
            Task { await handleAppleCredential(credential, session: session) }

        case .failure(let error):
            fail(with: error.localizedDescription)
        }
    }

    private func handleAppleCredential(_ credential: ASAuthorizationAppleIDCredential, session: AppSession) async {
        let userID = credential.user
        let email = credential.email ?? ""
        let givenName = credential.fullName?.givenName ?? ""
        let familyName = credential.fullName?.familyName ?? ""

        session.saveUserID(userID)
        session.givenName = givenName
        session.familyName = familyName
        session.email = email

        do {
            let user = User(
                givenName: givenName,
                familyName: familyName,
                email: email,
                appleUserID: userID
            )
            _ = try await cloudKitService.saveUserProfile(user)
            print("✅ Profile saved to CloudKit successfully")
        } catch {
            print("⚠️ CloudKit save failed:", error.localizedDescription)
        }

        isLoading = false
        shouldNavigateToWelcome = true  // ✅ Navigate to WelcomeView
    }

    private func fail(with message: String) {
        isLoading = false
        errorMessage = message
    }
}
