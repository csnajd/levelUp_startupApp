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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
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

#Preview {
    CommunityView()
}