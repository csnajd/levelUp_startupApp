import SwiftUI

struct CreateProjectTaskView: View {
    @ObservedObject var viewModel: CreateProjectViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)

            Text(viewModel.projectName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)

            Text("Task \(viewModel.currentTaskIndex + 1)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)

            ScrollView {
                VStack(spacing: 20) {

                    // Task Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task \(viewModel.currentTaskIndex + 1) Name")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)

                        TextField("e.g. Creating insights", text: Binding(
                            get: { viewModel.currentTask?.name ?? "" },
                            set: { viewModel.updateTaskName($0) }
                        ))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color("primary1"), lineWidth: 1.5)
                        )
                        .font(.system(size: 15))
                    }
                    .padding(.horizontal, 20)

                    // Task Priority
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Priority")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)

                        HStack {
                            Text(viewModel.currentTask?.priority.rawValue ?? "Medium")
                                .font(.system(size: 15))
                                .foregroundColor(.black)

                            Spacer()

                            Menu {
                                ForEach(ProjectTaskPriority.allCases, id: \.self) { priority in
                                    Button(priority.rawValue) {
                                        viewModel.updateProjectTaskPriority(priority)
                                    }
                                }
                            } label: {
                                Text("select")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color("primary1")))
                            }
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

                        NavigationLink(destination: UserSelectionView(selectedUserIDs: Binding(
                            get: { viewModel.currentTask?.assignedUserIDs ?? [] },
                            set: { viewModel.updateTaskUsers($0) }
                        ))) {
                            HStack {
                                if viewModel.currentTask?.assignedUserIDs.isEmpty ?? true {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.gray)
                                } else {
                                    HStack(spacing: -10) {
                                        ForEach((viewModel.currentTask?.assignedUserIDs ?? []).prefix(3), id: \.self) { userID in
                                            Circle()
                                                .fill(Color("primary1"))
                                                .frame(width: 30, height: 30)
                                                .overlay(
                                                    Text(String(userID.prefix(1)))
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 14, weight: .medium))
                                                )
                                        }
                                        if (viewModel.currentTask?.assignedUserIDs.count ?? 0) > 3 {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 30, height: 30)
                                                .overlay(
                                                    Text("+\((viewModel.currentTask?.assignedUserIDs.count ?? 0) - 3)")
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
                                    .background(Capsule().fill(Color("primary1")))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color("primary1"), lineWidth: 1.5)
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // Task Start Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Start date")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)

                        DatePicker("", selection: Binding(
                            get: { viewModel.currentTask?.startDate ?? Date() },
                            set: { viewModel.updateTaskStartDate($0) }
                        ), in: viewModel.startDate...viewModel.endDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color("primary1"), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 20)

                    // Task End Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task End date")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)

                        DatePicker("", selection: Binding(
                            get: { viewModel.currentTask?.endDate ?? Date() },
                            set: { viewModel.updateTaskEndDate($0) }
                        ), in: (viewModel.currentTask?.startDate ?? Date())...viewModel.endDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color("primary1"), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }

            Spacer()

            // Navigation Buttons
            HStack(spacing: 16) {
                if viewModel.currentTaskIndex > 0 {
                    Button(action: { viewModel.previousStep() }) {
                        Text("Previous")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("primary1"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color("primary1"), lineWidth: 1.5)
                            )
                    }
                }

                Button(action: { viewModel.nextTask() }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(viewModel.currentTaskIndex < viewModel.numberOfTasks - 1 ? "Next" : "Create")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(viewModel.canProceedToNextTask ? Color("primary1") : Color.gray.opacity(0.5))
                    )
                }
                .disabled(!viewModel.canProceedToNextTask || viewModel.isLoading)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
}
