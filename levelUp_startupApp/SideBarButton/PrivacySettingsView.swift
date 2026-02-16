//
//  PrivacySettingsView.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 12/02/2026.
//


import SwiftUI

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var profileVisibility = true
    @State private var showEmail = false
    @State private var showPhoneNumber = false
    @State private var allowInvites = true
    @State private var shareActivity = true
    
    var body: some View {
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
            Text("Privacy")
                .font(.system(size: 32, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Privacy
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Profile Visibility")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            NotificationToggle(
                                title: "Public Profile",
                                description: "Community members can see your profile",
                                isOn: $profileVisibility
                            )
                            
                            Divider()
                                .padding(.leading, 20)
                            
                            NotificationToggle(
                                title: "Show Email",
                                description: "Display email on your profile",
                                isOn: $showEmail
                            )
                            
                            Divider()
                                .padding(.leading, 20)
                            
                            NotificationToggle(
                                title: "Show Phone Number",
                                description: "Display phone number on your profile",
                                isOn: $showPhoneNumber
                            )
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                    
                    // Activity Privacy
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            NotificationToggle(
                                title: "Allow Community Invites",
                                description: "Let others invite you to communities",
                                isOn: $allowInvites
                            )
                            
                            Divider()
                                .padding(.leading, 20)
                            
                            NotificationToggle(
                                title: "Share Activity Status",
                                description: "Show when you're active on projects",
                                isOn: $shareActivity
                            )
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                    
                    // Data & Account
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Data & Account")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                // Download data action
                            }) {
                                HStack {
                                    Image(systemName: "arrow.down.circle")
                                        .foregroundColor(Color("primary1"))
                                    Text("Download My Data")
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                // Delete account action
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                    Text("Delete Account")
                                        .foregroundColor(.red)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

#Preview {
    PrivacySettingsView()
}
