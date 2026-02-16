import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()
    @State private var showCreateCommunity = false
    @State private var showJoinCommunity = false
    @EnvironmentObject var session: AppSession
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        // Optional: Show profile
                    }) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 28))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Notification action
                    }) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // Illustration
                Image("image1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .padding(.horizontal, 40)
                
                // Title
                Text("Discover Your\nTeam Here")
                    .font(.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showCreateCommunity = true
                    }) {
                        Text("Create a Community")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("primary1"))
                            .cornerRadius(28)
                    }
                    
                    Text("Or")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                    
                    Button(action: {
                        showJoinCommunity = true
                    }) {
                        Text("Join a Community")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("primary1").opacity(0.9))
                            .cornerRadius(28)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .navigationDestination(isPresented: $showCreateCommunity) {
            CreateCommunityView()
                .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $showJoinCommunity) {
            JoinCommunityView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppSession())
}
