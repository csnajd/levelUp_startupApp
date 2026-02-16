import SwiftUI

struct CreateProjectView: View {
    @StateObject private var viewModel: CreateProjectViewModel
    @Environment(\.dismiss) private var dismiss

    init(communityID: String, currentUserID: String) {
        _viewModel = StateObject(
            wrappedValue: CreateProjectViewModel(
                communityID: communityID,
                currentUserID: currentUserID
            )
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    progressBar

                    if viewModel.currentStep == 1 {
                        CreateProjectStep1View(viewModel: viewModel)
                    } else if viewModel.currentStep == 2 {
                        CreateProjectStep2View(viewModel: viewModel)
                    } else {
                        CreateProjectTaskView(viewModel: viewModel)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Create New Project")
                        .font(.system(size: 20, weight: .semibold))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            // ✅ iOS 17+ fixed onChange
            .onChange(of: viewModel.projectCreated) { _, created in
                if created { dismiss() }
            }
        }
    }

    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(1...3, id: \.self) { step in
                Rectangle()
                    .fill(step <= viewModel.currentStep ? Color("primary1") : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

#Preview {
    CreateProjectView(communityID: "test-community", currentUserID: "test-user")
}
