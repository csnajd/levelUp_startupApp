//
//  SettingsView.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 10/02/2026.
//


import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                Text("Settings")
                    .font(.system(size: 32, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                
                // Settings Options
                VStack(spacing: 16) {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        SettingsButton(icon: "bell.fill", title: "Notifications")
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        SettingsButton(icon: "lock.fill", title: "Privacy")
                    }
                    
                    NavigationLink(destination: AppearanceSettingsView()) {
                        SettingsButton(icon: "rectangle.fill.on.rectangle.fill", title: "Appearance")
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Color("primary1"))
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("primary1"))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color("primary1"), lineWidth: 2)
        )
    }
}

#Preview {
    SettingsView()
}
