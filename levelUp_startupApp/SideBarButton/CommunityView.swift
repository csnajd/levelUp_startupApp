import SwiftUI

struct CommunityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CommunityViewModel()
    @State private var showAddMember = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Back and Add Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    // Add Member Button
                    Button(action: {
                        showAddMember = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color("primary1"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Title
                Text("Community")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search Members", text: $viewModel.searchText)
                        .font(.system(size: 16))
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: {
                        // Voice search
                    }) {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Members List
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if viewModel.filteredMembers.isEmpty {
                    // Empty State
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No community members yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("Members will appear here when they join")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.filteredMembers) { member in
                                MemberCard(member: member)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .task {
                await viewModel.loadMembers()
            }
            .sheet(isPresented: $showAddMember) {
                AddMemberView()
            }
        }
    }
}

struct MemberCard: View {
    let member: CommunityMember
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Picture
            if let image = member.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    )
            }
            
            // Name and Job Title
            VStack(alignment: .leading, spacing: 4) {
                Text(member.fullName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color("primary1"))
                
                Text(member.jobTitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color("primary1").opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color("primary1"), lineWidth: 2)
        )
    }
}

// ✅ FIXED - Add Member View with CloudKit Integration
struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inviteCode = ""
    @State private var inviteLink = ""
    @State private var isLoading = true
    @State private var showCopiedMessage = false
    @State private var copiedItem: CopiedItem?
    
    private let cloudKitService = CloudKitService.shared  // ✅ FIXED: Changed from cloudService
    
    enum CopiedItem {
        case code, link
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading invite details...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            Text("Add Member")
                                .font(.system(size: 28, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding(.top, 40)
                            
                            // Invite Code Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Share Invite Code")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                HStack(spacing: 12) {
                                    Text(inviteCode.isEmpty ? "Loading..." : inviteCode)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color("primary1"))
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        copyToClipboard(inviteCode, item: .code)
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: copiedItem == .code ? "checkmark" : "doc.on.doc")
                                            Text(copiedItem == .code ? "Copied" : "Copy")
                                        }
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(copiedItem == .code ? Color.green : Color("primary1"))
                                        .cornerRadius(20)
                                    }
                                    .disabled(inviteCode.isEmpty)
                                }
                                .padding(16)
                                .background(Color("primary1").opacity(0.1))
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 24)
                            
                            // Invite Link Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Share Invite Link")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                VStack(spacing: 12) {
                                    Text(inviteLink.isEmpty ? "Loading..." : inviteLink)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                        .padding(16)
                                        .background(Color("primary1").opacity(0.1))
                                        .cornerRadius(16)
                                    
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            copyToClipboard(inviteLink, item: .link)
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: copiedItem == .link ? "checkmark" : "doc.on.doc")
                                                Text(copiedItem == .link ? "Copied" : "Copy Link")
                                            }
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(copiedItem == .link ? Color.green : Color("primary1"))
                                            .cornerRadius(20)
                                        }
                                        .disabled(inviteLink.isEmpty)
                                        
                                        Button(action: {
                                            shareInvite()
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "square.and.arrow.up")
                                                Text("Share")
                                            }
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color("primary1"))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color("primary1"), lineWidth: 2)
                                            )
                                        }
                                        .disabled(inviteLink.isEmpty)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Instructions
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(Color("primary1"))
                                    Text("How to invite members:")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("• Share the invite code for quick access")
                                    Text("• Or share the link via messaging apps")
                                    Text("• Members can join using either method")
                                }
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .padding(.leading, 28)
                            }
                            .padding(16)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                            
                            Spacer(minLength: 40)
                        }
                    }
                }
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("primary1"))
                    .fontWeight(.semibold)
                }
            }
            .task {
                await loadInviteDetails()
            }
        }
    }
    
    private func loadInviteDetails() async {
        isLoading = true
        
        do {
            let communities = try await cloudKitService.fetchUserCommunities()  // ✅ Now matches the variable name
            
            if let community = communities.first {
                inviteCode = community.inviteCode
                inviteLink = "levelup://join/\(community.inviteCode)"
                print("✅ Loaded invite code: \(inviteCode)")
            } else {
                print("⚠️ No community found")
                inviteCode = "N/A"
                inviteLink = "No community available"
            }
        } catch {
            print("❌ Error loading invite details: \(error)")
            inviteCode = "Error"
            inviteLink = "Failed to load"
        }
        
        isLoading = false
    }
    
    private func copyToClipboard(_ text: String, item: CopiedItem) {
        UIPasteboard.general.string = text
        copiedItem = item
        
        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedItem = nil
        }
    }
    
    private func shareInvite() {
        let shareText = "Join our community on LevelUp!\nInvite Code: \(inviteCode)\nLink: \(inviteLink)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    CommunityView()
}
