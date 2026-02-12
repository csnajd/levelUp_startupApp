import SwiftUI

struct ProfileTasksSummaryView: View {

    @StateObject var vm: ProfileTasksSummaryViewModel

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    header
                    Divider().padding(.horizontal, 2)

                    Text("Tasks")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 4)

                    summaryCard
                    filterRow

                    VStack(spacing: 14) {
                        ForEach(vm.filteredTasks) { t in
                            taskCard(t)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }

            if vm.isLoading {
                ProgressView().scaleEffect(1.2)
            }
        }
        .task { await vm.load() }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: Header
    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 54, height: 54)
                .foregroundStyle(.gray)

            Text("\(vm.displayName)")
                .font(.system(size: 34, weight: .bold))

            Spacer()

            Image(systemName: "bell")
                .font(.system(size: 22))
                .padding(8)
                .background(.white.opacity(0.8))
                .clipShape(Circle())
        }
    }

    // MARK: Summary Card
    private var summaryCard: some View {
        HStack(spacing: 16) {
            progressRing(progress: vm.progress)
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 6) {
                Text("\(Int(vm.progress * 100))%")
                    .font(.system(size: 22, weight: .bold))
                Text("Progress")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 6) {
                Text("\(vm.doneCount)  Done")
                Text("\(vm.inProgressCount)  In progress")
                Text("\(vm.todoCount)  To Do")
            }
            .font(.system(size: 14))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.orange.opacity(0.8), lineWidth: 2)
        )
    }

    // MARK: Filters
    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ProfileTasksSummaryViewModel.Filter.allCases) { f in
                    Button {
                        vm.selectedFilter = f
                    } label: {
                        Text(f.title)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(vm.selectedFilter == f ? Color.orange.opacity(0.5) : Color(.systemBackground))
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .foregroundStyle(.primary)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: Task Card
    private func taskCard(_ t: AppTask) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {

                VStack(alignment: .leading, spacing: 6) {
                    if let d = t.dueDate {
                        Text(dateString(d))
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }

                    Text(t.title)
                        .font(.system(size: 24, weight: .bold))

                    Text(t.projectName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.blue)
                }

                Spacer()

                Image(systemName: "message")
                    .font(.system(size: 18))
            }
            .padding(14)

            HStack {
                Spacer()
                priorityBadge(t.priority)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)

            Divider()

            Button {
                vm.toggleExpand(t.id)
            } label: {
                HStack {
                    Text("More details")
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    Image(systemName: vm.isExpanded(t.id) ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                }
                .padding(12)
            }
            .foregroundStyle(.primary)

            if vm.isExpanded(t.id) {
                VStack(alignment: .leading, spacing: 8) {
                    Text((t.details?.isEmpty == false) ? (t.details ?? "") : "No extra details.")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)

                    Text("Status: \(t.status.rawValue)")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.orange.opacity(0.8), lineWidth: 2)
        )
    }

    // MARK: UI Helpers
    private func priorityBadge(_ p: TaskPriority) -> some View {
        Text(p.title)
            .font(.system(size: 13, weight: .bold))
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(priorityColor(p).opacity(0.95))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
    }

    private func priorityColor(_ p: TaskPriority) -> Color {
        switch p {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .green
        }
    }

    private func progressRing(progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.25), lineWidth: 10)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d/MM/yyyy"
        return f.string(from: date)
    }
}
