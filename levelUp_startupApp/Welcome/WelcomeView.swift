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
    @State private var showProfile = false  // ✅ ADDED
    @EnvironmentObject var session: AppSession  // ✅ ADDED
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            showProfile = true  // ✅ CHANGED
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
                    Image("image1")
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
                // ⚠️ TEMPORARY - Replace with JoinCommunityView() when your friend finishes it
                HomepageView()
                    .navigationBarBackButtonHidden(true)
            }
            .sheet(isPresented: $showProfile) {  // ✅ ADDED
                QuickProfileView()
                    .environmentObject(session)
            }
        }
    }
}

// ✅ ADDED - Quick Profile Sheet
struct QuickProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: AppSession
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Profile Picture
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                    .padding(.top, 40)
                
                // Name
                VStack(spacing: 8) {
                    Text("\(session.givenName) \(session.familyName)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(session.givenName.isEmpty ? .gray : .black)
                    
                    if session.givenName.isEmpty {
                        Text("No name available")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                // Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(session.email.isEmpty ? "No email" : session.email)
                            .font(.system(size: 16))
                            .foregroundColor(session.email.isEmpty ? .gray : .black)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Text("This information was fetched from your Apple ID")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
            .navigationTitle("Your Profile")
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
    WelcomeView()
        .environmentObject(AppSession())
}
