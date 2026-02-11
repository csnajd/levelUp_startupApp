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
                    SettingsButton(icon: "bell.fill", title: "Notifications") {
                        // Navigate to notifications settings
                    }
                    
                    SettingsButton(icon: "lock.fill", title: "Privacy") {
                        // Navigate to privacy settings
                    }
                    
                    SettingsButton(icon: "rectangle.fill.on.rectangle.fill", title: "Appearance") {
                        // Navigate to appearance settings
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color("primary"))
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("primary"))
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color("primary"), lineWidth: 2)
            )
        }
    }
}

#Preview {
    SettingsView()
}