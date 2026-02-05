//
//  LogInViewModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 05/02/2026.
//

import Foundation
import AuthenticationServices
internal import Combine

@MainActor
class WelcomeViewModel: ObservableObject {

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Configure Apple Request
    func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    // MARK: - Handle Apple Result
    func handleAppleResult(_ result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil

        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                fail(with: "Invalid Apple credential")
                return
            }

            handleAppleCredential(credential)

        case .failure(let error):
            fail(with: error.localizedDescription)
        }
    }

    // MARK: - Process Credential
    private func handleAppleCredential(_ credential: ASAuthorizationAppleIDCredential) {

        let userID = credential.user
        let email = credential.email
        let fullName = credential.fullName

        // 👇 For now we just simulate success
        // Later: send these to Firebase / backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Apple User ID:", userID)
            print("Email:", email ?? "No email")
            print("Name:", fullName?.givenName ?? "No name")

            self.isLoading = false
        }
    }

    // MARK: - Error helper
    private func fail(with message: String) {
        isLoading = false
        errorMessage = message
    }
}
