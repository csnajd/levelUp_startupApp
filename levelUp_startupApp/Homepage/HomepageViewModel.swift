import Foundation
internal import Combine

@MainActor
final class HomepageViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var communityName = "My Community"
    @Published var currentCommunity: Community?
    @Published var showBlockedProjects = false
    @Published var isLoadingProjects = false
    @Published var isLoadingCommunity = false
    @Published var errorMessage: String?
    
    private let cloudKitService = CloudKitService.shared
    
    init() {
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        await loadCommunityName()
        
        if let communityID = currentCommunity?.id {
            await loadProjects(communityID: communityID)
        }
    }
    
    func loadCommunityName() async {
        isLoadingCommunity = true
        errorMessage = nil
        
        do {
            let communities = try await cloudKitService.fetchUserCommunities()
            
            if let firstCommunity = communities.first {
                currentCommunity = firstCommunity
                communityName = firstCommunity.name
                print("✅ Loaded community: \(firstCommunity.name)")
            } else {
                communityName = "No Community"
                print("⚠️ No communities found for user")
            }
            
            isLoadingCommunity = false
        } catch {
            communityName = "Error Loading"
            errorMessage = "Failed to load community: \(error.localizedDescription)"
            isLoadingCommunity = false
            print("❌ Error loading community: \(error)")
        }
    }
    
    func loadProjects(communityID: String) async {
        isLoadingProjects = true
        errorMessage = nil
        
        do {
            projects = try await cloudKitService.fetchCommunityProjects(communityID: communityID)
            isLoadingProjects = false
            print("✅ Loaded \(projects.count) projects")
        } catch {
            errorMessage = "Failed to load projects: \(error.localizedDescription)"
            isLoadingProjects = false
            projects = []
            print("❌ Error loading projects: \(error)")
        }
    }
    
    func refresh() async {
        await loadInitialData()
    }
    
    var activeProjects: [Project] {
        projects.filter { !$0.isBlocked }
    }
    
    var blockedProjects: [Project] {
        projects.filter { $0.isBlocked }
    }
    
    var hasProjects: Bool {
        !projects.isEmpty
    }
    
    var hasActiveProjects: Bool {
        !activeProjects.isEmpty
    }
    
    var hasBlockedProjects: Bool {
        !blockedProjects.isEmpty
    }
}
