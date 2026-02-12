import Foundation
import AuthenticationServices
internal import Combine
import CloudKit

@MainActor
class LogInViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // ✅ Using shared singleton instance
    private let cloud = CloudKitServices.shared

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
            // 1) Save/Update in CloudKit
            try await cloud.upsertUserProfile(
                appleUserID: userID,
                email: email,
                givenName: givenName,
                familyName: familyName
            )

            // 2) Fetch to confirm + fill session
            let user = try await cloud.fetchUserProfile(appleUserID: userID)

            session.saveUserID(userID)
            session.givenName = user?.givenName ?? (givenName ?? "")
            session.familyName = user?.familyName ?? (familyName ?? "")
            session.email = user?.email ?? (email ?? "")

            isLoading = false

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
