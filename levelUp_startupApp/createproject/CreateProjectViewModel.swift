import Foundation
internal import Combine

@MainActor
final class CreateProjectViewModel: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var projectName: String = ""
    @Published var numberOfTasks: Int = 0
    @Published var selectedUserIDs: [String] = []
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var currentTaskIndex: Int = 0
    @Published var tasks: [TaskCreationData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var projectCreated: Bool = false

    private let cloudService = CloudKitService.shared
    private let communityID: String
    private let currentUserID: String

    init(communityID: String, currentUserID: String) {
        self.communityID = communityID
        self.currentUserID = currentUserID
    }

    var canProceedFromStep1: Bool {
        !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && numberOfTasks > 0
    }

    var canProceedFromStep2: Bool {
        !selectedUserIDs.isEmpty && startDate < endDate
    }

    var canProceedToNextTask: Bool {
        guard currentTaskIndex < tasks.count else { return false }
        let t = tasks[currentTaskIndex]
        return !t.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !t.assignedUserIDs.isEmpty
            && t.startDate < t.endDate
    }

    func nextStep() {
        if currentStep == 1 && canProceedFromStep1 {
            tasks = (0..<numberOfTasks).map { _ in
                TaskCreationData(
                    name: "",
                    priority: .medium,
                    assignedUserIDs: [],
                    startDate: startDate,
                    endDate: endDate
                )
            }
            currentStep = 2

        } else if currentStep == 2 && canProceedFromStep2 {
            currentStep = 3
            currentTaskIndex = 0
        }
    }

    func previousStep() {
        if currentStep == 3 && currentTaskIndex > 0 {
            currentTaskIndex -= 1
        } else if currentStep > 1 {
            currentStep -= 1
        }
    }

    func nextTask() {
        guard canProceedToNextTask else { return }
        if currentTaskIndex < numberOfTasks - 1 {
            currentTaskIndex += 1
        } else {
            Task { await createProject() }
        }
    }

    func updateTaskName(_ name: String) {
        guard currentTaskIndex < tasks.count else { return }
        tasks[currentTaskIndex].name = name
    }

    func updateProjectTaskPriority(_ priority: ProjectTaskPriority) {
        guard currentTaskIndex < tasks.count else { return }
        tasks[currentTaskIndex].priority = priority
    }

    func updateTaskUsers(_ userIDs: [String]) {
        guard currentTaskIndex < tasks.count else { return }
        tasks[currentTaskIndex].assignedUserIDs = userIDs
    }

    func updateTaskStartDate(_ date: Date) {
        guard currentTaskIndex < tasks.count else { return }
        tasks[currentTaskIndex].startDate = date
    }

    func updateTaskEndDate(_ date: Date) {
        guard currentTaskIndex < tasks.count else { return }
        tasks[currentTaskIndex].endDate = date
    }

    var currentTask: TaskCreationData? {
        guard currentTaskIndex < tasks.count else { return nil }
        return tasks[currentTaskIndex]
    }

    func createProject() async {
        isLoading = true
        errorMessage = nil
        showError = false

        do {
            let project = Project(
                name: projectName,
                memberIDs: selectedUserIDs,
                isBlocked: false,
                blockReason: nil,
                createdAt: Date(),
                communityID: communityID
            )

            let savedProject = try await cloudService.saveProject(project)

            for taskData in tasks {
                let task = ProjectTask(
                    projectID: savedProject.id.uuidString,
                    name: taskData.name,
                    priority: taskData.priority,
                    assignedUserIDs: taskData.assignedUserIDs,
                    startDate: taskData.startDate,
                    endDate: taskData.endDate,
                    status: .todo,
                    createdAt: Date(),
                    communityID: communityID
                )
                _ = try await cloudService.saveProjectTask(task)
            }

            projectCreated = true
            isLoading = false

        } catch {
            errorMessage = "Failed to create project: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
}
