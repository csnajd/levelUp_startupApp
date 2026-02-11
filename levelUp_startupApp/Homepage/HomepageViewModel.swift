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
    @Published var communityName = "Code Lab"  // This will come from CloudKit
    @Published var showBlockedProjects = false
    @Published var isLoadingProjects = false
    
    init() {
        loadProjects()
    }
    
    func loadProjects() {
        // Default: Empty state for new communities
        projects = ProjectData.emptyProjects  // ✅ Changed from dummyProjects to emptyProjects
        
        // TODO: Replace with CloudKit fetch when your friend finishes CreateCommunity
        // When CloudKit is ready, it will look like this:
        // isLoadingProjects = true
        // Task {
        //     do {
        //         projects = try await CloudKitService.shared.fetchProjects(for: communityID)
        //         isLoadingProjects = false
        //     } catch {
        //         print("Error loading projects: \(error)")
        //         isLoadingProjects = false
        //     }
        // }
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
