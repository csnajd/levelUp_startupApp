import SwiftUI
import AuthenticationServices

struct LogInView: View {
    @StateObject private var vm = LogInViewModel()
    @EnvironmentObject var session: AppSession

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    Image("image1")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 320)
                        .padding(.horizontal, 24)

                    Text("Welcome!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("primary1"))

                    SignInWithAppleButton(.signIn) { request in
                        vm.configureAppleRequest(request)
                    } onCompletion: { result in
                        vm.handleAppleResult(result, session: session)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .padding(.horizontal, 32)

                    if vm.isLoading {
                        ProgressView().padding(.top, 8)
                    }

                    if let msg = vm.errorMessage {
                        Text(msg)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Spacer()
                }
            }
            .navigationDestination(isPresented: $vm.shouldNavigateToWelcome) {
                WelcomeView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
