import SwiftUI
import PhotosUI

struct ViewProfilePage: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ViewProfileViewModel()
    @State private var isEditMode = false  // ✅ STARTS IN VIEW MODE
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
                    
                    // ONLY show Edit Photo when in edit mode
                    if isEditMode {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Edit Photo")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.top, 40)
                
                // First Name - READ ONLY or EDITABLE
                VStack(alignment: .leading, spacing: 8) {
                    Text("First name")
                        .font(.system(size: 14, weight: .medium))
                    
                    if isEditMode {
                        // EDIT MODE - TextField
                        TextField("First name", text: $viewModel.givenName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(25)
                            .font(.system(size: 16))
                    } else {
                        // VIEW MODE - Just text
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
                
                // Last Name - READ ONLY or EDITABLE
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
                
                // Email - READ ONLY or EDITABLE
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
                
                // Phone Number - READ ONLY or EDITABLE
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
                
                // Gender - READ ONLY or EDITABLE
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
                            .background(Color("primary"))
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
                
                // Save Button - ONLY VISIBLE IN EDIT MODE
                if isEditMode {
                    Button(action: {
                        Task {
                            await viewModel.saveProfile()
                            if viewModel.savedSuccessfully {
                                await UserProfileManager.shared.loadProfile()
                                isEditMode = false  // Switch back to view mode
                            }
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(Color("primary"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(.systemGray6))
                                .cornerRadius(28)
                        } else {
                            Text("save")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(.systemGray6))
                                .cornerRadius(28)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color.white)
        .navigationTitle(isEditMode ? "Edit Profile" : "Profile")  // ✅ Title changes
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditMode {
                    // When editing - show Cancel button
                    Button("Cancel") {
                        isEditMode = false
                        Task {
                            await viewModel.loadExistingProfile()
                        }
                    }
                    .foregroundColor(Color("primary"))
                } else {
                    // When viewing - show Edit button
                    Button("Edit") {
                        isEditMode = true
                    }
                    .foregroundColor(Color("primary"))
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
            await viewModel.loadExistingProfile()
        }
    }
}

#Preview {
    NavigationStack {
        ViewProfilePage()
    }
}