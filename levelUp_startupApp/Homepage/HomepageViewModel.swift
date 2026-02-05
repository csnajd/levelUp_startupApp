//
//  HomepageViewModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

import Foundation
import Combine
import CloudKit
import SwiftUI

@MainActor
final class HomepageViewModel: ObservableObject {

    @Published var projects: [HomepageProject] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let cloud = CloudKitService.shared

    func load() {
        isLoading = true
        errorMessage = nil

        cloud.fetchProjects { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let items):
                    self.projects = items
                case .failure(let err):
                    self.errorMessage = self.prettyCloudKitError(err)
                }
            }
        }
    }

    func addProject(title: String) {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        cloud.createProject(title: clean) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success:
                    self.load()
                case .failure(let err):
                    self.errorMessage = self.prettyCloudKitError(err)
                }
            }
        }
    }

    func delete(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let item = projects[index]

        isLoading = true
        errorMessage = nil

        cloud.deleteProject(id: item.id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success:
                    self.projects.remove(at: index)
                case .failure(let err):
                    self.errorMessage = self.prettyCloudKitError(err)
                }
            }
        }
    }

    // MARK: - Better Error
    private func prettyCloudKitError(_ error: Error) -> String {
        // iCloud storage full / quota exceeded يظهر كثير عندك
        let ns = error as NSError
        if ns.domain == CKError.errorDomain {
            if let ck = CKError(_nsError: ns) as CKError? {
                switch ck.code {
                case .quotaExceeded:
                    return "iCloud storage / CloudKit quota exceeded. فضّي iCloud أو جرّبي بحساب iCloud ثاني."
                case .notAuthenticated:
                    return "You are not signed into iCloud. سجّلي دخول iCloud بالجهاز."
                case .networkUnavailable, .networkFailure:
                    return "Network issue. تأكدي من النت."
                default:
                    break
                }
            }
        }
        return error.localizedDescription
    }
}

#Preview {
    HomepageView()
}
