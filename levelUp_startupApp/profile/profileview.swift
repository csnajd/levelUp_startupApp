//
//  profileview.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 02/02/2026.
//

//
//  profileview.swift
//  levelUp_startupApp
//
import SwiftUI
import PhotosUI

struct profileview: View {
    @StateObject private var viewModel = profileViewModel()
    @State private var showGenderPicker = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Photo
                VStack(spacing: 12) {
                    if let image = viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("Edit Photo")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 40)
                
                // First Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("First name")
                        .font(.system(size: 14, weight: .medium))
                    
                    TextField("First name", text: $viewModel.givenName)
                        .textFieldStyle(ProfileTextFieldStyle())
                }
                .padding(.horizontal, 24)
                
                // Last Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last name")
                        .font(.system(size: 14, weight: .medium))
                    
                    TextField("Last name", text: $viewModel.familyName)
                        .textFieldStyle(ProfileTextFieldStyle())
                }
                .padding(.horizontal, 24)
                
                // Email (Required)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(ProfileTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding(.horizontal, 24)
                
                // Phone Number (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Phone number")
                            .font(.system(size: 14, weight: .medium))
                        
                        Text("(Optional)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Phone number", text: $viewModel.phoneNumber)
                        .textFieldStyle(ProfileTextFieldStyle())
                        .keyboardType(.phonePad)
                }
                .padding(.horizontal, 24)
                
                // Gender
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .font(.system(size: 14, weight: .medium))
                    
                    HStack {
                        Text(viewModel.gender.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button("select") {
                            showGenderPicker = true
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color("primary"))
                        .cornerRadius(20)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(25)
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
                
                // Error Message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
                
                // Save Button
                Button(action: {
                    Task {
                        await viewModel.saveProfile()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("primary"))
                            .cornerRadius(28)
                    } else {
                        Text("save")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(viewModel.isSaveButtonEnabled ? .white : Color(.systemGray3))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(viewModel.isSaveButtonEnabled ? Color("primary") : Color(.systemGray5))
                            .cornerRadius(28)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.isSaveButtonEnabled)
                .disabled(!viewModel.isSaveButtonEnabled || viewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showGenderPicker) {
            GenderPickerView(selectedGender: $viewModel.gender)
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.profileImage = image
                }
            }
        }
    }
}

struct ProfileTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(25)
            .font(.system(size: 16))
    }
}

#Preview {
    NavigationStack {
        profileview()
    }
}
