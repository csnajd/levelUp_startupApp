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
    @Published var communityName = "Code Lab"
    @Published var showBlockedProjects = false
    @Published var isLoadingProjects = false
    
    init() {
        loadProjects()
    }
    
    func loadProjects() {
        projects = ProjectData.emptyProjects
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
