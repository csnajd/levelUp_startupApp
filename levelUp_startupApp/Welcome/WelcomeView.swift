//
//  WelcomeView.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 10/02/2026.
//

//
//  WelcomeView.swift
//  levelUp_startupApp
//
//  Created on 2026-02-10
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()
    @State private var showCreateCommunity = false
    @State private var showJoinCommunity = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            // Profile action
                        }) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 28))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // Notification action
                        }) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Illustration
                    Image("image1") // Make sure to add this to Assets
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding(.horizontal, 40)
                    
                    // Title
                    Text("Discover Your\nTeam Here")
                        .font(.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                        .padding(.bottom, 60)
                    
                    // Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            showCreateCommunity = true
                        }) {
                            Text("Create a Community")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("primary"))
                                .cornerRadius(28)
                        }
                        
                        Text("Or")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                        
                        Button(action: {
                            showJoinCommunity = true
                        }) {
                            Text("Join a Community")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("primary").opacity(0.9))
                                .cornerRadius(28)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showCreateCommunity) {
                CreateCommunityView()
            }
            .navigationDestination(isPresented: $showJoinCommunity) {
//                JoinCommunityView()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
