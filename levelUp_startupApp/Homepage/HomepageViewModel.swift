//
//  HomepageViewModel.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

import Foundation
internal import Combine

@MainActor
class HomepageViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var communityName = "My Community"
    @Published var showBlockedProjects = false
    @Published var isLoadingProjects = false
    @Published var currentCommunity: Community?
    
    private let cloudKitService = CloudKitServices.shared
    
    init() {
        loadProjects()
        Task {
            await loadCommunityName()
        }
    }
    
    func loadProjects() {
        projects = ProjectData.emptyProjects
    }
    
    func loadCommunityName() async {
        do {
            let communities = try await cloudKitService.fetchUserCommunities()
            
            if let firstCommunity = communities.first {
                communityName = firstCommunity.name
                currentCommunity = firstCommunity
                print("✅ Loaded community: \(firstCommunity.name)")
            } else {
                communityName = "No Community"
                print("⚠️ No communities found for user")
            }
        } catch {
            communityName = "My Community"
            print("❌ Error loading community: \(error)")
        }
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
