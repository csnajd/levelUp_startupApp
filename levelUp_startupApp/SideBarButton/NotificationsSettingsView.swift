//
//  NotificationsSettingsView.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 12/02/2026.
//


import SwiftUI

struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var projectUpdates = true
    @State private var meetingReminders = true
    @State private var taskAssignments = true
    @State private var communityInvites = false
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    
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
            Text("Notifications")
                .font(.system(size: 32, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Push Notifications Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Delivery Method")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            NotificationToggle(
                                title: "Push Notifications",
                                description: "Receive notifications on your device",
                                isOn: $pushNotifications
                            )
                            
                            Divider()
                                .padding(.leading, 20)
                            
                            NotificationToggle(
                                title: "Email Notifications",
                                description: "Receive notifications via email",
                                isOn: $emailNotifications
                            )
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                    
                    // Activity Notifications
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            NotificationToggle(
                                title: "Project Updates",
                                description: "Get notified about project changes",
                                isOn: $projectUpdates
                            )
                            
                            Divider()
                                .padding(.leading, 20)
                            
                            NotificationToggle(
                                title: "Meeting Reminders",
                                description: "Reminders before meetings start",
                                isOn: $meetingReminders
                            )
                            
                            Divider()
                                .padding(.leading, 20)
                            
                            NotificationToggle(
                                title: "Task Assignments",
                                description: "When you're assigned to a task",
                                isOn: $taskAssignments
                            )
                            
                            Divider()
                                .padding(.leading, 20)
                            
                            NotificationToggle(
                                title: "Community Invites",
                                description: "New member join requests",
                                isOn: $communityInvites
                            )
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
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

struct NotificationToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color("primary1"))
        }
        .padding(16)
    }
}

#Preview {
    NotificationsSettingsView()
}
