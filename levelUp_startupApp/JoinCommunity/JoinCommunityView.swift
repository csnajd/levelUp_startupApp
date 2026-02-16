import SwiftUI

struct JoinCommunityView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = JoinCommunityViewModel()
    @State private var navigateToHomepage = false
    @EnvironmentObject var session: AppSession
    let inviteCode: String
    
    init(inviteCode: String = "") {
        self.inviteCode = inviteCode
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Join Community")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.horizontal, 24)
                    
                    Text("Enter the invite code to join a community")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Invite Code")
                        .font(.system(size: 16, weight: .semibold))
                    
                    TextField("Enter invite code", text: $viewModel.inviteCode)
                        .textInputAutocapitalization(.characters)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("primary1"), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 24)
                .onAppear {
                    if !inviteCode.isEmpty {
                        viewModel.inviteCode = inviteCode
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                if viewModel.joinedSuccessfully {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Successfully joined the community!")
                            .foregroundColor(.green)
                            .font(.footnote)
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Join Button
                Button(action: {
                    Task {
                        await viewModel.joinCommunity(inviteCode: viewModel.inviteCode)
                        if viewModel.joinedSuccessfully {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            navigateToHomepage = true
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("primary1"))
                            .cornerRadius(25)
                    } else {
                        Text("Join Community")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(viewModel.inviteCode.isEmpty ? Color.gray : Color("primary1"))
                            .cornerRadius(25)
                    }
                }
                .disabled(viewModel.inviteCode.isEmpty || viewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToHomepage) {
            // ✅ FIXED: Pass the required parameters
            if let joinedCommunity = viewModel.joinedCommunity {
                HomepageView(
                    communityID: joinedCommunity.id,
                    communityName: joinedCommunity.name
                )
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    JoinCommunityView()
        .environmentObject(AppSession())
}
