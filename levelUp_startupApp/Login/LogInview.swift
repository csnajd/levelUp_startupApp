//
//  LogInview.swift
//  levelUp_startupApp
//
//  Created by Danyah ALbarqawi on 05/02/2026.
//

import SwiftUI
import AuthenticationServices

struct WelcomeView: View {

    @StateObject private var vm = WelcomeViewModel()

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                

                // تقدر تحطين الصورة هنا (Image من Assets)
                Image("image1") // حطي اسمها في Assets
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 320)
                    .padding(.horizontal, 24)

                Text("Welcome!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color("primary"))

                SignInWithAppleButton(.signIn) { request in
                    vm.configureAppleRequest(request)
                } onCompletion: { result in
                    vm.handleAppleResult(result)
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
    }
}
#Preview {
    WelcomeView()
}
