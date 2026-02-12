//
//  AppearanceSettingsView.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 12/02/2026.
//


import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTheme = "Light"
    
    let themes = ["Light", "Dark", "System"]
    
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
            Text("Appearance")
                .font(.system(size: 32, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Theme Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Theme")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(themes, id: \.self) { theme in
                                Button(action: {
                                    selectedTheme = theme
                                }) {
                                    HStack {
                                        Image(systemName: themeIcon(for: theme))
                                            .font(.system(size: 20))
                                            .foregroundColor(Color("primary"))
                                            .frame(width: 30)
                                        
                                        Text(theme)
                                            .font(.system(size: 16))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        if selectedTheme == theme {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color("primary"))
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedTheme == theme ? Color("primary2") : Color(.systemGray6))
                                    )
                                }
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
    
    func themeIcon(for theme: String) -> String {
        switch theme {
        case "Light": return "sun.max.fill"
        case "Dark": return "moon.fill"
        case "System": return "circle.lefthalf.filled"
        default: return "circle"
        }
    }
}

#Preview {
    AppearanceSettingsView()
}
