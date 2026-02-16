import SwiftUI

struct HomepageView: View {
    @StateObject private var viewModel = HomepageViewModel()
    @State private var showMenu = false
    @State private var selectedTab = 0

    // ✅ فتح Create Project
    @State private var showCreateProjectSheet = false

    @EnvironmentObject var session: AppSession

    // ✅ لازم يجي من التنقل (AppDestination.homepage)
    let communityID: String
 


  
     let communityName: String

     init(communityID: String, communityName: String = "Home") {
         self.communityID = communityID
         self.communityName = communityName
     }
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {

                    // Header - ONLY show on Home tab
                    if selectedTab == 0 {
                        VStack(spacing: 0) {
                            HStack {
                                Text(viewModel.communityName)
                                    .font(.system(size: 32, weight: .bold))

                                Spacer()

                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showMenu.toggle()
                                    }
                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.system(size: 24))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)

                            Divider()
                                .background(Color("primary1"))
                                .frame(height: 2)
                        }
                        .background(Color.white)
                    }

                    // ✅ MAIN CONTENT
                    ZStack {
                        if selectedTab == 0 {
                            ScrollView {
                                VStack(spacing: 32) {

                                    // ✅ Create Project Button (FIXED)
                                    Button {
                                        // لو القائمة الجانبية مفتوحة سكّريها أول
                                        if showMenu {
                                            withAnimation(.easeInOut(duration: 0.3)) { showMenu = false }
                                        }
                                        showCreateProjectSheet = true
                                    } label: {
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
                                                .stroke(Color("primary1"), lineWidth: 2)
                                        )
                                        // ✅ يخلي كامل المساحة قابلة للضغط
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 24)

                                    // Active Projects Section
                                    if viewModel.hasActiveProjects {
                                        VStack(spacing: 16) {
                                            ForEach(viewModel.activeProjects) { project in
                                                ProjectCard(project: project)
                                                    .padding(.horizontal, 20)
                                            }
                                        }
                                    } else {
                                        EmptyProjectCard()
                                            .padding(.horizontal, 20)
                                    }

                                    // Pending Tasks Section
                                    VStack(spacing: 0) {
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                viewModel.showBlockedProjects.toggle()
                                            }
                                        } label: {
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
                                                    .stroke(Color("primary1"), lineWidth: 2)
                                            )
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.horizontal, 20)

                                        if viewModel.showBlockedProjects {
                                            if viewModel.hasBlockedProjects {
                                                VStack(spacing: 0) {
                                                    ForEach(Array(viewModel.blockedProjects.enumerated()), id: \.element.id) { index, project in
                                                        BlockedProjectRow(project: project)

                                                        if index < viewModel.blockedProjects.count - 1 {
                                                            Divider().padding(.leading, 70)
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
                                                .padding(.top, 16)
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
                                                .padding(.vertical, 40)
                                                .background(Color("grey"))
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                                .padding(.horizontal, 20)
                                                .padding(.top, 16)
                                            }
                                        }
                                    }

                                    Spacer(minLength: 120)
                                }
                            }
                        }

                        if selectedTab == 1 {
                            manView()
                        }

                        if selectedTab == 2 {
                            ProfileTasksSummaryView(
                                vm: ProfileTasksSummaryViewModel(
                                    ownerUserID: session.appleUserID ?? "",
                                    displayName: "\(session.givenName) \(session.familyName)".trimmingCharacters(in: .whitespaces)
                                )
                            )
                        }
                    }
                    .background(Color.white)

                    Divider()

                    // Bottom Tab Bar
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
                        .zIndex(2)
                }
            }
            .navigationBarHidden(true)
            // ✅ sheet لازم يكون خارج الزر عشان يشتغل دايم
            .sheet(isPresented: $showCreateProjectSheet) {
                CreateProjectView(
                    communityID: communityID,
                    currentUserID: session.appleUserID ?? ""
                )
            }
        }
    }
}

// MARK: - Side Menu View
struct SideMenuView: View {
    @Binding var isShowing: Bool
    @ObservedObject var userProfile = UserProfileManager.shared

    var body: some View {
        GeometryReader { geo in
            HStack {
                Spacer()

                VStack(spacing: 0) {
                    VStack(spacing: 12) {
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

                    VStack(spacing: 0) {
                        NavigationLink(destination: ViewProfilePage()) {
                            menuRow(icon: "person.fill", iconColor: Color("primary1"), title: "Profile", titleColor: .black)
                        }

                        Divider().padding(.leading, 60)

                        NavigationLink(destination: CommunityView()) {
                            menuRow(icon: "person.3.fill", iconColor: Color("primary1"), title: "Community", titleColor: .black)
                        }

                        Divider().padding(.leading, 60)

                        NavigationLink(destination: SettingsView()) {
                            menuRow(icon: "gearshape.fill", iconColor: Color("primary1"), title: "Settings", titleColor: .black)
                        }

                        Divider().padding(.leading, 60)

                        Button { isShowing = false } label: {
                            menuRow(icon: "rectangle.portrait.and.arrow.right", iconColor: .red, title: "Log Out", titleColor: .red)
                        }
                    }
                    .padding(.top, 20)

                    Spacer()
                }
                .frame(width: geo.size.width * 0.7)
                .background(Color("primary2"))
                .ignoresSafeArea()
                .task { await userProfile.loadProfile() }
            }
        }
    }

    @ViewBuilder
    private func menuRow(icon: String, iconColor: Color, title: String, titleColor: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)
                .frame(width: 30)

            Text(title)
                .font(.system(size: 18))
                .foregroundColor(titleColor)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.clear)
    }
}

// MARK: - Empty Project Card
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

// MARK: - Project Card
struct ProjectCard: View {
    let project: Project

    var body: some View {
        Button(action: {
            // TODO: Navigate to project details
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)

                    HStack(spacing: -10) {
                        ForEach(0..<min(project.memberCount, 3), id: \.self) { _ in
                            Circle()
                                .fill(Color("primary1"))
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
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
        .buttonStyle(.plain)
    }
}

// MARK: - Blocked Project Row
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

                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
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

                    Button { showingActionMenu = true } label: {
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
                        Button {
                            print("Resume task: \(project.name)")
                        } label: {
                            Label("Resume Task", systemImage: "checkmark.circle")
                        }

                        Button {
                            print("Change status: \(project.name)")
                        } label: {
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

// MARK: - Tab Bar Item
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
                    .foregroundColor(isSelected ? Color("primary1") : .gray)

                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color("primary1") : .gray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomepageView(communityID: "test-community-id")
        .environmentObject(AppSession())
}
