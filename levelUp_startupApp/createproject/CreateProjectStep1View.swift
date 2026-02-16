import SwiftUI

struct CreateProjectStep1View: View {
    @ObservedObject var viewModel: CreateProjectViewModel
    @FocusState private var isProjectNameFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)

            // Project Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Project Name")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)

                TextField("e.g. Counting", text: $viewModel.projectName)
                    .focused($isProjectNameFocused)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color("primary1"), lineWidth: 1.5)
                    )
                    .font(.system(size: 15))
            }
            .padding(.horizontal, 20)

            // Number of Tasks
            VStack(alignment: .leading, spacing: 8) {
                Text("Number of Tasks")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)

                HStack {
                    if viewModel.numberOfTasks > 0 {
                        Text("\(viewModel.numberOfTasks) Tasks")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                    } else {
                        Text("Choose a Number")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Menu {
                        ForEach(1...20, id: \.self) { number in
                            Button("\(number) Tasks") {
                                viewModel.numberOfTasks = number
                            }
                        }
                    } label: {
                        Text("select")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(Color("primary1"))
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color("primary1"), lineWidth: 1.5)
                )
            }
            .padding(.horizontal, 20)

            Spacer()

            // Create Button
            Button(action: { viewModel.nextStep() }) {
                Text("Create New Project")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(viewModel.canProceedFromStep1 ? Color("primary1") : Color.gray.opacity(0.5))
                    )
            }
            .disabled(!viewModel.canProceedFromStep1)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}
