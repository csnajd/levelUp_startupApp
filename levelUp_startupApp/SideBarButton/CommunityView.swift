//
//  CommunityView.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 10/02/2026.
//


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
                            .background(Color("primary"))
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
                    .foregroundColor(Color("primary"))
                
                Text(member.jobTitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color("primary").opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color("primary"), lineWidth: 2)
        )
    }
}

// Add Member View (Placeholder)
struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inviteCode = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Add Member")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Share Invite Code")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    HStack {
                        Text("ABC123XY")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("primary"))
                        
                        Spacer()
                        
                        Button(action: {
                            // Copy invite code
                            UIPasteboard.general.string = "ABC123XY"
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.doc")
                                Text("Copy")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("primary"))
                            .cornerRadius(16)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Text("Share this code with people you want to add to your community")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("primary"))
                }
            }
        }
    }
}

#Preview {
    CommunityView()
}
