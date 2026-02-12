import Foundation
import CloudKit

enum TaskPriority: String, CaseIterable {
    case urgent, high, medium, low

    var title: String {
        switch self {
        case .urgent: return "Urgent"
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }
}

enum TaskStatus: String {
    case todo, inProgress, done
}

struct AppTask: Identifiable {
    let id: String // recordName
    let ownerUserID: String

    var title: String
    var projectName: String
    var details: String?

    var priority: TaskPriority
    var status: TaskStatus

    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date?

    init(record: CKRecord) {
        self.id = record.recordID.recordName
        self.ownerUserID = record["ownerUserID"] as? String ?? ""

        self.title = record["title"] as? String ?? ""
        self.projectName = record["projectName"] as? String ?? ""
        self.details = record["details"] as? String

        let p = (record["priority"] as? String) ?? "low"
        self.priority = TaskPriority(rawValue: p) ?? .low

        let s = (record["status"] as? String) ?? "todo"
        self.status = TaskStatus(rawValue: s) ?? .todo

        self.dueDate = record["dueDate"] as? Date
        self.createdAt = record["createdAt"] as? Date ?? Date()
        self.updatedAt = record["updatedAt"] as? Date
    }
}
