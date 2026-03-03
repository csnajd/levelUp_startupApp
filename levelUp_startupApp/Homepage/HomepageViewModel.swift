import Foundation
internal import Combine

@MainActor
final class HomepageViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var communityName: String
    @Published var showBlockedProjects = false
    @Published var isLoadingProjects = false
    @Published var errorMessage: String?

    private let communityID: String
    private let cloudKitService = CloudKitService.shared

    init(communityID: String, communityName: String) {
        self.communityID = communityID
        self.communityName = communityName
        Task {
            await loadProjects()
        }
    }

    func loadProjects() async {
        isLoadingProjects = true
        errorMessage = nil
        do {
            projects = try await cloudKitService.fetchCommunityProjects(communityID: communityID)
            print("✅ Loaded \(projects.count) projects for community \(communityID)")
        } catch {
            errorMessage = "Failed to load projects: \(error.localizedDescription)"
            projects = []
            print("❌ Error loading projects: \(error)")
        }
        isLoadingProjects = false
    }

    func refresh() async {
        await loadProjects()
    }

    var activeProjects: [Project] {
        projects.filter { !$0.isBlocked }
    }

    var blockedProjects: [Project] {
        projects.filter { $0.isBlocked }
    }

    var hasActiveProjects: Bool { !activeProjects.isEmpty }
    var hasBlockedProjects: Bool { !blockedProjects.isEmpty }
}
