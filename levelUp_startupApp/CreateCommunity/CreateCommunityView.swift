//
//  CreateCommunityView.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 10/02/2026.
//

//
//  CreateCommunityView.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

//
//  CreateCommunityView.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

//
//  CreateCommunityView.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

//
//  CreateCommunityView.swift
//  levelUp_startupApp
//
//  Created on 2026-02-11
//

//
//  CreateCommunityView.swift
//  levelUp_startupApp
//
//  Created on 2026-02-11
//

import SwiftUI

struct CreateCommunityView: View {
    @StateObject private var viewModel = CreateCommunityViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 1
    
    var body: some View {
        VStack(spacing: 0) {
            ProgressView(value: Double(currentStep), total: 3)
                .tint(Color("primary"))
                .padding(.horizontal, 24)
                .padding(.top, 16)
            
            TabView(selection: $currentStep) {
                CommunityNameStep(viewModel: viewModel, currentStep: $currentStep)
                    .tag(1)
                
                CommunityPermissionsStep(viewModel: viewModel, currentStep: $currentStep)
                    .tag(2)
                
                InvitePeopleStep(viewModel: viewModel, currentStep: $currentStep)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentStep)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(Color("primary"))
            }
        }
    }
}

// MARK: - Step 1: Community Name
struct CommunityNameStep: View {
    @ObservedObject var viewModel: CreateCommunityViewModel
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create Community")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Give your community a name")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Community Name")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                TextField("Enter community name", text: $viewModel.communityName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button("Next") {
                withAnimation {
                    currentStep = 2
                }
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(viewModel.communityName.isEmpty ? Color.gray : Color("primary"))
            .cornerRadius(28)
            .disabled(viewModel.communityName.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Step 2: Permissions
struct CommunityPermissionsStep: View {
    @ObservedObject var viewModel: CreateCommunityViewModel
    @Binding var currentStep: Int
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Community Permissions")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Control who can access, post, and manage content\nwithin your community.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Who can join this community?")
                            .font(.system(size: 16, weight: .semibold))
                        
                        PermissionOption(
                            isSelected: viewModel.anyoneCanJoin,
                            title: "Anyone in the organization",
                            action: {
                                viewModel.anyoneCanJoin = true
                                viewModel.inviteOnly = false
                            }
                        )
                        
                        PermissionOption(
                            isSelected: viewModel.inviteOnly,
                            title: "Invite only",
                            action: {
                                viewModel.anyoneCanJoin = false
                                viewModel.inviteOnly = true
                            }
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Who can create posts?")
                            .font(.system(size: 16, weight: .semibold))
                        
                        PermissionOption(
                            isSelected: viewModel.adminsOnlyPost,
                            title: "Admins only",
                            action: {
                                viewModel.adminsOnlyPost = true
                                viewModel.allMembersPost = false
                            }
                        )
                        
                        PermissionOption(
                            isSelected: viewModel.allMembersPost,
                            title: "All members",
                            action: {
                                viewModel.adminsOnlyPost = false
                                viewModel.allMembersPost = true
                            }
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Who can manage the community?")
                            .font(.system(size: 16, weight: .semibold))
                        
                        PermissionOption(
                            isSelected: viewModel.adminManaged,
                            title: "Admins",
                            action: {
                                viewModel.adminManaged = true
                                viewModel.moderatorManaged = false
                            }
                        )
                        
                        PermissionOption(
                            isSelected: viewModel.moderatorManaged,
                            title: "Moderators",
                            action: {
                                viewModel.adminManaged = false
                                viewModel.moderatorManaged = true
                            }
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Additional Settings")
                            .font(.system(size: 16, weight: .semibold))
                        
                        PermissionOption(
                            isSelected: viewModel.allowFileSharing,
                            title: "Allow file sharing",
                            action: {
                                viewModel.allowFileSharing.toggle()
                            }
                        )
                        
                        PermissionOption(
                            isSelected: viewModel.allowComments,
                            title: "Allow comments",
                            action: {
                                viewModel.allowComments.toggle()
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            
            HStack(spacing: 16) {
                Button("Previous") {
                    withAnimation {
                        currentStep = 1
                    }
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("primary"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color("primary"), lineWidth: 2)
                )
                .cornerRadius(28)
                
                Button("Next") {
                    withAnimation {
                        currentStep = 3
                    }
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("primary"))
                .cornerRadius(28)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Step 3: Invite People
struct InvitePeopleStep: View {
    @ObservedObject var viewModel: CreateCommunityViewModel
    @Binding var currentStep: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .center, spacing: 8) {
                Text("Invite People")
                    .font(.system(size: 28, weight: .bold))
                
              
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 100)
            .padding(.top, 40)
            
            if viewModel.isCreating {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Text("Creating your community...")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                Spacer()
            } else if viewModel.communityCreated {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Community Created!")
                                .font(.system(size: 24, weight: .bold))
                            
                            Text("Share the invite code or link with your team")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Invite Code")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(viewModel.inviteCode)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color("primary"))
                                    
                                    Spacer()
                                    
                                    Button {
                                        UIPasteboard.general.string = viewModel.inviteCode
                                    } label: {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color("primary"))
                                    }
                                }
                                .padding()
                                .background(Color("primary").opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Invite Link")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text(viewModel.inviteLink)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Button {
                                        UIPasteboard.general.string = viewModel.inviteLink
                                    } label: {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color("primary"))
                                    }
                                }
                                .padding()
                                .background(Color("primary").opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            Button {
                                shareInvite()
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Invite")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("primary"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color("primary"), lineWidth: 2)
                                )
                                .cornerRadius(25)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                Spacer()
                
                Button("Go to Community") {
                    dismiss()
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("primary"))
                .cornerRadius(28)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            } else {
                
                VStack(spacing: 20) {
                   
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("primary").opacity(0.3))
//                        .padding(.vertical, 40)
                    
                    Text("You can invite people later from the community settings")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    
                }
                
                Spacer()
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
                
                HStack(spacing: 16) {
                    Button("Previous") {
                        withAnimation {
                            currentStep = 2
                        }
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("primary"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color("primary"), lineWidth: 2)
                    )
                    .cornerRadius(28)
                    
                    Button("Create Community") {
                        viewModel.createCommunitySync()
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color("primary"))
                    .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func shareInvite() {
        let shareText = "Join our community on LevelUp!\nInvite Code: \(viewModel.inviteCode)\nLink: \(viewModel.inviteLink)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Custom Components
struct PermissionOption: View {
    let isSelected: Bool
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color("primary") : Color.gray.opacity(0.3))
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        CreateCommunityView()
    }
}
