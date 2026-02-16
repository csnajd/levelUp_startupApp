import SwiftUI
internal import Combine

struct ProjectDetailView: View {
    let project: Project
    @StateObject private var viewModel: ProjectDetailViewModel
    @Environment(\.dismiss) var dismiss
    
    init(project: Project) {
        self.project = project
        _viewModel = StateObject(wrappedValue: ProjectDetailViewModel(project: project))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Project Progress Circle
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(progressColor, lineWidth: 20)
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut, value: viewModel.progress)
                        
                        Text("\(Int(viewModel.progress * 100))%")
                            .font(.system(size: 48, weight: .bold))
                    }
                    
                    // Task Counts
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(viewModel.doneCount)")
                                .font(.system(size: 24, weight: .bold))
                            Text("Done")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(viewModel.inProgressCount)")
                                .font(.system(size: 24, weight: .bold))
                            Text("in progress")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Text("\(viewModel.todoCount)")
                                .font(.system(size: 24, weight: .bold))
                            Text("TO do")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top, 20)
                
                // Project Tasks Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Project Tasks")
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                        Text("\(viewModel.tasks.count) Tasks")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    
                    // Priority Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(title: "All", isSelected: viewModel.selectedFilter == nil) {
                                viewModel.selectedFilter = nil
                            }
                            
                            ForEach(ProjectTaskPriority.allCases, id: \.self) { priority in
                                FilterButton(
                                    title: priority.rawValue,
                                    isSelected: viewModel.selectedFilter == priority
                                ) {
                                    viewModel.selectedFilter = priority
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Tasks List
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if viewModel.filteredTasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No tasks")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.filteredTasks) { task in
                                TaskCard(task: task)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit Project") {
                    // TODO: Add edit functionality
                }
                .foregroundColor(Color("primary"))
            }
        }
        .task {
            await viewModel.loadTasks()
        }
    }
    
    private var progressColor: Color {
        let progress = viewModel.progress
        if progress < 0.33 {
            return .red
        } else if progress < 0.66 {
            return .yellow
        } else {
            return .green
        }
    }
}

// Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color("primary") : Color.gray.opacity(0.2))
                )
        }
    }
}

// Task Card
struct TaskCard: View {
    let task: ProjectTask
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(task.name)
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Image(systemName: "message")
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("Team")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(task.priority.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(priorityColor(task.priority))
                    )
            }
            
            Button(action: {}) {
                HStack {
                    Text("More details")
                        .font(.system(size: 14))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(.black)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("primary2"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("primary1"), lineWidth: 2)
                )
        )
    }
    
    private func priorityColor(_ priority: ProjectTaskPriority) -> Color {
        switch priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .green
        }
    }
}

// ViewModel
@MainActor
class ProjectDetailViewModel: ObservableObject {
    @Published var tasks: [ProjectTask] = []
    @Published var isLoading = false
    @Published var selectedFilter: ProjectTaskPriority? = nil
    
    private let project: Project
    private let cloudService = CloudKitService.shared
    
    init(project: Project) {
        self.project = project
    }
    
    func loadTasks() async {
        isLoading = true
        
        do {
            tasks = try await cloudService.fetchProjectTasks(projectID: project.id.uuidString)
            print("✅ Loaded \(tasks.count) tasks for project \(project.name)")
            isLoading = false
        } catch {
            print("❌ Error loading tasks: \(error)")
            tasks = []
            isLoading = false
        }
    }
    
    var filteredTasks: [ProjectTask] {
        if let filter = selectedFilter {
            return tasks.filter { $0.priority == filter }
        }
        return tasks
    }
    
    var doneCount: Int {
        tasks.filter { $0.status == .done }.count
    }
    
    var inProgressCount: Int {
        tasks.filter { $0.status == .inProgress }.count
    }
    
    var todoCount: Int {
        tasks.filter { $0.status == .todo }.count
    }
    
    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(doneCount) / Double(tasks.count)
    }
}
