//
//  AppDestination.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 13/02/2026.
//


import SwiftUI
internal import Combine

enum AppDestination: Hashable {
    case welcome
    case createCommunity
    case joinCommunity
    case profile
}

@MainActor
class NavigationManager: ObservableObject {
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
    
    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    func showCreateCommunity() {
        showCreateCommunitySheet = true
    }
    
    func showJoinCommunity() {
        showJoinCommunitySheet = true
    }
    
    func showJoinCommunityWithCode(_ code: String) {
        pendingInviteCode = code
        showJoinCommunitySheet = true
    }
    
    func showProfile() {
        showProfileSheet = true
    }
    
    func dismissSheet() {
        showCreateCommunitySheet = false
        showJoinCommunitySheet = false
        showProfileSheet = false
        pendingInviteCode = nil
    }
}
