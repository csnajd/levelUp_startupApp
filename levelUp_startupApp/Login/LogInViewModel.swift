import Foundation
import AuthenticationServices
internal import Combine
import CloudKit

@MainActor
class LogInViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // ✅ Public عشان iCloud عندك ممتلئ (إذا فضّيتي iCloud بدّليها false)
    private let cloud = CloudKitService(containerID: nil, usePublicDB: true)

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

        do {
            // 1) Save/Update in CloudKit
            try await cloud.upsertUserProfile(
                appleUserID: userID,
                email: email,
                givenName: givenName,
                familyName: familyName
            )

            // 2) Fetch to confirm + fill session
            let record = try await cloud.fetchUserProfile(appleUserID: userID)

            session.saveUserID(userID)
            session.givenName = (record["givenName"] as? String) ?? (givenName ?? "")
            session.familyName = (record["familyName"] as? String) ?? (familyName ?? "")
            session.email = (record["email"] as? String) ?? (email ?? "")

            isLoading = false

        } catch {
            // إذا فشل CloudKit، على الأقل لا يوقف اللوقين
            print("❌ CloudKit failed:", error.localizedDescription)

            session.saveUserID(userID)
            session.givenName = givenName ?? ""
            session.familyName = familyName ?? ""
            session.email = email ?? ""

            isLoading = false
        }
    }

    private func fail(with message: String) {
        isLoading = false
        errorMessage = message
    }
}
