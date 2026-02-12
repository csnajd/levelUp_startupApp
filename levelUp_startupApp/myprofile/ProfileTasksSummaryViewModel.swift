import Foundation
internal import  Combine

@MainActor
final class ProfileTasksSummaryViewModel: ObservableObject {

    enum Filter: String, CaseIterable, Identifiable {
        case all, urgent, high, medium, low
        var id: String { rawValue }

        var title: String {
            switch self {
            case .all: return "All"
            case .urgent: return "Urgent"
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            }
        }
    }

    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var displayName: String
    @Published var ownerUserID: String

    @Published var tasks: [AppTask] = []
    @Published var selectedFilter: Filter = .all
    @Published var expandedTaskIDs: Set<String> = []

    private let service = CloudKitTasksService()

    init(ownerUserID: String, displayName: String = "Hey") {
        self.ownerUserID = ownerUserID
        self.displayName = displayName
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            tasks = try await service.fetchTasks(ownerUserID: ownerUserID)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    var filteredTasks: [AppTask] {
        switch selectedFilter {
        case .all: return tasks
        case .urgent: return tasks.filter { $0.priority == .urgent }
        case .high: return tasks.filter { $0.priority == .high }
        case .medium: return tasks.filter { $0.priority == .medium }
        case .low: return tasks.filter { $0.priority == .low }
        }
    }

    var doneCount: Int { tasks.filter { $0.status == .done }.count }
    var inProgressCount: Int { tasks.filter { $0.status == .inProgress }.count }
    var todoCount: Int { tasks.filter { $0.status == .todo }.count }

    var progress: Double {
        let total = max(tasks.count, 1)
        return Double(doneCount) / Double(total)
    }

    func toggleExpand(_ id: String) {
        if expandedTaskIDs.contains(id) { expandedTaskIDs.remove(id) }
        else { expandedTaskIDs.insert(id) }
    }

    func isExpanded(_ id: String) -> Bool {
        expandedTaskIDs.contains(id)
    }
}
