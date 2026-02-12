//
//  HomepageView.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//
import SwiftUI

struct HomepageView: View {
    @StateObject private var viewModel = HomepageViewModel()
    @State private var showMenu = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 0) {
                        HStack {
                            Text(viewModel.communityName)
                                .font(.system(size: 32, weight: .bold))
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showMenu.toggle()
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        Divider()
                            .background(Color("primary"))
                            .frame(height: 2)
                    }
                    .background(Color.white)
                    
                    ScrollView {
                        VStack(spacing: 20) {  // ✅ Changed from 16 to 20
                            // Create Project Button
                            Button(action: {
                                // Navigate to create project
                            }) {
                                HStack {
                                    Text("Create Project")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    Text("+")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color("primary2"))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color("primary"), lineWidth: 2)
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)  // ✅ Added top padding
                            
                            // Active Projects Section
                            if viewModel.hasActiveProjects {
                                ForEach(viewModel.activeProjects) { project in
                                    ProjectCard(project: project)
                                        .padding(.horizontal, 20)
                                }
                            } else {
                                EmptyProjectCard()
                                    .padding(.horizontal, 20)
                            }
                            
                            // Pending Tasks Section
                            VStack(spacing: 0) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.showBlockedProjects.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text("Pending")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Image(systemName: viewModel.showBlockedProjects ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.black)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 28)
                                            .fill(Color("primary2"))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(Color("primary"), lineWidth: 2)
                                    )
                                }
                                .padding(.horizontal, 20)
                                
                                if viewModel.showBlockedProjects {
                                    if viewModel.hasBlockedProjects {
                                        VStack(spacing: 0) {
                                            ForEach(Array(viewModel.blockedProjects.enumerated()), id: \.element.id) { index, project in
                                                BlockedProjectRow(project: project)
                                                
                                                if index < viewModel.blockedProjects.count - 1 {
                                                    Divider()
                                                        .padding(.leading, 70)
                                                }
                                            }
                                        }
                                        .background(Color("grey"))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        .padding(.horizontal, 20)
                                        .padding(.top, 8)  // ✅ Changed from 4 to 8
                                    } else {
                                        VStack(spacing: 8) {
                                            Text("No pending tasks")
                                                .font(.system(size: 16))
                                                .foregroundColor(.gray)
                                            
                                            Text("Tasks that need attention will appear here")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray.opacity(0.7))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 32)
                                        .background(Color("grey"))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                        .padding(.horizontal, 20)
                                        .padding(.top, 8)  // ✅ Changed from 4 to 8
                                    }
                                }
                            }
                            
                            Spacer(minLength: 100)
                        }
                    }
                    .background(Color.white)
                    
                    // Bottom Tab Bar
                    Divider()
                    
                    HStack(spacing: 0) {
                        TabBarItem(icon: "house.fill", title: "Home", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabBarItem(icon: "calendar", title: "Meetings", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        
                        TabBarItem(icon: "person.circle", title: "Profile", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .frame(height: 70)
                    .background(Color.white)
                }
                
                // Side Menu Overlay
                if showMenu {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showMenu = false
                            }
                        }
                    
                    SideMenuView(isShowing: $showMenu)
                        .transition(.move(edge: .trailing))
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Side Menu View
struct SideMenuView: View {
    @Binding var isShowing: Bool
    @ObservedObject var userProfile = UserProfileManager.shared
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 0) {
                // Profile Section
                VStack(spacing: 12) {
                    // Profile Picture
                    if let image = userProfile.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            )
                    }
                    
                    // Name and Email
                    VStack(spacing: 4) {
                        Text(userProfile.fullName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(userProfile.givenName.isEmpty ? .gray : .black)
                        
                        Text(userProfile.displayEmail)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                Divider()
                
                // Menu Items
                VStack(spacing: 0) {
                    NavigationLink(destination: ViewProfilePage()) {
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color("primary"))
                                .frame(width: 30)
                            
                            Text("Profile")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    NavigationLink(destination: CommunityView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color("primary"))
                                .frame(width: 30)
                            
                            Text("Community")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    NavigationLink(destination: SettingsView()) {
                        HStack(spacing: 16) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color("primary"))
                                .frame(width: 30)
                            
                            Text("Settings")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                    }
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    Button(action: {
                        isShowing = false
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 22))
                                .foregroundColor(.red)
                                .frame(width: 30)
                            
                            Text("Log Out")
                                .font(.system(size: 18))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width * 0.7)
            .background(Color("primary2"))
            .ignoresSafeArea()
            .task {
                await userProfile.loadProfile()
            }
        }
    }
}

// Empty Project Card
struct EmptyProjectCard: View {
    var body: some View {
        HStack {
            Text("No projects created yet")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("primary2").opacity(0.5))
        )
    }
}

// Project Card
struct ProjectCard: View {
    let project: Project
    
    var body: some View {
        Button(action: {
            // Navigate to project details
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                    
                    HStack(spacing: -10) {
                        ForEach(0..<min(project.memberCount, 3), id: \.self) { _ in
                            Circle()
                                .fill(Color("primary"))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        if project.memberCount > 3 {
                            Text("+\(project.memberCount - 3)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                                .padding(.leading, 14)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("primary2"))
            )
        }
    }
}

// Blocked Project Row
struct BlockedProjectRow: View {
    let project: Project
    @State private var isExpanded = false
    @State private var showingActionMenu = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color("p1"))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 18, height: 18)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    
                    if isExpanded, let reason = project.blockReason {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            
                            Text(reason)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.black)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.clear)
            .contentShape(Rectangle())
            
            if isExpanded {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showingActionMenu = true
                    }) {
                        HStack(spacing: 6) {
                            Text("More Options")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("primary2"))
                        .cornerRadius(16)
                    }
                    .confirmationDialog("", isPresented: $showingActionMenu, titleVisibility: .hidden) {
                        Button(action: {
                            print("Resume task: \(project.name)")
                        }) {
                            Label("Resume Task", systemImage: "checkmark.circle")
                        }
                        
                        Button(action: {
                            print("Change status: \(project.name)")
                        }) {
                            Label("Change Status", systemImage: "arrow.triangle.2.circlepath")
                        }
                        
                        Button("Delete Task", role: .destructive) {
                            print("Delete task: \(project.name)")
                        }
                        
                        Button("Cancel", role: .cancel) {}
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
    }
}

// Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color("primary") : .gray)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color("primary") : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomepageView()
}
