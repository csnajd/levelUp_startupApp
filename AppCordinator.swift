//
//  AppCordinator.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 10/02/2026.
//

//
//  AppCoordinator.swift
//  levelUp_startupApp
//
//  Integration Example - Shows how to connect Login to Welcome View
//

import SwiftUI

// MARK: - App State Manager
class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var selectedCommunity: Community?
    
    enum Screen {
        case login
        case welcome
        case communityHome
    }
    
    @Published var currentScreen: Screen = .login
    
    func handleLoginSuccess(user: User) {
        self.currentUser = user
        self.isAuthenticated = true
        self.currentScreen = .welcome
    }
    
    func handleCommunityCreated(_ community: Community) {
        self.selectedCommunity = community
        self.currentScreen = .communityHome
    }
    
    func handleCommunityJoined(_ community: Community) {
        self.selectedCommunity = community
        self.currentScreen = .communityHome
    }
    
    func logout() {
        self.currentUser = nil
        self.isAuthenticated = false
        self.selectedCommunity = nil
        self.currentScreen = .login
    }
}

// MARK: - User Model (if you don't have one already)
struct User: Identifiable, Codable {
    var id: String
    var email: String
    var name: String
    var organizationID: String
}

// MARK: - Main App View Structure
struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        Group {
            switch coordinator.currentScreen {
            case .login:
                LogInView()
                    .environmentObject(coordinator)
                
            case .welcome:
                WelcomeView()
                    .environmentObject(coordinator)
                
            case .communityHome:
                HomepageView() // Your existing homepage
                    .environmentObject(coordinator)
            }
        }
    }
}

// MARK: - Updated Login View Example
// This shows how to modify your existing LogInView to integrate with the coordinator

/*
struct LogInView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = LogInViewModel()
    
    var body: some View {
        // Your existing login UI
        
        Button("Login") {
            Task {
                await viewModel.login(email: email, password: password)
            }
        }
        .onChange(of: viewModel.loginSuccess) { success in
            if success, let user = viewModel.currentUser {
                coordinator.handleLoginSuccess(user: user)
            }
        }
    }
}
*/

// MARK: - Updated Welcome View Example
// This shows how to modify WelcomeView to integrate with the coordinator

/*
struct WelcomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel = WelcomeViewModel()
    @State private var showCreateCommunity = false
    @State private var showJoinCommunity = false
    
    var body: some View {
        NavigationStack {
            // ... your UI
            
            Button("Create a Community") {
                showCreateCommunity = true
            }
            
            .navigationDestination(isPresented: $showCreateCommunity) {
                CreateCommunityView()
                    .environmentObject(coordinator)
            }
            .navigationDestination(isPresented: $showJoinCommunity) {
                JoinCommunityView()
                    .environmentObject(coordinator)
            }
        }
    }
}
*/

// MARK: - App Entry Point
/*
@main
struct levelUp_startupAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
*/

// MARK: - Alternative Navigation Approach Using NavigationPath
// If you prefer using NavigationPath for more complex navigation

class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    enum Destination: Hashable {
        case welcome
        case createCommunity
        case joinCommunity
        case communityHome(String) // Use community ID instead of Community object
        case project(String)
        
        // Hashable conformance
        func hash(into hasher: inout Hasher) {
            switch self {
            case .welcome:
                hasher.combine("welcome")
            case .createCommunity:
                hasher.combine("createCommunity")
            case .joinCommunity:
                hasher.combine("joinCommunity")
            case .communityHome(let id):
                hasher.combine("communityHome")
                hasher.combine(id)
            case .project(let id):
                hasher.combine("project")
                hasher.combine(id)
            }
        }
        
        static func == (lhs: Destination, rhs: Destination) -> Bool {
            switch (lhs, rhs) {
            case (.welcome, .welcome): return true
            case (.createCommunity, .createCommunity): return true
            case (.joinCommunity, .joinCommunity): return true
            case (.communityHome(let id1), .communityHome(let id2)): return id1 == id2
            case (.project(let id1), .project(let id2)): return id1 == id2
            default: return false
            }
        }
    }
    
    func navigate(to destination: Destination) {
        path.append(destination)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

/*
// Usage with NavigationPath:
struct RootView: View {
    @StateObject private var coordinator = NavigationCoordinator()
    @StateObject private var appState = AppState() // Holds actual community objects
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            LogInView()
                .navigationDestination(for: NavigationCoordinator.Destination.self) { destination in
                    switch destination {
                    case .welcome:
                        WelcomeView()
                    case .createCommunity:
                        CreateCommunityView()
                    case .joinCommunity:
                        JoinCommunityView()
                    case .communityHome(let communityID):
                        // Fetch community by ID from appState or pass ID to view
                        if let community = appState.communities.first(where: { $0.id == communityID }) {
                            HomepageView(community: community)
                        }
                    case .project(let projectID):
                        ProjectDetailView(projectID: projectID)
                    }
                }
        }
        .environmentObject(coordinator)
        .environmentObject(appState)
    }
}
*/

// MARK: - Checking User Community Status on Launch

extension WelcomeViewModel {
    /// Call this when WelcomeView appears to check if user already has communities
    func checkUserCommunityStatus() async {
        await fetchUserCommunities()
        
        // If user has communities, you might want to auto-navigate to the first one
        // or show a picker if they have multiple
        if let firstCommunity = userCommunities.first {
            // Option 1: Auto-navigate to their community
            // coordinator.handleCommunityJoined(firstCommunity)
            
            // Option 2: Show community picker if multiple exist
            // showCommunityPicker = userCommunities.count > 1
        }
    }
}

// MARK: - Deep Linking Support for Invite Links
// Handle invite links like "levelup://join/ABC12345"

class DeepLinkHandler: ObservableObject {
    @Published var inviteCode: String?
    
    func handle(url: URL) {
        guard url.scheme == "levelup",
              url.host == "join",
              url.pathComponents.count > 1 else {
            return
        }
        
        let code = url.pathComponents[1]
        self.inviteCode = code
    }
}

/*
// Usage in your App:
@main
struct levelUp_startupAppApp: App {
    @StateObject private var deepLinkHandler = DeepLinkHandler()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deepLinkHandler)
                .onOpenURL { url in
                    deepLinkHandler.handle(url: url)
                }
        }
    }
}

// In JoinCommunityView:
struct JoinCommunityView: View {
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler
    @State private var inviteCode = ""
    
    var body: some View {
        // ... UI
        .onAppear {
            if let code = deepLinkHandler.inviteCode {
                inviteCode = code
                deepLinkHandler.inviteCode = nil // Clear after using
            }
        }
    }
}
*/
