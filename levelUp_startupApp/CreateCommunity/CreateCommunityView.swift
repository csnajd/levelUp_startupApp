import SwiftUI
struct CreateCommunityView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var session: AppSession
    @StateObject private var viewModel = CreateCommunityViewModel()
    @State private var navigateToHomepage = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Rectangle()
                            .fill(index <= viewModel.currentStep ? Color("primary1") : Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 56)
                .padding(.top, 16)
                
                // Content based on current step
                switch viewModel.currentStep {
                case 0:
                    Step1_CommunityName(viewModel: viewModel)
                case 1:
                    Step2_Permissions(viewModel: viewModel)
                case 2:
                    Step3_InvitePeople(
                        viewModel: viewModel,
                        onComplete: {
                            navigateToHomepage = true
                        }
                    )
                default:
                    EmptyView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.currentStep == 0 {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToHomepage) {
            // ✅ FIXED: Pass the required parameters
            if let communityID = viewModel.createdCommunityID {
                HomepageView(
                    communityID: communityID,
                    communityName: viewModel.communityName
                )
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// MARK: - Step 1: Community Name
struct Step1_CommunityName: View {
    @ObservedObject var viewModel: CreateCommunityViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Create Community")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.horizontal, 24)
                
                Text("Manage the branding for your community profile.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Community Name")
                    .font(.system(size: 16, weight: .semibold))
                
                TextField("e.g. Fiker company", text: $viewModel.communityName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("primary1"), lineWidth: 2)
                    )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                viewModel.nextStep()
            }) {
                Text("Next")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.communityName.isEmpty ? Color.gray : Color("primary1"))
                    .cornerRadius(25)
            }
            .disabled(viewModel.communityName.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Step 2: Permissions
struct Step2_Permissions: View {
    @ObservedObject var viewModel: CreateCommunityViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Community Permissions")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.horizontal, 24)
                
                Text("Control who can access, post, and manage content within your community.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    PermissionSection(
                        title: "Who can join this community?",
                        options: ["Anyone in the organization", "Invite only"],
                        selectedIndex: viewModel.whoCanJoinIndex,
                        onSelect: { viewModel.whoCanJoinIndex = $0 }
                    )
                    
                    PermissionSection(
                        title: "Who can create posts?",
                        options: ["Admins only", "All members"],
                        selectedIndex: viewModel.whoCanPostIndex,
                        onSelect: { viewModel.whoCanPostIndex = $0 }
                    )
                    
                    PermissionSection(
                        title: "Who can manage the community?",
                        options: ["Admins", "Moderators"],
                        selectedIndex: viewModel.whoCanManageIndex,
                        onSelect: { viewModel.whoCanManageIndex = $0 }
                    )
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Additional Settings")
                            .font(.system(size: 18, weight: .semibold))
                        
                        CheckboxRow(
                            title: "Allow file sharing",
                            isChecked: $viewModel.allowFileSharing
                        )
                        
                        CheckboxRow(
                            title: "Allow comments",
                            isChecked: $viewModel.allowComments
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.previousStep()
                }) {
                    Text("Previous")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("primary1"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color("primary1"), lineWidth: 2)
                        )
                }
                
                Button(action: {
                    viewModel.nextStep()
                }) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("primary1"))
                        .cornerRadius(25)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
// MARK: - Step 3: Invite People
struct Step3_InvitePeople: View {
    @ObservedObject var viewModel: CreateCommunityViewModel
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Invite People")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.horizontal, 24)
                
                Text("Share your community invite code")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if let inviteCode = viewModel.generatedInviteCode {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Your Invite Code")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(inviteCode)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color("primary1"))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = inviteCode
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy Invite Code")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("primary1"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color("primary1"), lineWidth: 2)
                        )
                    }
                    
                    Button(action: {
                        viewModel.shareInviteLink()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Invite Link")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("primary1"))
                        .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            Button(action: {
                onComplete()
            }) {
                Text("Done")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.createdCommunityID != nil ? Color("primary1") : Color.gray)
                    .cornerRadius(25)
            }
            .disabled(viewModel.createdCommunityID == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            if viewModel.generatedInviteCode == nil {
                Task {
                    await viewModel.createCommunity()
                }
            }
        }
    }
}

// MARK: - Helper Components
struct PermissionSection: View {
    let title: String
    let options: [String]
    let selectedIndex: Int
    let onSelect: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
            
            ForEach(0..<options.count, id: \.self) { index in
                RadioButton(
                    title: options[index],
                    isSelected: selectedIndex == index,
                    action: { onSelect(index) }
                )
            }
        }
    }
}

struct RadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color("primary1") : .gray)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
    }
}

struct CheckboxRow: View {
    let title: String
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isChecked ? Color("primary1") : .gray)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
    }
}

#Preview {
    CreateCommunityView()
        .environmentObject(AppSession())
}
