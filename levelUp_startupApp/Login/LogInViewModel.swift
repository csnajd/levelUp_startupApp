import Foundation
import AuthenticationServices
internal import Combine
import CloudKit

@MainActor
class LogInViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // ✅ FIXED - Changed CloudKitService to CloudKitServices
    private let cloud = CloudKitServices.shared  // Use the singleton

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
        let email = credential.email
        let givenName = credential.fullName?.givenName
        let familyName = credential.fullName?.familyName

        // ✅ For now, just save to session without CloudKit
        // We'll implement CloudKit user profile saving later
        session.saveUserID(userID)
        session.givenName = givenName ?? ""
        session.familyName = familyName ?? ""
        session.email = email ?? ""

        isLoading = false
        
        /* TODO: Implement CloudKit user profile save when ready
        do {
            try await cloud.saveUserProfile(...)
        } catch {
            print("CloudKit error:", error)
        }
        */
    }

    private func fail(with message: String) {
        isLoading = false
        errorMessage = message
    }
}
