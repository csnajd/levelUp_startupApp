//
//  ViewProfilePage.swift
//  levelUp_startupApp
//
//  Created by Ghala Alsalem on 10/02/2026.
//


import SwiftUI
import PhotosUI

struct ViewProfilePage: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditProfileViewModel()
    @State private var isEditMode = false
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
                    
                    if isEditMode {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Edit Photo")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.top, 40)
                
                // First Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("First name")
                        .font(.system(size: 14, weight: .medium))
                    
                    if isEditMode {
                        TextField("First name", text: $viewModel.givenName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(25)
                            .font(.system(size: 16))
                    } else {
                        HStack {
                            Text(viewModel.givenName.isEmpty ? "Not set" : viewModel.givenName)
                                .font(.system(size: 16))
                                .foregroundColor(viewModel.givenName.isEmpty ? .gray : .black)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 24)
                
                // Last Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last name")
                        .font(.system(size: 14, weight: .medium))
                    
                    if isEditMode {
                        TextField("Last name", text: $viewModel.familyName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(25)
                            .font(.system(size: 16))
                    } else {
                        HStack {
                            Text(viewModel.familyName.isEmpty ? "Not set" : viewModel.familyName)
                                .font(.system(size: 16))
                                .foregroundColor(viewModel.familyName.isEmpty ? .gray : .black)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 24)
                
                // Email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14, weight: .medium))
                    
                    if isEditMode {
                        TextField("Email", text: $viewModel.email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(25)
                            .font(.system(size: 16))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    } else {
                        HStack {
                            Text(viewModel.email.isEmpty ? "No email" : viewModel.email)
                                .font(.system(size: 16))
                                .foregroundColor(viewModel.email.isEmpty ? .gray : .black)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 24)
                
                // Phone Number
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone number")
                        .font(.system(size: 14, weight: .medium))
                    
                    if isEditMode {
                        TextField("Phone number", text: $viewModel.phoneNumber)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(25)
                            .font(.system(size: 16))
                            .keyboardType(.phonePad)
                    } else {
                        HStack {
                            Text(viewModel.phoneNumber.isEmpty ? "No phone number" : viewModel.phoneNumber)
                                .font(.system(size: 16))
                                .foregroundColor(viewModel.phoneNumber.isEmpty ? .gray : .black)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 24)
                
                // Gender
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gender")
                        .font(.system(size: 14, weight: .medium))
                    
                    if isEditMode {
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
                            .background(Color("primary1"))
                            .cornerRadius(20)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                    } else {
                        HStack {
                            Text(viewModel.gender.displayName)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                    }
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
                
                // Save Button - ALWAYS ENABLED IN EDIT MODE
                if isEditMode {
                    Button(action: {
                        Task {
                            await viewModel.saveProfile()
                            if viewModel.savedSuccessfully {
                                await UserProfileManager.shared.loadProfile()
                                dismiss()  // ✅ Go back after saving
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("primary1"))
                                .cornerRadius(28)
                        } else {
                            Text("save")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("primary1"))
                                .cornerRadius(28)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color.white)
        .navigationTitle(isEditMode ? "Edit Profile" : "Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode {
                    Button("Cancel") {
                        isEditMode = false
                        Task {
                            await viewModel.loadExistingProfile()
                        }
                    }
                    .foregroundColor(Color("primary1"))
                } else {
                    Button("Edit") {
                        isEditMode = true
                    }
                    .foregroundColor(Color("primary1"))
                }
            }
        }
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
        .task {
            await viewModel.loadExistingProfile()  // ✅ Load from CloudKit
        }
    }
}

#Preview {
    NavigationStack {
        ViewProfilePage()
    }
}
