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
    @Published var selectedCommunity: Community?
    
    private let cloudKitService = CloudKitServices.shared
    
    init() {
        loadProjects()
    }
    
    func loadProjects() {
        // Default: Empty state for new communities
        projects = ProjectData.emptyProjects
        
        // If you have a selected community, load its name
        if let community = selectedCommunity {
            communityName = community.name
            
            // TODO: Uncomment when ready to fetch from CloudKit
            // Task {
            //     await fetchProjectsFromCloudKit(communityID: community.id)
            // }
        }
    }
    
    func fetchProjectsFromCloudKit(communityID: String) async {
        isLoadingProjects = true
        
        do {
            projects = try await cloudKitService.fetchCommunityProjects(communityID: communityID)
            isLoadingProjects = false
        } catch {
            print("Error loading projects: \(error)")
            isLoadingProjects = false
            // Fall back to empty state
            projects = []
        }
    }
    
    func setCommunity(_ community: Community) {
        selectedCommunity = community
        communityName = community.name
        loadProjects()
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
