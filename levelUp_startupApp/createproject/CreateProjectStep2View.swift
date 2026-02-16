import SwiftUI

struct CreateProjectStep2View: View {
    @ObservedObject var viewModel: CreateProjectViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)

            // Project Name (Display only)
            VStack(alignment: .leading, spacing: 8) {
                Text("Project Name")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)

                HStack {
                    Text(viewModel.projectName)
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color("primary1"), lineWidth: 1.5)
                )
            }
            .padding(.horizontal, 20)

            // Number of Tasks (Display only)
            VStack(alignment: .leading, spacing: 8) {
                Text("Number of Tasks")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)

                HStack {
                    Text("\(viewModel.numberOfTasks) Tasks")
                        .font(.system(size: 15))
                        .foregroundColor(.black)

                    Spacer()

                    Text("select")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Color("primary1"))
                        )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color("primary1"), lineWidth: 1.5)
                )
            }
            .padding(.horizontal, 20)

            // Who can join
            VStack(alignment: .leading, spacing: 8) {
                Text("Who can join")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)

                NavigationLink(destination: UserSelectionView(selectedUserIDs: $viewModel.selectedUserIDs)) {
                    HStack {
                        if viewModel.selectedUserIDs.isEmpty {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                        } else {
                            HStack(spacing: -10) {
                                ForEach(viewModel.selectedUserIDs.prefix(3), id: \.self) { userID in
                                    Circle()
                                        .fill(Color("primary1"))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Text(String(userID.prefix(1)))
                                                .foregroundColor(.white)
                                                .font(.system(size: 14, weight: .medium))
                                        )
                                }
                                if viewModel.selectedUserIDs.count > 3 {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Text("+\(viewModel.selectedUserIDs.count - 3)")
                                                .foregroundColor(.black)
                                                .font(.system(size: 12, weight: .medium))
                                        )
                                }
                            }
                        }

                        Spacer()

                        Text("select")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(Color("primary1"))
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color("primary1"), lineWidth: 1.5)
                    )
                }
            }
            .padding(.horizontal, 20)

            // Project Start Date
            VStack(alignment: .leading, spacing: 8) {
                Text("Project Start date")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)

                DatePicker("", selection: $viewModel.startDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color("primary1"), lineWidth: 1.5)
                    )
            }
            .padding(.horizontal, 20)

            // Project End Date
            VStack(alignment: .leading, spacing: 8) {
                Text("Project End date")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)

                DatePicker("", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
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
                            .fill(viewModel.canProceedFromStep2 ? Color("primary1") : Color.gray.opacity(0.5))
                    )
            }
            .disabled(!viewModel.canProceedFromStep2)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}

