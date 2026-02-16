import SwiftUI
internal import Combine

enum AppDestination: Hashable {
    case welcome
    case createCommunity
    case joinCommunity
    case profile
    case homepage(communityID: String, userID: String, userName: String)
}

@MainActor
final class NavigationManager: ObservableObject {

    @Published var path = NavigationPath()
    @Published var showCreateCommunitySheet = false
    @Published var showJoinCommunitySheet = false
    @Published var showProfileSheet = false
    @Published var pendingInviteCode: String?

    static let shared = NavigationManager()
    private init() {}

    func navigateTo(_ destination: AppDestination) {
        path.append(destination)
    }

    func navigateToHomepage(communityID: String, userID: String, userName: String) {
        // ✅ تصفير المسار بأمان
        path = NavigationPath()
        path.append(AppDestination.homepage(communityID: communityID, userID: userID, userName: userName))

    }

    func navigateBack() {
        if !path.isEmpty { path.removeLast() }
    }

    func navigateToRoot() {
        path = NavigationPath()
    }

    func showCreateCommunity() { showCreateCommunitySheet = true }
    func showJoinCommunity() { showJoinCommunitySheet = true }

    func showJoinCommunityWithCode(_ code: String) {
        pendingInviteCode = code
        showJoinCommunitySheet = true
    }

    func showProfile() { showProfileSheet = true }

    func dismissSheet() {
        showCreateCommunitySheet = false
        showJoinCommunitySheet = false
        showProfileSheet = false
        pendingInviteCode = nil
    }
}

